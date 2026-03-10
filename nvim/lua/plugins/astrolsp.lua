---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      autoformat = true,
      codelens = false,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = false,
        allow_filetypes = {},
        ignore_filetypes = {},
      },
      disabled = {},
      timeout_ms = 1000,
    },
    servers = {
      "rust_analyzer",
    },
    ---@diagnostic disable: missing-fields
    config = {
      rust_analyzer = {
        on_new_config = function(config, root_dir)
          if root_dir and root_dir:match("jolt") then
            config.settings["rust-analyzer"].cargo.features = { "allocative", "host" }
          end
        end,
        settings = {
          ["rust-analyzer"] = {
            numThreads = 3,
            cargo = {
              buildScripts = { enable = true },
            },
            check = {
              command = "clippy",
              extraArgs = { "--no-deps", "--jobs", "3" },
            },
            procMacro = { enable = true },
            completion = {
              termSearch = { enable = true },
            },
            lens = {
              debug = { enable = false },
              run = { enable = false },
            },
          },
        },
      },
    },
    mappings = {
      n = {
        gl = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
      },
    },
  },
}
