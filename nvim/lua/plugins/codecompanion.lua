---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    config = true,
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      display = {
        chat = {
          show_settings = true,
          window = {
            width = 0.35,
          }
        },
        diff = {
          provider = "mini_diff"
        }
      }
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
