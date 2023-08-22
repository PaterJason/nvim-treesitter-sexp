local utils = require "treesitter-sexp.utils"

---@type table<string, TSSexp.Command>
local M = {
  swap_prev_elem = {
    desc = "Swap previous element",
    call = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local prev_elem = utils.get_prev(elem, { "sexp.elem" }, vim.v.count1)
        if prev_elem ~= nil then
          utils.swap_ranges({ elem:range() }, { prev_elem:range() })
        end
      end
    end,
  },
  swap_next_elem = {
    desc = "Swap next element",
    call = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local next_elem = utils.get_next(elem, { "sexp.elem" }, vim.v.count1)
        if next_elem ~= nil then
          utils.swap_ranges({ elem:range() }, { next_elem:range() })
        end
      end
    end,
  },
  swap_prev_form = {
    desc = "Swap previous form",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local node = utils.get_prev(form.outer, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          utils.swap_ranges({ form.outer:range() }, { node:range() })
        end
      end
    end,
  },
  swap_next_form = {
    desc = "Swap next form",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local node = utils.get_next(form.outer, { "sexp.elem" }, vim.v.count1)
        if node ~= nil then
          utils.swap_ranges({ form.outer:range() }, { node:range() })
        end
      end
    end,
  },
  promote_elem = {
    desc = "Promote element",
    call = function()
      local elem = utils.get_elem()
      local form = utils.get_parent_form(elem)
      if elem ~= nil and form ~= nil then
        utils.promote_range({ elem:range() }, { form.outer:range() })
      end
    end,
  },
  promote_form = {
    desc = "Promote form",
    call = function()
      local forms = utils.get_forms()
      local form1 = forms[1]
      local form2 = forms[2]
      if form1 ~= nil and form2 ~= nil then
        utils.promote_range({ form1.outer:range() }, { form2.outer:range() })
      end
    end,
  },
  splice = {
    desc = "Splice element",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        utils.promote_range({ utils.get_i_form_range(form) }, { form.outer:range() })
      end
    end,
  },
  slurp_left = {
    desc = "Slurp left",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local open_node = form.open
        if open_node ~= nil then
          local target_node = utils.get_prev(form.outer, { "sexp.elem" }, vim.v.count1)
          if target_node ~= nil then
            local head_range = { utils.get_head_range(form) }
            local row, col, _, _ = open_node:range()
            local target_row, target_col, _, _ = target_node:range()
            utils.move_range(head_range, { target_row, target_col }, { row + 1, col })
          end
        end
      end
    end,
  },
  slurp_right = {
    desc = "Slurp right",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local close_node = form.close
        if close_node ~= nil then
          local target_node = utils.get_next(form.outer, { "sexp.elem" }, vim.v.count1)
          if target_node ~= nil then
            local tail_range = { utils.get_tail_range(form) }
            local _, _, row, col = close_node:range()
            local _, _, target_row, target_col = target_node:range()
            utils.move_range(tail_range, { target_row, target_col }, { row + 1, col - 1 })
          end
        end
      end
    end,
  },
  barf_left = {
    desc = "Barf left",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local open_node = form.open
        if open_node ~= nil then
          local target_node = utils.get_next(open_node, { "sexp.elem", "sexp.close" }, vim.v.count1 + 1)
          if target_node ~= nil then
            local head_range = { utils.get_head_range(form) }
            local row, col, _, _ = open_node:range()
            local target_row, target_col, _, _ = target_node:range()
            utils.move_range(head_range, { target_row, target_col }, { row + 1, col })
          end
        end
      end
    end,
  },
  barf_right = {
    desc = "Barf right",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local close_node = form.close
        if close_node ~= nil then
          local target_node = utils.get_prev(close_node, { "sexp.elem", "sexp.open" }, vim.v.count1 + 1)
          if target_node ~= nil then
            local tail_range = { utils.get_tail_range(form) }
            local _, _, row, col = close_node:range()
            local _, _, target_row, target_col = target_node:range()
            utils.move_range(tail_range, { target_row, target_col }, { row + 1, col - 1 })
          end
        end
      end
    end,
  },
}

for _, command in pairs(M) do
  setmetatable(command, { __call = command.call })
end

return M
