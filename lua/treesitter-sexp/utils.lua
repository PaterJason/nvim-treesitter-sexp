local options = require("treesitter-sexp.config").options

local M = {}

---@type fun(node: TSNode): TSNode
function M.get_valid_node(node)
  local parent = node:parent()
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  local parent_node_overrides = options.parent_node_overrides[lang] or {}
  while parent ~= nil and vim.tbl_contains(parent_node_overrides, parent:type()) do
    node = parent
    parent = parent:parent()
  end
  return node
end

---@type fun(node: TSNode): TSNode
function M.get_range_max_node(node)
  local parent = node:parent()

  while parent ~= nil and parent:child_count() == 1 do
    local next_parent = parent:parent()
    node = parent
    parent = next_parent
  end
  return node
end

---@type fun(node: TSNode): TSNode|nil
function M.get_larger_parent(node)
  return M.get_range_max_node(node):parent()
end

---@type fun(node: TSNode): TSNode
function M.get_next_node_count(node)
  local next_node
  for _ = 1, vim.v.count1 do
    next_node = node:next_named_sibling()
    if next_node == nil then
      return node
    else
      node = next_node
    end
  end
  return node
end

---@type fun(node: TSNode): TSNode
function M.get_prev_node_count(node)
  local prev_node
  for _ = 1, vim.v.count1 do
    prev_node = node:prev_named_sibling()
    if prev_node == nil then
      return node
    else
      node = prev_node
    end
  end
  return node
end

---@type fun(node: TSNode): TSNode
function M.get_parent_node_count(node)
  for _ = 1, vim.v.count1 do
    local parent_node = M.get_larger_parent(node)
    if parent_node == nil then
      return node
    end
    node = parent_node
  end
  return node
end

---@type TSSexp.GetNode
function M.get_elem_node()
  local start = vim.fn.getpos "v"
  local end_ = vim.fn.getpos "."
  local parser = vim.treesitter.get_parser()
  local node = parser:named_node_for_range { start[2] - 1, start[3] - 1, end_[2] - 1, end_[3] - 1 }
  if node ~= nil then
    return M.get_valid_node(node)
  end
end

---@type TSSexp.GetNode
function M.get_form_node()
  local node = M.get_elem_node()
  if node ~= nil then
    return M.get_larger_parent(node)
  end
end

---@type TSSexp.GetNode
function M.get_form_node_count()
  local node = M.get_elem_node()
  if node ~= nil then
    return M.get_parent_node_count(node)
  end
end

---@type TSSexp.GetNode
function M.get_top_level_node()
  local start = vim.fn.getpos "v"
  local end_ = vim.fn.getpos "."
  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()
  for child_node, _ in root:iter_children() do
    if
      child_node:named()
      and vim.treesitter.is_in_node_range(child_node, start[2] - 1, start[3] - 1)
      and vim.treesitter.is_in_node_range(child_node, end_[2] - 1, end_[3] - 1)
    then
      return child_node
    end
  end
end

---@type TSSexp.GetRange
function M.get_unnamed_start_range(node)
  local end_row, end_col
  local start_row, start_col, _, _ = node:range()

  local named_child_count = node:named_child_count()
  if named_child_count == 0 then
    local child_count = node:child_count()
    if child_count == 0 then
      end_row, end_col = start_row, start_col
    else
      _, _, end_row, end_col = node:child(0):range()
    end
  else
    end_row, end_col, _, _ = node:named_child(0):range()
  end
  return start_row, start_col, end_row, end_col
end

---@type TSSexp.GetRange
function M.get_unnamed_end_range(node)
  local start_row, start_col
  local _, _, end_row, end_col = node:range()

  local named_child_count = node:named_child_count()
  if named_child_count == 0 then
    local child_count = node:child_count()
    if child_count == 0 then
      start_row, start_col = end_row, end_col
    else
      start_row, start_col, _, _ = node:child(child_count - 1):range()
    end
  else
    _, _, start_row, start_col = node:named_child(named_child_count - 1):range()
  end
  return start_row, start_col, end_row, end_col
end

---@type TSSexp.GetRange
function M.get_i_range(node)
  local _, _, start_row, start_col = M.get_unnamed_start_range(node)
  local end_row, end_col, _, _ = M.get_unnamed_end_range(node)
  return start_row, start_col, end_row, end_col
end

---@type TSSexp.GetRange
function M.get_a_range(node)
  local start_row, start_col, end_row, end_col = node:range()
  local last_line = vim.fn.line "$"
  if end_row >= last_line then
    end_row = last_line - 1
    end_col = vim.fn.col { last_line, "$" } - 1
  end
  return start_row, start_col, end_row, end_col
end

return M
