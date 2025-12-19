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
      n = {
        ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        ["<Leader>xp"] = { ":TypstPreview<cr>", desc = "Typst preview start" },
        ["<Leader>xs"] = { ":TypstPreviewStop<cr>", desc = "Typst preview stop" },
        ["<Leader>xf"] = { ":TypstPreviewFollowCursorToggle<cr>", desc = "Typst follow cursor toggle" },
      },
      t = {
        ["<C-w>"] = { "<C-\\><C-n><C-w>", desc = "Exit terminal mode" },
      },
      v = {
        ["<leader>p"] = { "p", desc = "Paste" },
        ["p"] = { "P", desc = "Paste not altering register" },
      },
    },
  },
}
