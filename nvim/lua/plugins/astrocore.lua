local function smart_navigation(direction, yabai_direction)
  local current_win = vim.api.nvim_get_current_win()

  local success = pcall(function() vim.cmd("wincmd " .. direction) end)
  local new_win = vim.api.nvim_get_current_win()

  if not success or current_win == new_win then
    local result = vim
      .system({ "yabai", "-m", "window", "--focus", yabai_direction }, {
        detach = false,
        timeout = 500,
      })
      :wait()

    if result.code ~= 0 then
      vim.notify("Yabai focus " .. yabai_direction .. " failed: " .. (result.stderr or ""), vim.log.levels.DEBUG)
    end
  end
end

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
        mouse = "", -- disable mouse support
      },
      g = { -- vim.g.<key>
        loaded_matchparen = 1,
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
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
