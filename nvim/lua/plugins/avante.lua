local prefix = "<Leader>a"
---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    opts = {
      disabled_tools = { "python", "git_diff", "git_commit", "bash", "web_search", "fetch" },
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        timeout = 30000,
        temperature = 1,
        max_tokens = 8096,
      },
      ollama = {
        endpoint = "http://127.0.0.1:11434/v1",
        model = "deepseek-r1:1.5b",
      },
      auto_suggestions_provider = "ollama",
      behaviour = {
        auto_suggestions = false,
        enable_claude_text_editor_tool_mode = true,
      },
      windows = {
        width = 35,
      },
      highlights = {
        diff = {
          current = "DiffChange",
        },
      },
      mappings = {
        ask = prefix .. "a",
        edit = prefix .. "e",
        refresh = prefix .. "r",
        focus = prefix .. "f",
        toggle = {
          default = prefix .. "t",
          debug = prefix .. "d",
          hint = prefix .. "h",
          suggestion = prefix .. "s",
          repomap = prefix .. "R",
        },
        diff = {
          next = "]c",
          prev = "[c",
        },
        files = {
          add_current = prefix .. ".",
        },
      },
    },
  },
}
