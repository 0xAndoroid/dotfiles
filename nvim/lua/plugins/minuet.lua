return {
  {
    {
      "milanglacier/minuet-ai.nvim",
      config = function()
        require("minuet").setup {
          provider = "gemini",
          throttle = 0,
          debounce = 400,
          request_timeout = 2,
          show_on_completion_menu = true,
          virtualtext = {
            auto_trigger_ft = { "rust", "lua", "typst", "typescript", "javascript", "markdown" },
            -- auto_trigger_ft = {},
            keymap = {
              -- accept whole completion
              accept = "<C-t>",
              -- accept one line
              accept_line = "<C-a>",
              -- accept n lines (prompts for number)
              -- e.g. "A-z 2 CR" will accept 2 lines
              accept_n_lines = nil,
              -- Cycle to prev completion item, or manually invoke completion
              prev = "<C-[>",
              -- Cycle to next completion item, or manually invoke completion
              next = "<C-]>",
              dismiss = "<A-e>",
            },
          },
          provider_options = {
            gemini = {
              model = "gemini-2.0-flash",
              stream = false,
              optional = {
                generationConfig = {
                  maxOutputTokens = 256,
                },
                safetySettings = {
                  {
                    category = "HARM_CATEGORY_DANGEROUS_CONTENT",
                    threshold = "BLOCK_NONE",
                  },
                },
              },
            },
          },
        }
      end,
    },
    { "nvim-lua/plenary.nvim" },
  },
}
