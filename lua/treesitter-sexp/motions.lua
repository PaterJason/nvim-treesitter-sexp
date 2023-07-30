local utils = require "treesitter-sexp.utils"

---@type TSSexp.GetFormPos
local function get_outer(form)
  local row, col, _, _ = form.outer:range()
  return row, col
end

---@type TSSexp.GetFormPos
local function get_open(form)
  local row, col, _, _ = form.open:range()
  return row, col
end

---@type TSSexp.GetFormPos
local function get_close(form)
  local row, col, _, _ = form.close:range()
  return row, col
end

---@type table<string, TSSexp.Motion>
local M = {
  form_start = {
    desc = "Form start",
    get_form = utils.get_form_count,
    get_pos = get_open,
  },
  form_end = {
    desc = "Form end",
    get_form = utils.get_form_count,
    get_pos = get_close,
  },
  prev_elem = {
    desc = "Previous element",
    get_form = function()
      local form = utils.get_elem()
      if form ~= nil then
        return utils.get_prev_form(form.outer, vim.v.count1)
      end
    end,
    get_pos = get_outer,
  },
  next_elem = {
    desc = "Next element",
    get_form = function()
      local form = utils.get_elem()
      if form ~= nil then
        return utils.get_next_form(form.outer, vim.v.count1)
      end
    end,
    get_pos = get_outer,
  },
  prev_top_level = {
    desc = "Previous top level form",
    get_form = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        return utils.get_prev_form(form.outer, vim.v.count1)
      end
    end,
    get_pos = get_outer,
  },
  next_top_level = {
    desc = "Next top level form",
    get_form = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        return utils.get_next_form(form.outer, vim.v.count1)
      end
    end,
    get_pos = get_outer,
  },
}

local metatable = {
  ---@param self TSSexp.Motion
  __call = function(self)
    local form = self.get_form()
    if form == nil then
      vim.notify "Node not found"
      return
    end
    local row, col = self.get_pos(form)
    vim.api.nvim_win_set_cursor(0, { row + 1, col })
  end,
}

for _, motion in pairs(M) do
  setmetatable(motion, metatable)
end

vim.tbl_keys(M)

return M
