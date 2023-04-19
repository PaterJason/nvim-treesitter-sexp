local actions = require "treesitter-sexp.actions"
local utils = require "treesitter-sexp.utils"

local M = {}

function M.set()
  vim.keymap.set("n", "<e", function()
    actions.swap_prev(utils.get_node())
  end)
  vim.keymap.set("n", ">e", function()
    actions.swap_next(utils.get_node())
  end)
  vim.keymap.set("n", "<f", function()
    actions.swap_prev(utils.get_node():parent())
  end)
  vim.keymap.set("n", ">f", function()
    actions.swap_next(utils.get_node():parent())
  end)


  vim.keymap.set("n", "<I", function()
    actions.insert_head(utils.get_node())
  end)
  vim.keymap.set("n", ">I", function()
    actions.insert_tail(utils.get_node())
  end)

  vim.keymap.set("n", "<LocalLeader>o", function ()
    actions.promote(utils.get_node():parent())
  end)
  vim.keymap.set("n", "<LocalLeader>O", function ()
    actions.promote(utils.get_node())
    -- vim.go.operatorfunc = "v:lua.require'treesitter-sexp.actions'.get_node"
  end)
  vim.keymap.set("n", "<LocalLeader>@", function ()
    actions.splice(utils.get_node())
  end)

  vim.keymap.set("n", "<(", function ()
    actions.slurp_left(utils.get_node())
  end)
  vim.keymap.set("n", ">)", function ()
    actions.slurp_right(utils.get_node())
  end)
  vim.keymap.set("n", ">(", function ()
    actions.barf_left(utils.get_node())
  end)
  vim.keymap.set("n", "<)", function ()
    actions.barf_right(utils.get_node())
  end)
end

return M
