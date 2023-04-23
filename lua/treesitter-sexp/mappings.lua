local actions = require "treesitter-sexp.actions"
local utils = require "treesitter-sexp.utils"

local M = {}

local function some_fn(s)
  vim.go.operatorfunc = "v:lua.require'treesitter-sexp.operators'." .. s
  return "g@l"
end

function M.set()
  vim.keymap.set("n", "<e", function()
    return some_fn "swap_prev_elem"
  end, { expr = true })
  vim.keymap.set("n", ">e", function()
    return some_fn "swap_next_elem"
  end, { expr = true })
  vim.keymap.set("n", "<f", function()
    return some_fn "swap_prev_form"
  end, { expr = true })
  vim.keymap.set("n", ">f", function()
    return some_fn "swap_next_form"
  end, { expr = true })

  vim.keymap.set("n", "<I", function()
    actions.insert_head(utils.get_elem_node())
  end)
  vim.keymap.set("n", ">I", function()
    actions.insert_tail(utils.get_elem_node())
  end)

  vim.keymap.set("n", "<LocalLeader>o", function()
    return some_fn "promote_form"
  end, { expr = true })
  vim.keymap.set("n", "<LocalLeader>O", function()
    return some_fn "promote_elem"
  end, { expr = true })
  vim.keymap.set("n", "<LocalLeader>@", function()
    return some_fn "splice"
  end, { expr = true })

  vim.keymap.set("n", "<(", function()
    return some_fn "slurp_left"
  end, { expr = true })
  vim.keymap.set("n", ">)", function()
    return some_fn "slurp_right"
  end, { expr = true })
  vim.keymap.set("n", ">(", function()
    return some_fn "barf_left"
  end, { expr = true })
  vim.keymap.set("n", "<)", function()
    return some_fn "barf_right"
  end, { expr = true })
end

return M
