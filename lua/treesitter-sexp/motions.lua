local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Motion>
local M = {
  form_start = {
    desc = "Form start",
    get_node = function()
      local form = utils.get_form_node_count()
      if form ~= nil then
        return form.open or form.outer
      end
    end,
    pos = "start",
  },
  form_end = {
    desc = "Form end",
    get_node = function()
      local form = utils.get_form_node_count()
      if form ~= nil then
        return form.close or form.outer
      end
    end,
    pos = "end",
  },
  prev_elem = {
    desc = "Previous element",
    get_node = function()
      local form = utils.get_elem()
      if form ~= nil and form.outer ~= nil then
        return utils.get_prev_node(form.outer, vim.v.count1)
      end
    end,
    pos = "start",
  },
  next_elem = {
    desc = "Next element",
    get_node = function()
      local form = utils.get_elem()
      if form ~= nil and form.outer ~= nil then
        return utils.get_next_node(form.outer, vim.v.count1)
      end
    end,
    pos = "start",
  },
  prev_top_level = {
    desc = "Previous top level form",
    get_node = function()
      local node = utils.get_top_level_form().outer
      if node ~= nil then
        return utils.get_prev_node(node, vim.v.count1)
      end
    end,
    pos = "start",
  },
  next_top_level = {
    desc = "Next top level form",
    get_node = function()
      local node = utils.get_top_level_form().outer
      if node ~= nil then
        return utils.get_next_node(node, vim.v.count1)
      end
    end,
    pos = "start",
  },
}

local metatable = {
  ---@param self TSSexp.Motion
  __call = function(self)
    local node = self.get_node()
    if node == nil then
      vim.notify "Node not found"
      return
    end
    local start_row, start_col, end_row, end_col = node:range()
    if self.pos == "end" then
      vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
    else
      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    end
  end,
}

for _, motion in pairs(M) do
  setmetatable(motion, metatable)
end

vim.tbl_keys(M)

return M
