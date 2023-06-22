local utils = require "treesitter-sexp.utils"

local M = {}

function M.a_elem()
  local node = utils.get_elem_node()
  if node ~= nil then
    local range = { node:range() }

    vim.fn.setpos("'<", { 0, range[1] + 1, range[2] + 1, 0 })
    vim.fn.setpos("'>", { 0, range[3] + 1, range[4], 0 })
  end
  vim.cmd "normal! gv"
end

function M.i_elem()
  local node = utils.get_elem_node()
  if node ~= nil then
    local _, _, start_row, start_col = utils.get_unnamed_start_range(node)
    local end_row, end_col, _, _ = utils.get_unnamed_end_range(node)

    vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
    vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
  end
  vim.cmd "normal! gv"
end

function M.a_form()
  local node = utils.get_form_node()
  if node ~= nil then
    local range = { node:range() }

    vim.fn.setpos("'<", { 0, range[1] + 1, range[2] + 1, 0 })
    vim.fn.setpos("'>", { 0, range[3] + 1, range[4], 0 })
  end
  vim.cmd "normal! gv"
end

function M.i_form()
  local node = utils.get_form_node()
  if node ~= nil then
    local _, _, start_row, start_col = utils.get_unnamed_start_range(node)
    local end_row, end_col, _, _ = utils.get_unnamed_end_range(node)

    vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
    vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
  end
  vim.cmd "normal! gv"
end

return M
