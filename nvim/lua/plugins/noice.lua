return {
  {
    "folke/noice.nvim",
    opts = {
      messages = {
        enabled = false, -- Disable message UI (use snacks.notifier instead)
      },
      notify = {
        enabled = false, -- Use snacks.notifier instead
      },
      lsp = {
        progress = {
          enabled = false, -- Disable LSP progress
        },
        hover = {
          enabled = false, -- Use default hover
        },
        signature = {
          enabled = false, -- Use default signature  
        },
        message = {
          enabled = false, -- Disable LSP message UI
        },
        override = {
          -- Disable all LSP overrides
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      cmdline = {
        enabled = true, -- Keep the command line UI you like
        view = "cmdline_popup", -- Use popup view
      },
      routes = {
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "Invalid offset LineCol",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true, -- Keep command palette
        long_message_to_split = false, -- Disable since messages are disabled
        inc_rename = false, -- Disable to avoid conflicts
        lsp_doc_border = false, -- Using default LSP UI
      },
    },
  },
}
