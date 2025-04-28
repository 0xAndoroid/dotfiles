-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  { "AstroNvim/astrocommunity" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.typst" },
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.programming-language-support.csv-vim" },
  { import = "astrocommunity.utility.noice-nvim" },
  { import = "astrocommunity.bars-and-lines.smartcolumn-nvim" },
  {
    "m4xshen/smartcolumn.nvim",
    opts = {
      colorcolumn = "100",
      custom_colorcolumn = {
        typescriptreact = "120",
      },
    },
  },
  { import = "astrocommunity.bars-and-lines.lualine-nvim" },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "sonokai",
      },
    },
  },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
}
