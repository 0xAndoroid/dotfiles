-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Disable unused providers to remove warnings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Set LSP log level to ERROR only
vim.lsp.log.set_level("ERROR")

-- OSC 52 clipboard for SSH sessions (write-only, paste uses last yank)
-- Read disabled: Zellij blocks it, and it's a security risk
if os.getenv("SSH_TTY") then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = function() return vim.fn.getreg("0") end,
      ["*"] = function() return vim.fn.getreg("0") end,
    },
  }
end
