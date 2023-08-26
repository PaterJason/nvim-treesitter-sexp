local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Motion>
local M = {
  form_start = {
    desc = "Form start",
    get_pos = function()
      local n = vim.v.count1
      local forms = utils.get_forms()
      if forms[1] ~= nil then
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local row1, col1, _, _ = (forms[1].open or forms[1].outer):range()
        if row1 == cursor_pos[1] - 1 and col1 == cursor_pos[2] and forms[n + 1] ~= nil then
          local row, col, _, _ = (forms[n + 1].open or forms[n + 1].outer):range()
          return { row, col }
        elseif forms[n] ~= nil then
          local row, col, _, _ = (forms[n].open or forms[n].outer):range()
          return { row, col }
        end
      end
    end,
  },
  form_end = {
    desc = "Form end",
    get_pos = function()
      local n = vim.v.count1
      local forms = utils.get_forms()
      if forms[1] ~= nil then
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local _, _, row1, col1 = (forms[1].close or forms[1].outer):range()
        if row1 == cursor_pos[1] - 1 and col1 - 1 == cursor_pos[2] and forms[n + 1] ~= nil then
          local _, _, row, col = (forms[n + 1].close or forms[n + 1].outer):range()
          return { row, col - 1 }
        elseif forms[n] ~= nil then
          local _, _, row, col = (forms[n].close or forms[n].outer):range()
          return { row, col - 1 }
        end
      end
    end,
  },
  prev_elem = {
    desc = "Previous element",
    get_pos = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local node = utils.get_prev(elem, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          local row, col, _, _ = node:range()
          return { row, col }
        end
      end
    end,
  },
  next_elem = {
    desc = "Next element",
    get_pos = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local node = utils.get_next(elem, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          local row, col, _, _ = node:range()
          return { row, col }
        end
      end
    end,
  },
  prev_elem_end = {
    desc = "Previous element end",
    get_pos = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local node = utils.get_prev(elem, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          local _, _, row, col = node:range()
          return { row, col - 1 }
        end
      end
    end,
  },
  next_elem_end = {
    desc = "Next element end",
    get_pos = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local node = utils.get_next(elem, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          local _, _, row, col = node:range()
          return { row, col - 1 }
        end
      end
    end,
  },
  prev_top_level = {
    desc = "Previous top level form",
    get_pos = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        local node = utils.get_prev(form.outer, { "sexp.form" }, vim.v.count1)
        if node ~= nil then
          local row, col, _, _ = node:range()
          return { row, col }
        end
      end
    end,
  },
  next_top_level = {
    desc = "Next top level form",
    get_pos = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        local node = utils.get_next(form.outer, { "sexp.form" }, vim.v.count1)
        if node ~= nil then
          local row, col, _, _ = node:range()
          return { row, col }
        end
      end
    end,
  },
}

local metatable = {
  ---@param self TSSexp.Motion
  __call = function(self)
    local pos = self.get_pos()
    if pos ~= nil then
      vim.cmd "normal! m'"
      vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
    end
  end,
}

for _, motion in pairs(M) do
  setmetatable(motion, metatable)
end

vim.tbl_keys(M)

return M
