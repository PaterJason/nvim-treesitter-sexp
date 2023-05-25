local actions = require "treesitter-sexp.actions"
local utils = require "treesitter-sexp.utils"

local M = {}

local function operate(s)
  vim.go.operatorfunc = "v:lua.require'treesitter-sexp.operators'." .. s
  return "g@l"
end

function M.set()
  vim.keymap.set("n", "<e", function()
    return operate "swap_prev_elem"
  end, { expr = true })
  vim.keymap.set("n", ">e", function()
    return operate "swap_next_elem"
  end, { expr = true })
  vim.keymap.set("n", "<f", function()
    return operate "swap_prev_form"
  end, { expr = true })
  vim.keymap.set("n", ">f", function()
    return operate "swap_next_form"
  end, { expr = true })

  vim.keymap.set("n", "<I", function()
    actions.insert_head(utils.get_elem_node())
  end)
  vim.keymap.set("n", ">I", function()
    actions.insert_tail(utils.get_elem_node())
  end)

  vim.keymap.set("n", "<LocalLeader>o", function()
    return operate "promote_form"
  end, { expr = true })
  vim.keymap.set("n", "<LocalLeader>O", function()
    return operate "promote_elem"
  end, { expr = true })
  vim.keymap.set("n", "<LocalLeader>@", function()
    return operate "splice"
  end, { expr = true })

  vim.keymap.set("n", "<(", function()
    return operate "slurp_left"
  end, { expr = true })
  vim.keymap.set("n", ">)", function()
    return operate "slurp_right"
  end, { expr = true })
  vim.keymap.set("n", ">(", function()
    return operate "barf_left"
  end, { expr = true })
  vim.keymap.set("n", "<)", function()
    return operate "barf_right"
  end, { expr = true })

  -- Text objects
  vim.keymap.set({ "o", "x" }, "ie", ":<C-U> lua require'treesitter-sexp.operators'.select_elem()<CR>")
  vim.keymap.set({ "o", "x" }, "if", ":<C-U> lua require'treesitter-sexp.operators'.select_form()<CR>")
end

return M
