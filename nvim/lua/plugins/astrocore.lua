local debug_log = function(msg)
  local log_file = io.open("/tmp/nvim_navigation_debug.log", "a")
  if log_file then
    log_file:write(os.date "%Y-%m-%d %H:%M:%S" .. " - " .. msg .. "\n")
    log_file:close()
  end
end

local function smart_navigation(direction, yabai_direction)
  local current_win = vim.api.nvim_get_current_win()
  -- local win_count = #vim.api.nvim_list_wins()
  -- local current_buf = vim.api.nvim_get_current_buf()
  -- local buf_name = vim.api.nvim_buf_get_name(current_buf)

  -- debug_log(
  --   string.format(
  --     "Navigation attempt: direction=%s, yabai_direction=%s, win_count=%d, buf=%s",
  --     direction,
  --     yabai_direction,
  --     win_count,
  --     buf_name
  --   )
  -- )

  local success = pcall(function() vim.cmd("wincmd " .. direction) end)
  local new_win = vim.api.nvim_get_current_win()

  if not success or current_win == new_win then
    -- debug_log "At edge window, attempting yabai focus"

    -- Method 1: Direct yabai call with immediate execution
    local result = vim
      .system({ "yabai", "-m", "window", "--focus", yabai_direction }, {
        detach = false,
        timeout = 500,
      })
      :wait()

    if result.code ~= 0 then
      debug_log("Yabai focus failed with code: " .. tostring(result.code) .. ", stderr: " .. (result.stderr or ""))

      -- Method 2: Try with a small delay
      -- vim.defer_fn(function()
      --   -- debug_log "Retrying yabai focus with delay"
      --   vim.system({ "yabai", "-m", "window", "--focus", yabai_direction }, { detach = true })
      -- end, 50)
      -- else
      -- debug_log "Yabai focus succeeded"
    end
    -- else
    --   debug_log "Successfully moved within neovim"
  end
end

-- Debug command to check current state
vim.api.nvim_create_user_command("NavigationDebug", function()
  local log_content = vim.fn.readfile("/tmp/nvim_navigation_debug.log", "", -20)
  for _, line in ipairs(log_content) do
    print(line)
  end
end, {})

-- Clear debug log command
vim.api.nvim_create_user_command("NavigationDebugClear", function()
  os.remove "/tmp/nvim_navigation_debug.log"
  print "Navigation debug log cleared"
end, {})

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        loaded_matchparen = 1,
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    autocmds = {
      focus_tracker = {
        {
          event = { "VimEnter", "FocusGained" },
          callback = function() vim.system({ "touch", "/tmp/nvim_edge_move_lock" }, { detach = true }) end,
        },
        {
          event = { "FocusLost" },
          callback = function()
            vim.defer_fn(function() vim.system({ "rm", "-f", "/tmp/nvim_edge_move_lock" }, { detach = true }) end, 100)
          end,
        },
        {
          event = { "VimLeavePre" },
          callback = function() vim.system({ "rm", "-f", "/tmp/nvim_edge_move_lock" }, { detach = true }) end,
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        ["<Leader>xp"] = { ":TypstPreview<cr>", desc = "Typst preview start" },
        ["<Leader>xs"] = { ":TypstPreviewStop<cr>", desc = "Typst preview stop" },
        ["<Leader>xf"] = { ":TypstPreviewFollowCursorToggle<cr>", desc = "Typst follow cursor toggle" },
        ["<C-h>"] = {
          function() smart_navigation("h", "west") end,
          desc = "Move to left window or yabai west",
        },
        ["<C-j>"] = {
          function() smart_navigation("j", "south") end,
          desc = "Move to bottom window or yabai south",
        },
        ["<C-k>"] = {
          function() smart_navigation("k", "north") end,
          desc = "Move to top window or yabai north",
        },
        ["<C-l>"] = {
          function() smart_navigation("l", "east") end,
          desc = "Move to right window or yabai east",
        },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
        ["<C-w>"] = { "<C-\\><C-n><C-w>", desc = "Exit terminal mode" },
        ["<C-h>"] = {
          function() smart_navigation("h", "west") end,
          desc = "Move to left window or yabai west",
        },
        ["<C-j>"] = {
          function() smart_navigation("j", "south") end,
          desc = "Move to bottom window or yabai south",
        },
        ["<C-k>"] = {
          function() smart_navigation("k", "north") end,
          desc = "Move to top window or yabai north",
        },
        ["<C-l>"] = {
          function() smart_navigation("l", "east") end,
          desc = "Move to right window or yabai east",
        },
      },
      v = {
        ["<leader>p"] = { "p", desc = "Paste" },
        ["p"] = { "P", desc = "Paste not altering register" },
      },
    },
  },
}
