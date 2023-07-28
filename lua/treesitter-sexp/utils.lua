local M = {}

---@type fun(filetype?: string): Query|nil
function M.get_query(filetype)
  filetype = filetype or vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(filetype) or ""
  return vim.treesitter.query.get(lang, "sexp")
end

---@type fun(node: TSNode, query: Query): boolean
function M.is_valid_node(node, query)
  if query == nil then
    return false
  end

  for id, cnode in query:iter_captures(node, 0, 0, -1) do
    local name = query.captures[id]
    if name == "sexp.outer" and node:equal(cnode) then
      return true
    end
  end
  return false
end

---@type fun(node: TSNode, f: (fun(node: TSNode): TSNode|nil), count?: integer): TSNode | nil
function M.seek_node(node, f, count)
  count = count or 1
  local query = M.get_query()
  if query == nil then
    return node
  end

  local result = node
  local next_node
  for _ = 1, count do
    next_node = node
    repeat
      next_node = f(next_node)
    until next_node == nil or M.is_valid_node(next_node, query)

    if next_node ~= nil then
      result = next_node
    end
  end
  if not node:equal(result) then
    return result
  end
end

---@type fun(node: TSNode, count?: integer): TSNode | nil
function M.get_next_node(node, count)
  return M.seek_node(node, function(fnode)
    return fnode:next_sibling()
  end, count)
end

---@type fun(node: TSNode, count?: integer): TSNode|nil
function M.get_prev_node(node, count)
  return M.seek_node(node, function(fnode)
    return fnode:prev_sibling()
  end, count)
end

---@type fun(node: TSNode, count?: integer): TSNode|nil
function M.get_parent_node(node, count)
  return M.seek_node(node, function(fnode)
    return fnode:parent()
  end, count)
end

--- Relies on the ordering outputed by iter_matches
--- The ordering is undocumented behaviour, I hope it doesn't break
---@type fun(n: integer): TSSexp.Form|nil
function M.get_nth_form(n)
  local start = vim.fn.getpos "v"
  local end_ = vim.fn.getpos "."

  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()

  local query = M.get_query()
  if query == nil then
    return
  end

  local result
  local counter = 0
  for _, match in query:iter_matches(root, 0, 0, -1) do
    local is_form = false
    for id, cnode in pairs(match) do
      local name = query.captures[id]

      if
        name == "sexp.outer"
        and vim.treesitter.is_in_node_range(cnode, start[2] - 1, start[3] - 1)
        and vim.treesitter.is_in_node_range(cnode, end_[2] - 1, end_[3] - 1)
      then
        is_form = true
      end
    end

    if is_form then
      local next_result = {}
      for id, cnode in pairs(match) do
        local name = query.captures[id]
        if name == "sexp.outer" then
          next_result.outer = cnode
        elseif name == "sexp.open" then
          next_result.open = cnode
        elseif name == "sexp.close" then
          next_result.close = cnode
        end
      end
      result = next_result
      if n >= 0 and counter == n then
        return result
      end
      counter = counter + 1
    end
  end
  return result
end

---@type TSSexp.GetForm
function M.get_elem()
  return M.get_nth_form(0)
end

---@type TSSexp.GetForm
function M.get_form()
  return M.get_nth_form(1)
end

---@type TSSexp.GetForm
function M.get_form_node_count()
  return M.get_nth_form(vim.v.count1)
end

---@type TSSexp.GetForm
function M.get_top_level_form()
  return M.get_nth_form(-1)
end

---@type TSSexp.GetRange
function M.get_head_range(form)
  if form.open then
    local _, _, end_row, end_col = form.open:range()
    local start_row, start_col, _, _ = form.outer:range()
    return start_row, start_col, end_row, end_col
  else
    local row, col, _, _ = form.outer:range()
    return row, col, row, col
  end
end

---@type TSSexp.GetRange
function M.get_tail_range(form)
  if form.close then
    local start_row, start_col, _, _ = form.close:range()
    local _, _, end_row, end_col = form.outer:range()
    return start_row, start_col, end_row, end_col
  else
    local _, _, row, col = form.outer:range()
    return row, col, row, col
  end
end

---@type TSSexp.GetRange
function M.get_i_range(form)
  local _, _, start_row, start_col = M.get_head_range(form)
  local end_row, end_col, _, _ = M.get_tail_range(form)
  return start_row, start_col, end_row, end_col
end

---@type TSSexp.GetRange
function M.get_a_range(form)
  local start_row, start_col, end_row, end_col = form.outer:range()
  local last_line = vim.fn.line "$"
  if end_row >= last_line then
    end_row = last_line - 1
    end_col = vim.fn.col { last_line, "$" } - 1
  end
  return start_row, start_col, end_row, end_col
end

return M
