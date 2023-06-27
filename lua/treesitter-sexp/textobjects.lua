local utils = require "treesitter-sexp.utils"

--- @type TSSexpGetRange
local function range_i(node)
  local _, _, start_row, start_col = utils.get_unnamed_start_range(node)
  local end_row, end_col, _, _ = utils.get_unnamed_end_range(node)
  return start_row, start_col, end_row, end_col
end

--- @type TSSexpGetRange
local function range_a(node)
  return node:range()
end

--- @type fun(type: "i"|"a", nodefn: TSSexpGetNode): fun()
local function make_textobj(type, nodefn)
  return function()
    local node = nodefn()
    if node == nil then
      vim.notify "Node not found"
    else
      local start_row, start_col, end_row, end_col
      if type == "i" then
        start_row, start_col, end_row, end_col = range_i(node)
      elseif type == "a" then
        start_row, start_col, end_row, end_col = range_a(node)
      end
      vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
      vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
    end
    vim.cmd "normal! gv"
  end
end

--- @alias TSSexpTextObj
--- | "elem"
--- | "form"

--- @type table<TSSexpTextObj, table<"a"|"i", {desc: string, textobj: fun()}>>
local M = {
  elem = {
    a = {
      desc = "An element",
      textobj = make_textobj("a", utils.get_elem_node),
    },
    i = {
      desc = "Inner element",
      textobj = make_textobj("i", utils.get_elem_node),
    }
  },
  form = {
    a = {
      desc = "A form",
      textobj = make_textobj("a", utils.get_form_node),
    },
    i = {
      desc = "Inner form",
      textobj = make_textobj("i", utils.get_form_node),
    }
  },
}

return M
