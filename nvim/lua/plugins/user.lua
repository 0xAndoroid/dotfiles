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
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      image = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    "pocco81/auto-save.nvim",
    opts = {
      enabled = true,
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
    "iden3/vim-circom-syntax",
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   opts = {
  --     formatting = {
  --       format = function(entry, vim_item)
  --         vim_item.kind = require("lspkind").presets.default[vim_item.kind]
  --         vim_item.menu = entry:get_completion_item().detail
  --         return vim_item
  --       end,
  --     },
  --   },
  -- },
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
  {
    "echasnovski/mini.surround",
    version = "*",
    -- No need to copy this inside `setup()`. Will be used automatically.
    opts = {
      mappings = {
        add = "<C-o>a", -- Add surrounding in Normal and Visual modes
        delete = "<C-o>od", -- Delete surrounding
        find = "<C-o>f", -- Find surrounding (to the right)
        find_left = "<C-o>F", -- Find surrounding (to the left)
        highlight = "<C-o>h", -- Highlight surrounding
        replace = "<C-o>r", -- Replace surrounding
        update_n_lines = "<C-o>n", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
}
