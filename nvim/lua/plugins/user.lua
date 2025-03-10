-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "pocco81/auto-save.nvim",
    opts = {
      enabled = true,
    },
    event = "BufRead",
  },
  {
    "MunifTanjim/eslint.nvim",
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
  {
    "hrsh7th/nvim-cmp",
    opts = {
      formatting = {
        format = function(entry, vim_item)
          vim_item.kind = require("lspkind").presets.default[vim_item.kind]
          vim_item.menu = entry:get_completion_item().detail
          return vim_item
        end,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        live_grep = {
          file_ignore_patterns = {
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
          additional_args = function(_) return { "--hidden" } end,
        },
        find_files = {
          file_ignore_patterns = {
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
          hidden = true,
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
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      image = { enabled = false },
      picker = { enabled = true },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },
}
