local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Motion>
local M = {
  form_start = {
    desc = "Form start",
    get_candidates = utils.get_forms,
    get_candidate_pos = function(form)
      local row, col, _, _ = (form.open or form.outer):range()
      return row, col
    end,
  },
  form_end = {
    desc = "Form end",
    get_candidates = utils.get_forms,
    get_candidate_pos = function(form)
      local _, _, row, col = (form.close or form.outer):range()
      return row, col
    end,
  },
  prev_elem = {
    desc = "Previous element",
    get_candidates = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local nodes = utils.get_prev_nodes(elem, { "sexp.elem" })
        return vim.list_extend({ elem }, nodes)
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local row, col, _, _ = node:range()
      return row, col
    end,
  },
  next_elem = {
    desc = "Next element",
    get_candidates = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local nodes = utils.get_next_nodes(elem, { "sexp.elem" })
        return nodes
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local row, col, _, _ = node:range()
      return row, col
    end,
  },
  prev_elem_end = {
    desc = "Previous element end",
    get_candidates = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local nodes = utils.get_prev_nodes(elem, { "sexp.elem" })
        return nodes
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local _, _, row, col = node:range()
      return row, col - 1
    end,
  },
  next_elem_end = {
    desc = "Next element end",
    get_candidates = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local nodes = utils.get_next_nodes(elem, { "sexp.elem" })
        return vim.list_extend({ elem }, nodes)
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local _, _, row, col = node:range()
      return row, col - 1
    end,
  },
  prev_top_level = {
    desc = "Previous top level form",
    get_candidates = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        local nodes = utils.get_prev_nodes(form.outer, { "sexp.form" })
        return vim.list_extend({ form.outer }, nodes)
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local row, col, _, _ = node:range()
      return row, col
    end,
  },
  next_top_level = {
    desc = "Next top level form",
    get_candidates = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        local nodes = utils.get_next_nodes(form.outer, { "sexp.form" })
        return nodes
      else
        return {}
      end
    end,
    get_candidate_pos = function(node)
      local row, col, _, _ = node:range()
      return row, col
    end,
  },
}

local metatable = {
  ---@param self TSSexp.Motion
  __call = function(self)
    local n = vim.v.count1
    local candidates = self.get_candidates()
    local row, col
    if candidates[1] ~= nil then
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local row1, col1 = self.get_candidate_pos(candidates[1])
      if row1 == cursor_pos[1] - 1 and col1 == cursor_pos[2] and candidates[n + 1] ~= nil then
        row, col = self.get_candidate_pos(candidates[n + 1])
      elseif candidates[n] ~= nil then
        row, col = self.get_candidate_pos(candidates[n])
      else
        row, col = self.get_candidate_pos(candidates[#candidates])
      end
    end

    if row ~= nil and col ~= nil then
      vim.cmd "normal! m'"
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
    end
  end,
}

for _, motion in pairs(M) do
  setmetatable(motion, metatable)
end

vim.tbl_keys(M)

return M
