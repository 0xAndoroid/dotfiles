return {
  {
    "max397574/better-escape.nvim",
    event = "InsertCharPre",
    opts = {
      timeout = 500,
      default_mappings = true,
      mappings = {
        i = {
          j = {
            k = "<Esc>",
            j = false,
          },
        },
        c = {
          j = {
            k = "<Esc>",
            j = false,
          },
        },
        t = {
          j = {
            k = false,
            j = false,
          },
        },
        v = {
          j = {
            k = false,
          },
        },
        s = {
          j = {
            k = false,
          },
        },
      },
    },
  },
}
