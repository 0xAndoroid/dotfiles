return {
  {
    "sainnhe/sonokai",
    config = function()
      vim.g.sonokai_style = "andromeda"
      vim.g.sonokai_diagnostic_line_highlight = 1
      vim.g.sonokai_disable_terminal_colors = 1
      vim.g.sonokai_dim_inactive_windows = 1
      vim.g.sonokai_diagnostic_virtual_text = "colored"
    end,
    lazy = false,
    priority = 1000,
  },
}
