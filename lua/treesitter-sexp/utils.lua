local config = require "treesitter-sexp.config"

local M = {}

function M.get_valid_node(node)
  local parent = node:parent()

  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  local ignored_types = config.ignored_node_types[lang] or {}
  while parent ~= nil and vim.tbl_contains(ignored_types, node:type()) do
    local next_parent = parent:parent()
    node = parent
    parent = next_parent
  end
  return node
end

function M.get_range_max_node(node)
  local parent = node:parent()

  while parent ~= nil and parent:child_count() == 1 do
    local next_parent = parent:parent()
    node = parent
    parent = next_parent
  end
  return node
end

function M.get_elem_node()
  local node = M.get_valid_node(vim.treesitter.get_node())
  if node == nil then
    vim.notify "Node not found"
    return
  else
    return M.get_range_max_node(node)
  end
end

function M.get_form_node()
  local elem_node = M.get_elem_node()
  if elem_node == nil then
    vim.notify "Node not found"
    return
  end
  local parent_node = elem_node:parent()
  if parent_node == nil then
    vim.notify "Node not found"
    return
  else
    return M.get_range_max_node(parent_node)
  end
end

function M.get_unnamed_start_range(node)
  if node:child_count() == 0 then
    local start_range = { node:range() }
    return start_range[1], start_range[2], start_range[1], start_range[2]
  end

  local start_node = node:child(0)
  local start_range = { start_node:range() }
  if start_node:named() then
    return start_range[1], start_range[2], start_range[1], start_range[2]
  end

  local end_node = start_node
  local end_range
  repeat
    end_range = { end_node:range() }
    end_node = end_node:next_sibling()
  until end_node:named()

  return start_range[1], start_range[2], end_range[3], end_range[4]
end

function M.get_unnamed_end_range(node)
  if node:child_count() == 0 then
    local _, _, end_row, end_col = node:range()
    return end_row, end_col, end_row, end_col
  end

  local end_node = node:child(node:child_count() - 1)
  local end_range = { end_node:range() }
  if end_node:named() then
    return end_range[3], end_range[4], end_range[3], end_range[4]
  end

  local start_node = end_node
  local start_range
  repeat
    start_range = { start_node:range() }
    start_node = start_node:prev_sibling()
  until start_node:named()

  return start_range[1], start_range[2], end_range[3], end_range[4]
end

return M
