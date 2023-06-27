local actions = require "treesitter-sexp.actions"
local utils = require "treesitter-sexp.utils"

--- @alias TSSexpOpName
--- | "swap_prev_elem"
--- | "swap_next_elem"
--- | "swap_next_form"
--- | "swap_prev_form"
--- | "promote_elem"
--- | "promote_form"
--- | "splice"
--- | "slurp_left"
--- | "slurp_right"
--- | "barf_left"
--- | "barf_right"

--- @type fun(action: TSSexpAction, nodefn: TSSexpGetNode): fun()
local function make_op(action, nodefn)
  return function()
    local node = nodefn()
    if node == nil then
      vim.notify "Node not found"
      return
    end
    action(node)
  end
end

--- @type {name: TSSexpOpName, func: fun(), desc: string}[]
local operators = {
  {
    name = "swap_prev_elem",
    desc = "Swap previous element",
    func = make_op(actions.swap_prev, utils.get_elem_node),
  },
  {
    name = "swap_next_elem",
    desc = "Swap next element",
    func = make_op(actions.swap_next, utils.get_elem_node),
  },
  {
    name = "swap_prev_form",
    desc = "Swap previous form",
    func = make_op(actions.swap_prev, utils.get_form_node),
  },
  {
    name = "swap_next_form",
    desc = "Swap next form",
    func = make_op(actions.swap_next, utils.get_form_node),
  },
  {
    name = "promote_elem",
    desc = "Promote element",
    func = make_op(actions.promote, utils.get_elem_node),
  },
  {
    name = "promote_form",
    desc = "Promote form",
    func = make_op(actions.promote, utils.get_form_node),
  },
  {
    name = "splice",
    desc = "Splice element",
    func = make_op(actions.splice, utils.get_elem_node),
  },
  {
    name = "slurp_left",
    desc = "Slurp left",
    func = make_op(actions.slurp_left, utils.get_elem_node),
  },
  {
    name = "slurp_right",
    desc = "Slurp right",
    func = make_op(actions.slurp_right, utils.get_elem_node),
  },
  {
    name = "barf_left",
    desc = "Barf left",
    func = make_op(actions.barf_left, utils.get_elem_node),
  },
  {
    name = "barf_right",
    desc = "Barf right",
    func = make_op(actions.barf_right, utils.get_elem_node),
  },
}

local M = {}
for _, operator in ipairs(operators) do
  M[operator.name] = operator
end

return M
