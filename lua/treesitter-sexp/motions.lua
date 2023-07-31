local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Motion>
local M = {
  form_start = {
    desc = "Form start",
    get_pos = function()
      local form = utils.get_form()
      if form ~= nil then
        local row, col, _, _ = (form.open or form.outer):range()
        return { row, col }
      end
    end,
  },
  form_end = {
    desc = "Form end",
    get_pos = function()
      local form = utils.get_form()
      if form ~= nil then
        local _, _, row, col = (form.close or form.outer):range()
        return { row, col - 1 }
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
      vim.api.nvim_win_set_cursor(0, { pos[1] + 1, pos[2] })
    end
  end,
}

for _, motion in pairs(M) do
  setmetatable(motion, metatable)
end

vim.tbl_keys(M)

return M
