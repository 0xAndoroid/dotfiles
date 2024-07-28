return {
  {
    "declancm/cinnamon.nvim",
    config = true,
    ---@class CinnamonOptions
    opts = {
      -- Disable the plugin
      disabled = false,
      keymaps = {
        -- Enable the provided 'basic' keymaps
        basic = true,
        -- Enable the provided 'extra' keymaps
        extra = true,
      },
      ---@class ScrollOptions
      options = {
        -- Post-movement callback
        callback = nil, ---@type function?
        -- Delay between each movement step (in ms)
        delay = 4,
        max_delta = {
          -- Maximum distance for line movements. Set to `nil` to disable
          line = nil, ---@type number?
          -- Maximum distance for column movements. Set to `nil` to disable
          column = nil, ---@type number?
          -- Maximum duration for a movement (in ms). Automatically adjusts the step delay
          time = 500, ---@type number
        },
        -- The scrolling mode
        -- `cursor`: Smoothly scrolls the cursor for any movement
        -- `window`: Smoothly scrolls the window only when the cursor moves out of view
        mode = "cursor", ---@type "cursor" | "window"
      },
    },
  },
}
