local yabai_dir_map = {
  left = "west",
  right = "east",
  up = "north",
  down = "south",
}

local plugin_path = "file:" .. vim.fn.expand("~/.dotfiles/zellij/plugins/zellij-nav.wasm")

local function at_edge_handler(ctx)
  if vim.env.ZELLIJ then
    -- Signal zellij-nav plugin to handle zellij pane / yabai window navigation
    vim.system({ "zellij", "pipe", "--plugin", plugin_path, "--name", "nvim_at_edge", "--", ctx.direction })
  else
    -- Outside zellij: call yabai directly
    vim.system({ "yabai", "-m", "window", "--focus", yabai_dir_map[ctx.direction] })
  end
end

return {
  "mrjones2014/smart-splits.nvim",
  opts = {
    at_edge = at_edge_handler,
    multiplexer_integration = false, -- Disable: zellij-nav handles pane movement
    ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
    ignored_buftypes = { "nofile" },
  },
}
