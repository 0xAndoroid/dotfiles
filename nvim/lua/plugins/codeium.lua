return {
  "Exafunction/codeium.nvim",
  event = "User AstroFile",
  cmd = "Codeium",
  opts = {
    enable_chat = false,
    enable_cmp_source = false,
    virtual_text = {
      enabled = true,
      key_bindings = {
        accept = "<C-t>",
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
  },
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
  specs = {
    -- {
    --   "onsails/lspkind.nvim",
    --   optional = true,
    --   -- Adds icon for codeium using lspkind
    --   opts = function(_, opts)
    --     if not opts.symbol_map then opts.symbol_map = {} end
    --     opts.symbol_map.Codeium = require("astroui").get_icon("Codeium", 1, true)
    --   end,
    -- },
  },
}
