local M = {}

function M.max_range_node(node)
  local parent = node:parent()

  while parent ~= nil and parent:child_count() == 1 do
    local next_parent = parent:parent()
    node = parent
    parent = next_parent
  end
  return node
end

function M.get_node()
  local node = vim.treesitter.get_node()
  if node == nil then
    vim.notify "Node not found"
    return
  else
    return M.max_range_node(node)
  end
end

function M.get_unnamed_start_range (node)
  local start_node = node:child(0)
  local start_range = {start_node:range()}

  local end_node = start_node
  local end_range
  repeat
    end_range = {end_node:range()}
    end_node = end_node:next_sibling()
  until end_node:named()

  return start_range[1], start_range[2], end_range[3], end_range[4]
end

function M.get_unnamed_end_range (node)
  local end_node = node:child(node:child_count() - 1)
  local end_range = {end_node:range()}

  local start_node = end_node
  local start_range
  repeat
    start_range = {start_node:range()}
    start_node = start_node:prev_sibling()
  until start_node:named()

  return start_range[1], start_range[2], end_range[3], end_range[4]
end

return M
