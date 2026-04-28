return {
  "zbirenbaum/copilot.lua",
  event = "User AstroFile",
  cmd = "Copilot",
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = "<C-t>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      [""] = false,
      ["*"] = true,
    },
  },
  dependencies = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Copilot = "",
        },
      },
    },
  },
}
