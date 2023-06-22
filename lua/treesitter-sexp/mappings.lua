local config = require "treesitter-sexp.config"

local descriptions = {
  swap_prev_elem = "Swap previous element",
  swap_next_elem = "Swap next element",
  swap_prev_form = "Swap previous form",
  swap_next_form = "Swap next form",
  promote_form = "Promote form",
  promote_elem = "Promote element",
  splice = "Splice element",

  slurp_left = "Slurp left",
  slurp_right = "Slurp right",
  barf_left = "Barf left",
  barf_right = "Barf right",

  a_elem = "An element",
  a_form = "A form",
  i_elem = "Inner element",
  i_form = "Inner form",
}

local M = {}

local function operate(s)
  vim.go.operatorfunc = "v:lua.require'treesitter-sexp.operators'." .. s
  return "g@l"
end

function M.set()
  -- Overators
  for op, lhs in pairs(config.keymaps) do
    vim.keymap.set("n", lhs, function()
      return operate(op)
    end, {
      expr = true,
      desc = descriptions[op],
    })
  end

  -- Text objects
  if config.textobjects.elem then
    local char = config.textobjects.elem
    vim.keymap.set(
      { "o", "x" },
      "a" .. char,
      ":<C-U> lua require'treesitter-sexp.textobjects'.a_elem()<CR>",
      { desc = descriptions.a_elem }
    )
    vim.keymap.set(
      { "o", "x" },
      "i" .. char,
      ":<C-U> lua require'treesitter-sexp.textobjects'.i_elem()<CR>",
      { desc = descriptions.i_elem }
    )
  end
  if config.textobjects.form then
    local char = config.textobjects.form
    vim.keymap.set(
      { "o", "x" },
      "a" .. char,
      ":<C-U> lua require'treesitter-sexp.textobjects'.a_form()<CR>",
      { desc = descriptions.a_form }
    )
    vim.keymap.set(
      { "o", "x" },
      "i" .. char,
      ":<C-U> lua require'treesitter-sexp.textobjects'.i_form()<CR>",
      { desc = descriptions.i_form }
    )
  end
end

return M
