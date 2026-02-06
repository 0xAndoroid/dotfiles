return {
  "mrjones2014/smart-splits.nvim",
  init = function()
    -- Must set before plugin/smart-splits.lua runs: set_default_multiplexer()
    -- auto-detects $ZELLIJ and caches the mux module in M.__mux, which persists
    -- even after setup() sets multiplexer_integration = false (cache not cleared).
    -- This vim.g var is checked first, preventing the auto-detection entirely.
    vim.g.smart_splits_multiplexer_integration = false
  end,
  opts = {
    multiplexer_integration = false, -- Disable: zellij-nav handles pane movement
    ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
    ignored_buftypes = { "nofile" },
  },
}
