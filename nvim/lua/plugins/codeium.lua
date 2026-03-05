return {
  "Exafunction/windsurf.nvim",
  event = "User AstroFile",
  config = function() require("codeium").setup {
    enable_chat = false,
    enable_cmp_source = false,
    virtual_text = {
      enabled = true,
      filetypes = {
        [""] = false,
      },
      key_bindings = {
        accept = "<C-t>",
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
  } end,
  dependencies = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Codeium = "",
        },
      },
    },
  },
}
