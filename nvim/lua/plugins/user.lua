-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          ["files"] = {
            exclude = {
              "node_modules",
              ".git",
              ".venv",
              "target",
              "dist",
              "build",
              ".next/",
              ".cache",
              "public",
            },
          },
          ["grep"] = {
            exclude = {
              "node_modules",
              ".git",
              ".venv",
              "target",
              "dist",
              "build",
              "*lock.yml",
              ".next/",
              ".cache",
              "*lock.yaml",
              "*.lock",
              "public",
            },
          },
        },
      },
      dashboard = {
        preset = {
          header = table.concat({
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
      bigfile = { enabled = true },
      explorer = {
        enabled = true,
        filters = {
          always_show = {
            ".env",
            ".gitignore", 
            ".gitmodules",
            ".gitattributes",
            "out",
          },
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      image = {
        enabled = true,
        math = {
          enabled = true,
        },
        doc = {
          enabled = true,
          inline = false,
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      -- Replace dressing.nvim functionality
      select = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { 
        enabled = true,
        animate = {
          duration = { step = 10, total = 100 },
        },
      },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    "pocco81/auto-save.nvim",
    opts = {
      enabled = true,
      debounce_delay = 1000, -- Wait 1 second after typing stops
      conditions = {
        exists = true,
        modifiable = true,
        filename_is_not = {},
        filetype_is_not = {},
      },
    },
    event = "BufRead",
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    event = "BufRead",
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_theme = "dark"
    end,
    ft = { "markdown" },
  },
  {
    "ggandor/leap.nvim",
    lazy = false,
    config = function() require("leap").add_default_mappings() end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          always_show = {
            ".env",
            ".gitignore",
            ".gitmodules",
            ".gitattributes",
            "out",
          },
        },
      },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
    opts = {
      disable_diagnostics = true,
      highlights = {
        current = "DiffChange",
      },
    },
  },
}
