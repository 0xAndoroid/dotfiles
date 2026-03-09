return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        ["files"] = {
          exclude = {
            "node_modules",
            ".git",
            ".venv",
            "target",
            "dist",
            "build",
            ".next/",
            ".cache",
            "public",
            "trees",
          },
        },
        ["grep"] = {
          exclude = {
            "node_modules",
            ".git",
            ".venv",
            "target",
            "dist",
            "build",
            "*lock.yml",
            ".next/",
            ".cache",
            "*lock.yaml",
            "*.lock",
            "public",
            "trees",
          },
        },
      },
    },
    dashboard = {
      preset = {
        header = table.concat({
          "███    ██ ██    ██ ██ ███    ███",
          "████   ██ ██    ██ ██ ████  ████",
          "██ ██  ██ ██    ██ ██ ██ ████ ██",
          "██  ██ ██  ██  ██  ██ ██  ██  ██",
          "██   ████   ████   ██ ██      ██",
        }, "\n"),
      },
    },
    bigfile = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    image = {
      enabled = true,
      math = { enabled = true },
      doc = {
        enabled = true,
        inline = false,
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    select = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 10, total = 100 },
      },
    },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
}
