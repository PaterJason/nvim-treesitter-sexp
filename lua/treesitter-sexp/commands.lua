local utils = require "treesitter-sexp.utils"
local ts_utils = require "nvim-treesitter.ts_utils"

---@type table<string, TSSexp.Command>
local M = {
  swap_prev_elem = {
    desc = "Swap previous element",
    call = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        local prev_elem = utils.get_prev(elem, { "sexp.elem" }, vim.v.count1)
        if prev_elem ~= nil then
          ts_utils.swap_nodes(elem, prev_elem, 0, true)
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
          ts_utils.swap_nodes(elem, next_elem, 0, true)
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
          ts_utils.swap_nodes(form.outer, node, 0, true)
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
          ts_utils.swap_nodes(form.outer, node, 0, true)
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
        local text = vim.treesitter.get_node_text(elem, 0)
        local start_row, start_col, end_row, end_col = form.outer:range()

        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n"))
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      end
    end,
  },
  promote_form = {
    desc = "Promote form",
    call = function()
      local forms = utils.get_valid_forms(utils.is_in_form_range, utils.comp_form_ancestor)
      local form1 = forms[1]
      local form2 = forms[2]

      if form1 ~= nil and form2 ~= nil then
        local text = vim.treesitter.get_node_text(form1.outer, 0)
        local start_row, start_col, end_row, end_col = form2.outer:range()

        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n"))
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      end
    end,
  },
  splice = {
    desc = "Splice element",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local inner_range = { utils.get_i_form_range(form) }
        local outer_range = { form.outer:range() }

        local text = vim.api.nvim_buf_get_text(0, inner_range[1], inner_range[2], inner_range[3], inner_range[4], {})
        vim.api.nvim_buf_set_text(0, outer_range[1], outer_range[2], outer_range[3], outer_range[4], text)
      end
    end,
  },
  slurp_left = {
    desc = "Slurp left",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local target_node = utils.get_prev(form.outer, { "sexp.elem" }, vim.v.count1)
        if target_node ~= nil then
          local head_range = { utils.get_head_range(form) }
          local target_range = { target_node:range() }
          ts_utils.swap_nodes(
            head_range,
            { target_range[1], target_range[2], target_range[1], target_range[2] },
            0,
            true
          )
        end
      end
    end,
  },
  slurp_right = {
    desc = "Slurp right",
    call = function()
      local form = utils.get_form()
      if form ~= nil then
        local target_node = utils.get_next(form.outer, { "sexp.elem" }, vim.v.count1)
        if target_node ~= nil then
          local tail_range = { utils.get_tail_range(form) }
          local target_range = { target_node:range() }
          ts_utils.swap_nodes(
            tail_range,
            { target_range[3], target_range[4], target_range[3], target_range[4] },
            0,
            true
          )
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
            local target_row, target_col, _, _ = target_node:range()
            ts_utils.swap_nodes(head_range, { target_row, target_col, target_row, target_col }, 0, true)
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
            local _, _, target_row, target_col = target_node:range()
            ts_utils.swap_nodes(tail_range, { target_row, target_col, target_row, target_col }, 0, true)
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
