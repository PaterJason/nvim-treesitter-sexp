local ts_utils = require "nvim-treesitter.ts_utils"
local utils = require "nvim-treesitter.sexp.utils"

---@type table<string, {desc: string, get_node: TSSexpGetNode, get_range:TSSexpGetRange}>
local M = {
  inner_elem = {
    desc = "Inner element",
    get_node = utils.get_elem_node,
    get_range = utils.get_i_range,
  },
  outer_elem = {
    desc = "Outer element",
    get_node = utils.get_elem_node,
    get_range = utils.get_a_range,
  },
  inner_form = {
    desc = "Inner form",
    get_node = utils.get_form_node,
    get_range = utils.get_i_range,
  },
  outer_form = {
    desc = "Outer form",
    get_node = utils.get_form_node,
    get_range = utils.get_a_range,
  },
  inner_top_level = {
    desc = "Inner top level form",
    get_node = utils.get_top_level_node,
    get_range = utils.get_i_range,
  },
  outer_top_level = {
    desc = "Outer top level form",
    get_node = utils.get_top_level_node,
    get_range = utils.get_a_range,
  },
}

for key, textobject in pairs(M) do
  setmetatable(M[key], {
    __call = function()
      local node = textobject.get_node()
      if node == nil then
        vim.notify "Node not found"
        return
      end
      ts_utils.update_selection(0, { textobject.get_range(node) }, "v")
    end,
  })
end

return M
