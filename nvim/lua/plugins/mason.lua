---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "nomicfoundation-solidity-language-server",
        "stylua",
        "prettier",
        "tree-sitter-cli",
      },
    },
  },
}
