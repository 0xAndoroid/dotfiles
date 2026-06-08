#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

command_text=$(
  jq -r '
    def object_arg:
      if type == "string" then (try fromjson catch {})
      elif type == "object" then .
      else {}
      end;

    if (.hook_event_name // "") != "PreToolUse" then
      ""
    else
      [
        .tool_input.command?,
        .tool_input.cmd?,
        .input.command?,
        .input.cmd?,
        .parameters.command?,
        .parameters.cmd?,
        .params.command?,
        .params.cmd?,
        .arguments.command?,
        .arguments.cmd?,
        (.arguments? | object_arg | .command?),
        (.arguments? | object_arg | .cmd?),
        (.tool_call.arguments? | object_arg | .command?),
        (.tool_call.arguments? | object_arg | .cmd?),
        .command?,
        .cmd?
      ]
      | map(select(type == "string" and length > 0))
      | .[0] // empty
    end
  ' <<<"$input" 2>/dev/null || true
)

[ -n "$command_text" ] || exit 0

case "$command_text" in
  *python* | *pip*) ;;
  *) exit 0 ;;
esac

blocked=$(
  awk '
    function reset_command() {
      command_position = 1
      env_mode = 0
      env_skip_next = 0
    }

    function basename_of(token, parts, count) {
      count = split(token, parts, "/")
      return parts[count]
    }

    function is_forbidden(token) {
      return token ~ /^python([0-9]+(\.[0-9]+)*)?$/ || token ~ /^pip([0-9]+(\.[0-9]+)*)?$/
    }

    function is_assignment(token) {
      return token ~ /^[A-Za-z_][A-Za-z0-9_]*=.*/
    }

    function is_redirection(token) {
      return token ~ /^([0-9]*>>?|[0-9]*<>|[0-9]*<&|[0-9]*>&|&>|&>>)/
    }

    function evaluate_token(raw, token, lower) {
      if (raw == "" || found) {
        return
      }

      token = raw

      if (!command_position) {
        return
      }

      if (env_skip_next) {
        env_skip_next = 0
        return
      }

      if (env_mode) {
        if (token ~ /^-[uCS]$/) {
          env_skip_next = 1
          return
        }

        if (token ~ /^-/ || is_assignment(token)) {
          return
        }

        env_mode = 0
      }

      if (is_assignment(token) || is_redirection(token)) {
        return
      }

      lower = tolower(basename_of(token))

      if (lower ~ /^(if|then|do|else|elif|while|until|for|case|select|function|!|\{)$/) {
        return
      }

      if (lower == "env") {
        env_mode = 1
        return
      }

      if (lower ~ /^(command|builtin|exec|time|noglob)$/) {
        return
      }

      if (is_forbidden(lower)) {
        print lower
        found = 1
        exit
      }

      command_position = 0
    }

    function emit_token() {
      evaluate_token(token)
      token = ""
    }

    function emit_separator() {
      emit_token()
      reset_command()
    }

    BEGIN {
      reset_command()
    }

    {
      line = $0 "\n"

      for (i = 1; i <= length(line); i++) {
        char = substr(line, i, 1)

        if (comment) {
          if (char == "\n") {
            comment = 0
            emit_separator()
          }
          continue
        }

        if (single_quote) {
          if (char == "'\''") {
            single_quote = 0
          } else {
            token = token char
          }
          continue
        }

        if (double_quote) {
          if (char == "\\") {
            i++
            token = token substr(line, i, 1)
          } else if (char == "\"") {
            double_quote = 0
          } else {
            token = token char
          }
          continue
        }

        if (char == "#") {
          if (token == "") {
            comment = 1
            continue
          }
        } else if (char == "'\''") {
          single_quote = 1
          continue
        } else if (char == "\"") {
          double_quote = 1
          continue
        } else if (char == "\\") {
          i++
          token = token substr(line, i, 1)
          continue
        } else if (char ~ /[ \t\r]/) {
          emit_token()
          continue
        } else if (char == "\n" || char == ";" || char == "|" || char == "&" || char == "(" || char == ")") {
          if ((char == "|" || char == "&") && substr(line, i + 1, 1) == char) {
            i++
          }
          emit_separator()
          continue
        }

        token = token char
      }
    }

    END {
      if (!found) {
        emit_token()
      }
    }
  ' <<<"$command_text"
)

[ -n "$blocked" ] || exit 0

printf 'Use uv instead of %s: uv run python ..., uv run <tool> ..., uv add/remove/sync, or uv pip ...\n' "$blocked" >&2
exit 2
