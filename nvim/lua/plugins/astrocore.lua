---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        mouse = "",
        title = true,
      },
      g = {},
    },
    treesitter = {
      ensure_installed = {
        "lua",
        "solidity",
        "yaml",
        "rust",
      },
    },
    mappings = {
      n = {
        ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        ["<Leader>xp"] = { ":TypstPreview<cr>", desc = "Typst preview start" },
        ["<Leader>xs"] = { ":TypstPreviewStop<cr>", desc = "Typst preview stop" },
        ["<Leader>xf"] = { ":TypstPreviewFollowCursorToggle<cr>", desc = "Typst follow cursor toggle" },
        ["<M-h>"] = { "<cmd>wincmd h<cr>", desc = "Focus left window" },
        ["<M-j>"] = { "<cmd>wincmd j<cr>", desc = "Focus lower window" },
        ["<M-k>"] = { "<cmd>wincmd k<cr>", desc = "Focus upper window" },
        ["<M-l>"] = { "<cmd>wincmd l<cr>", desc = "Focus right window" },
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
