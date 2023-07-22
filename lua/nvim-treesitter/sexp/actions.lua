local utils = require "nvim-treesitter.sexp.utils"
local ts_utils = require "nvim-treesitter.ts_utils"

---@alias TSSexpAction fun(node: TSNode): nil

---@type table<string, TSSexpAction>
local M = {}

function M.swap_next(node)
  node = utils.get_range_max_node(node)
  local next_node = node
  for _ = 1, vim.v.count1 do
    next_node = next_node:next_named_sibling()
    if next_node == nil then
      vim.notify "No next node"
      return
    end
  end

  ts_utils.swap_nodes(node, next_node, 0, true)
end

function M.swap_prev(node)
  node = utils.get_range_max_node(node)
  local prev_node = node
  for _ = 1, vim.v.count1 do
    prev_node = prev_node:prev_named_sibling()
    if prev_node == nil then
      vim.notify "No previous node"
      return
    end
  end

  ts_utils.swap_nodes(node, prev_node, 0, true)
end

function M.promote(node)
  local parent_node = node
  for _ = 1, vim.v.count1 do
    local next_parent_node = utils.get_larger_parent(parent_node)
    if next_parent_node == nil then
      vim.notify "No parent node"
      return
    end
    parent_node = next_parent_node
  end

  local text = vim.treesitter.get_node_text(node, 0)
  local start_row, start_col, end_row, end_col = utils.get_a_range(parent_node)

  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(text, "\n"))
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

function M.splice(node)
  local ranges = {}
  for child_node, _ in node:iter_children() do
    if not child_node:named() then
      ranges[#ranges + 1] = { child_node:range() }
    end
  end

  for i = 1, #ranges do
    local range = ranges[#ranges + 1 - i]
    vim.api.nvim_buf_set_text(0, range[1], range[2], range[3], range[4], {})
  end
end

function M.slurp_left(node)
  local start_range = { utils.get_unnamed_start_range(node) }

  local target_node = utils.get_range_max_node(node)
  for _ = 1, vim.v.count1 do
    target_node = target_node:prev_named_sibling()
    if target_node == nil then
      vim.notify "No target node"
      return
    end
  end

  local target_range = { target_node:range() }
  local text = vim.api.nvim_buf_get_text(0, start_range[1], start_range[2], start_range[3], start_range[4], {})

  vim.api.nvim_buf_set_text(0, start_range[1], start_range[2], start_range[3], start_range[4], {})
  vim.api.nvim_buf_set_text(0, target_range[1], target_range[2], target_range[1], target_range[2], text)
  vim.api.nvim_win_set_cursor(0, { target_range[1] + 1, target_range[2] })
end

function M.slurp_right(node)
  local end_range = { utils.get_unnamed_end_range(node) }

  local target_node = utils.get_range_max_node(node)
  for _ = 1, vim.v.count1 do
    target_node = target_node:next_named_sibling()
    if target_node == nil then
      vim.notify "No target node"
      return
    end
  end

  local target_range = { target_node:range() }
  local text = vim.api.nvim_buf_get_text(0, end_range[1], end_range[2], end_range[3], end_range[4], {})

  vim.api.nvim_buf_set_text(0, target_range[3], target_range[4], target_range[3], target_range[4], text)
  vim.api.nvim_buf_set_text(0, end_range[1], end_range[2], end_range[3], end_range[4], {})
  vim.api.nvim_win_set_cursor(0, { target_range[3] + 1, target_range[4] })
end

function M.barf_left(node)
  local start_range = { utils.get_unnamed_start_range(node) }

  local target_node = node:named_child(0)
  if target_node == nil then
    vim.notify "No named node"
    return
  end
  for _ = 1, vim.v.count1 - 1 do
    target_node = target_node:next_named_sibling()
    if target_node == nil then
      vim.notify "No named node"
      return
    end
  end
  target_node = target_node:next_named_sibling() or target_node:next_sibling()

  local target_range = { target_node:range() }
  local text = vim.api.nvim_buf_get_text(0, start_range[1], start_range[2], start_range[3], start_range[4], {})

  vim.api.nvim_buf_set_text(0, target_range[1], target_range[2], target_range[1], target_range[2], text)
  vim.api.nvim_buf_set_text(0, start_range[1], start_range[2], start_range[3], start_range[4], {})
  vim.api.nvim_win_set_cursor(0, { target_range[1] + 1, target_range[2] })
end

function M.barf_right(node)
  local end_range = { utils.get_unnamed_end_range(node) }

  local target_node = node:named_child(node:named_child_count() - 1)
  if target_node == nil then
    vim.notify "No named node"
    return
  end
  for _ = 1, vim.v.count1 - 1 do
    target_node = target_node:prev_named_sibling()
    if target_node == nil then
      vim.notify "No named node"
      return
    end
  end
  target_node = target_node:prev_named_sibling() or target_node:prev_sibling()

  local target_range = { target_node:range() }
  local text = vim.api.nvim_buf_get_text(0, end_range[1], end_range[2], end_range[3], end_range[4], {})

  vim.api.nvim_buf_set_text(0, end_range[1], end_range[2], end_range[3], end_range[4], {})
  vim.api.nvim_buf_set_text(0, target_range[3], target_range[4], target_range[3], target_range[4], text)
  vim.api.nvim_win_set_cursor(0, { target_range[3] + 1, target_range[4] })
end

return M
