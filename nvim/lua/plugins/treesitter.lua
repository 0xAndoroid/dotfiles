-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
      "lua",
      "solidity",
      "yaml",
      "markdown",
    })
    -- opts.textobjects.move = {
    --   enable = true,
    --   set_jumps = true,
    --   goto_next_start = {
    --     [".k"] = { query = "@block.outer", desc = "Next block start" },
    --     [".f"] = { query = "@function.outer", desc = "Next function start" },
    --     [".a"] = { query = "@parameter.inner", desc = "Next argument start" },
    --     [".c"] = { query = "@class.outer", desc = "Next class start" },
    --   },
    --   goto_next_end = {
    --     [".K"] = { query = "@block.outer", desc = "Next block end" },
    --     [".F"] = { query = "@function.outer", desc = "Next function end" },
    --     [".A"] = { query = "@parameter.inner", desc = "Next argument end" },
    --     [".C"] = { query = "@class.outer", desc = "Next class end" },
    --   },
    --   goto_previous_start = {
    --     [",k"] = { query = "@block.outer", desc = "Previous block start" },
    --     [",f"] = { query = "@function.outer", desc = "Previous function start" },
    --     [",a"] = { query = "@parameter.inner", desc = "Previous argument start" },
    --     [",c"] = { query = "@class.outer", desc = "Previous class start" },
    --   },
    --   goto_previous_end = {
    --     [",K"] = { query = "@block.outer", desc = "Previous block end" },
    --     [",F"] = { query = "@function.outer", desc = "Previous function end" },
    --     [",A"] = { query = "@parameter.inner", desc = "Previous argument end" },
    --     [",C"] = { query = "@class.outer", desc = "Previous class end" },
    --   },
    -- }
  end,
}
