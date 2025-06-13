local prefix = "<Leader>a"
---@type LazySpec
return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    cmd = {
      "AvanteAsk",
      "AvanteBuild",
      "AvanteEdit",
      "AvanteRefresh",
      "AvanteSwitchProvider",
      "AvanteChat",
      "AvanteToggle",
      "AvanteClear",
    },
    dependencies = {
      -- "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.mappings.n[prefix] = { desc = " Avante" }
          opts.mappings.n[prefix .. "n"] = { ":AvanteChatNew", desc = "Start new chat" }
          opts.mappings.n[prefix .. "g"] = { ":AvanteHistory", desc = "Open chat history" }
        end,
      },
    },
    opts = {
      disabled_tools = {
        "rag_search",
        "python",
        "run_python",
        "git_diff",
        "git_commit",
        "list_files",
        "search_files",
        "search_keyword",
        "read_file_toplevel_symbols",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash",
        "web_search",
        "fetch",
        "grep",
        "ls",
        "dispatch_agent",
        "glob",
      },
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          extra_request_body = {
            -- temperature = 0,
            max_tokens = 8192,
          },
        },
        ollama = {
          endpoint = "http://127.0.0.1:11434/v1",
          model = "deepseek-r1:1.5b",
        },
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
    specs = { -- configure optional plugins
      { "AstroNvim/astroui", opts = { icons = { Avante = "" } } },
      { -- if copilot.lua is available, default to copilot provider
        "zbirenbaum/copilot.lua",
        optional = true,
        specs = {
          {
            "yetone/avante.nvim",
            opts = {
              provider = "copilot",
              auto_suggestions_provider = "copilot",
            },
          },
        },
      },
      {
        -- make sure `Avante` is added as a filetype
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.file_types then opts.file_types = { "markdown" } end
          opts.file_types = require("astrocore").list_insert_unique(opts.file_types, { "Avante" })
        end,
      },
      {
        -- make sure `Avante` is added as a filetype
        "OXY2DEV/markview.nvim",
        optional = true,
        opts = function(_, opts)
          if not opts.filetypes then opts.filetypes = { "markdown", "quarto", "rmd" } end
          opts.filetypes = require("astrocore").list_insert_unique(opts.filetypes, { "Avante" })
        end,
      },
    },
  },
}
