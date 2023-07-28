local ts_utils = require "nvim-treesitter.ts_utils"
local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Textobject>
local M = {
  inner_elem = {
    desc = "Inner element",
    get_form = utils.get_elem,
    get_range = utils.get_i_range,
  },
  outer_elem = {
    desc = "Outer element",
    get_form = utils.get_elem,
    get_range = utils.get_a_range,
  },
  inner_form = {
    desc = "Inner form",
    get_form = utils.get_form_node_count,
    get_range = utils.get_i_range,
  },
  outer_form = {
    desc = "Outer form",
    get_form = utils.get_form_node_count,
    get_range = utils.get_a_range,
  },
  inner_top_level = {
    desc = "Inner top level form",
    get_form = utils.get_top_level_form,
    get_range = utils.get_i_range,
  },
  outer_top_level = {
    desc = "Outer top level form",
    get_form = utils.get_top_level_form,
    get_range = utils.get_a_range,
  },
}

local metatable = {
  ---@param self TSSexp.Textobject
  __call = function(self)
    local form = self.get_form()
    if form == nil then
      vim.notify "Node not found"
      return
    end
    ts_utils.update_selection(0, { self.get_range(form) }, "v")
  end,
}

for _, textobject in pairs(M) do
  setmetatable(textobject, metatable)
end

return M
