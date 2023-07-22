local utils = require "treesitter-sexp.utils"
local ts_utils = require "nvim-treesitter.ts_utils"

---@type table<string, TSSexp.Action>
local M = {}

function M.swap_next(node)
  node = utils.get_range_max_node(node)
  local next_node = utils.get_next_node_count(node)
  if not node:equal(next_node) then
    ts_utils.swap_nodes(node, next_node, 0, true)
  end
end

function M.swap_prev(node)
  node = utils.get_range_max_node(node)
  local prev_node = utils.get_prev_node_count(node)
  if not node:equal(prev_node) then
    ts_utils.swap_nodes(node, prev_node, 0, true)
  end
end

function M.promote(node)
  local parent_node = utils.get_parent_node_count(node)
  if not node:equal(parent_node) then
    local text = vim.treesitter.get_node_text(node, 0)
    local start_row, start_col, end_row, end_col = utils.get_a_range(parent_node)

    vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n"))
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  end
end

-- Splice the inner range onto the outer range
function M.splice(node)
  local inner_range = { utils.get_i_range(node) }
  local outer_range = { utils.get_a_range(node) }

  local text = vim.api.nvim_buf_get_text(0, inner_range[1], inner_range[2], inner_range[3], inner_range[4], {})
  vim.api.nvim_buf_set_text(0, outer_range[1], outer_range[2], outer_range[3], outer_range[4], text)
end

function M.slurp_left(node)
  local target_node = utils.get_prev_node_count(utils.get_range_max_node(node))
  if target_node ~= nil then
    local start_range = { utils.get_unnamed_start_range(node) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(start_range, { target_range[1], target_range[2], target_range[1], target_range[2] }, 0, true)
  end
end

function M.slurp_right(node)
  local target_node = utils.get_next_node_count(utils.get_range_max_node(node))
  if node:equal(target_node) then
    local end_range = { utils.get_unnamed_end_range(node) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(end_range, { target_range[3], target_range[4], target_range[3], target_range[4] }, 0, true)
  end
end

function M.barf_left(node)
  ---@type TSNode|nil
  if node:named_child_count() == 0 then
    vim.notify "No nodes to barf"
    return
  end
  local target_node = node:child(0)
  if target_node == nil or target_node:named() then
    vim.notify "No valid start range"
    return
  end
  target_node = utils.get_next_node_count(target_node)
  target_node = target_node:next_named_sibling() or target_node:next_sibling()
  if target_node ~= nil then
    local start_range = { utils.get_unnamed_start_range(node) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(start_range, { target_range[1], target_range[2], target_range[1], target_range[2] }, 0, true)
  end
end

function M.barf_right(node)
  ---@type TSNode|nil
  if node:named_child_count() == 0 then
    vim.notify "No nodes to barf"
    return
  end
  local target_node = node:child(node:child_count() - 1)
  if target_node == nil or target_node:named() then
    vim.notify "No valid end range"
    return
  end
  target_node = utils.get_prev_node_count(target_node)
  target_node = target_node:prev_named_sibling() or target_node:prev_sibling()
  if target_node ~= nil then
    local end_range = { utils.get_unnamed_end_range(node) }
    local target_range = { target_node:range() }

    ts_utils.swap_nodes(end_range, { target_range[3], target_range[4], target_range[3], target_range[4] }, 0, true)
  end
end

return M
