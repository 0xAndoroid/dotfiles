---@type LazySpec
return {
  {
    "okuuva/auto-save.nvim",
    opts = {
      enabled = true,
      debounce_delay = 1000,
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
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_theme = "dark"
    end,
    ft = { "markdown" },
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
            ".zshrc",
            ".rustfmt.toml",
            ".skhdrc",
            ".yabairc",
            "out",
          },
        },
      },
    },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = {
      disable_diagnostics = true,
      highlights = {
        current = "DiffChange",
      },
    },
    config = function(_, opts)
      local disable_diagnostics = opts.disable_diagnostics
      local plugin_opts = vim.deepcopy(opts)

      -- git-conflict.nvim v2.1.0 still calls the removed pre-0.12
      -- diagnostic API, so keep its internal toggle off and handle it here.
      plugin_opts.disable_diagnostics = false
      require("git-conflict").setup(plugin_opts)

      if disable_diagnostics then
        local group = vim.api.nvim_create_augroup(
          "user_git_conflict_diagnostics",
          { clear = true }
        )
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "GitConflictDetected",
          callback = function()
            vim.diagnostic.enable(
              false,
              { bufnr = vim.api.nvim_get_current_buf() }
            )
          end,
        })
        vim.api.nvim_create_autocmd("User", {
          group = group,
          pattern = "GitConflictResolved",
          callback = function()
            vim.diagnostic.enable(
              true,
              { bufnr = vim.api.nvim_get_current_buf() }
            )
          end,
        })
      end
    end,
  },
}
