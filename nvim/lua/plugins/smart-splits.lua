local direction_map = {
  left = "west",
  right = "east",
  up = "north",
  down = "south",
}

local function yabai_at_edge(ctx)
  local yabai_dir = direction_map[ctx.direction]
  if not yabai_dir then return end
  vim.system({ "yabai", "-m", "window", "--focus", yabai_dir }, {}, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("Yabai focus " .. yabai_dir .. " failed", vim.log.levels.DEBUG)
      end)
    end
  end)
end

return {
  "mrjones2014/smart-splits.nvim",
  opts = {
    at_edge = yabai_at_edge,
    ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
    ignored_buftypes = { "nofile" },
  },
}
