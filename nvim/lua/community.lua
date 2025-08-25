-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  { "AstroNvim/astrocommunity" },
  { import = "astrocommunity.pack.lua" },
  -- { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.typst" },
  { import = "astrocommunity.programming-language-support.csv-vim" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
}
