-- Disable plugins that are loaded by AstroNvim or community packs
return {
  -- Window picker (not needed)
  { "nvim-window-picker", enabled = false },
  -- Symbols/Outline (can use LSP symbols from snacks.picker)
  { "stevearc/aerial.nvim", enabled = false },
  -- Word highlighting (using native LSP document highlights)
  { "RRethy/vim-illuminate", enabled = false },
}
