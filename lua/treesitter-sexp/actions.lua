local utils = require "treesitter-sexp.utils"
local ts_utils = require "nvim-treesitter.ts_utils"

---@type table<string, TSSexp.Action>
local M = {}

function M.swap_next(form)
  local node = form.outer
  local next_node = utils.get_next_node(node, vim.v.count1)
  if next_node ~= nil then
    ts_utils.swap_nodes(node, next_node, 0, true)
  end
end

function M.swap_prev(form)
  local node = form.outer
  local prev_node = utils.get_prev_node(node, vim.v.count1)
  if prev_node ~= nil then
    ts_utils.swap_nodes(node, prev_node, 0, true)
  end
end

function M.promote(form)
  local node = form.outer
  local parent_node = utils.get_parent_node(node, vim.v.count1)
  if parent_node ~= nil then
    local text = vim.treesitter.get_node_text(node, 0)
    local start_row, start_col, end_row, end_col = parent_node:range()

    vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n"))
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  end
end

-- Splice the inner range onto the outer range
function M.splice(form)
  local inner_range = { utils.get_i_range(form) }
  local outer_range = { utils.get_a_range(form) }

  local text = vim.api.nvim_buf_get_text(0, inner_range[1], inner_range[2], inner_range[3], inner_range[4], {})
  vim.api.nvim_buf_set_text(0, outer_range[1], outer_range[2], outer_range[3], outer_range[4], text)
end

function M.slurp_left(form)
  local node = form.outer
  local target_node = utils.get_prev_node(node, vim.v.count1)
  if target_node ~= nil then
    local start_range = { utils.get_head_range(form) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(start_range, { target_range[1], target_range[2], target_range[1], target_range[2] }, 0, true)
  end
end

function M.slurp_right(form)
  local node = form.outer
  local target_node = utils.get_next_node(node, vim.v.count1)
  if target_node ~= nil then
    local end_range = { utils.get_tail_range(form) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(end_range, { target_range[3], target_range[4], target_range[3], target_range[4] }, 0, true)
  end
end

function M.barf_left(form)
  local open_node = form.open
  if open_node == nil then
    vim.notify "No valid start range"
    return
  end

  local first_node = utils.get_next_node(open_node)
  if first_node == nil then
    vim.notify "No valid child node"
    return
  end

  local target_node = utils.get_next_node(first_node, vim.v.count1)
  local start_range = { utils.get_head_range(form) }
  if target_node ~= nil then
    local target_range = { target_node:range() }
    ts_utils.swap_nodes(start_range, { target_range[1], target_range[2], target_range[1], target_range[2] }, 0, true)
  else
    local close_node = form.close
    if close_node == nil then
      vim.notify "No valid end range"
      return
    end
    local target_range = { close_node:range() }

    ts_utils.swap_nodes(start_range, { target_range[1], target_range[2], target_range[1], target_range[2] }, 0, true)
  end
end

function M.barf_right(form)
  local close_node = form.close
  if close_node == nil then
    vim.notify "No valid end range"
    return
  end

  local last_node = utils.get_prev_node(close_node)
  if last_node == nil then
    vim.notify "No valid child node"
    return
  end

  local target_node = utils.get_prev_node(last_node, vim.v.count1)
  local end_range = { utils.get_tail_range(form) }
  if target_node ~= nil then
    local target_range = { target_node:range() }
    ts_utils.swap_nodes(end_range, { target_range[3], target_range[4], target_range[3], target_range[4] }, 0, true)
  else
    local open_node = form.open
    if open_node == nil then
      vim.notify "No valid start range"
      return
    end
    local target_range = { open_node:range() }

    ts_utils.swap_nodes(end_range, { target_range[3], target_range[4], target_range[3], target_range[4] }, 0, true)
  end
end

return M
