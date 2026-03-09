---@type LazySpec
return {
  {
    "pocco81/auto-save.nvim",
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
    config = true,
    opts = {
      disable_diagnostics = true,
      highlights = {
        current = "DiffChange",
      },
    },
  },
}
