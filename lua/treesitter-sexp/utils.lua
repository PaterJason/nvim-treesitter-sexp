local config = require "treesitter-sexp.config"

local M = {}

--- @type fun(node: TSNode): TSNode
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

--- @type fun(node: TSNode): TSNode
function M.get_range_max_node(node)
  local parent = node:parent()

  while parent ~= nil and parent:child_count() == 1 do
    local next_parent = parent:parent()
    node = parent
    parent = next_parent
  end
  return node
end

--- @alias TSSexpGetNode fun(): TSNode|nil

--- @type TSSexpGetNode
function M.get_elem_node()
  local node = vim.treesitter.get_node()
  if node ~= nil then
    node = M.get_valid_node(node)
    return M.get_range_max_node(node)
  end
end

--- @type TSSexpGetNode
function M.get_form_node()
  local elem_node = M.get_elem_node()
  if elem_node == nil then
    return
  end
  local parent_node = elem_node:parent()
  if parent_node ~= nil then
    return M.get_range_max_node(parent_node)
  end
end

--- @type TSSexpGetNode
function M.get_top_level_node()
  local node = M.get_elem_node()
  if node == nil then
    return
  end
  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()
  for child_node, _ in root:iter_children() do
    if child_node:named() and vim.treesitter.is_ancestor(child_node, node) then
      return child_node
    end
  end
end

--- @alias TSSexpGetRange fun(node: TSNode): integer, integer, integer, integer

--- @type TSSexpGetRange
function M.get_unnamed_start_range(node)
  if node:child_count() == 0 then
    local start_row, start_col, _, _ = node:range()
    return start_row, start_col, start_row, start_col
  end

  local start_node = node:child(0)
  local start_row, start_col, _, _ = start_node:range()
  if start_node:named() then
    return start_row, start_col, start_row, start_col
  end

  local end_node = start_node
  local end_row, end_col
  repeat
    _, _, end_row, end_col = end_node:range()
    end_node = end_node:next_sibling()
  until end_node == nil or end_node:named()

  return start_row, start_col, end_row, end_col
end

--- @type TSSexpGetRange
function M.get_unnamed_end_range(node)
  if node:child_count() == 0 then
    local _, _, end_row, end_col = node:range()
    return end_row, end_col, end_row, end_col
  end

  local end_node = node:child(node:child_count() - 1)
  local _, _, end_row, end_col = end_node:range()
  if end_node:named() then
    return end_row, end_col, end_row, end_col
  end

  local start_node = end_node
  local start_row, start_col
  repeat
    start_row, start_col, _, _ = start_node:range()
    start_node = start_node:prev_sibling()
  until start_node == nil or start_node:named()

  return start_row, start_col, end_row, end_col
end

return M
