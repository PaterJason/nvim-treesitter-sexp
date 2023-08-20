local M = {}

---@type fun(filetype?: string): Query|nil
function M.get_query(filetype)
  filetype = filetype or vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(filetype) or ""
  return vim.treesitter.query.get(lang, "sexp")
end

---@type fun(pred: TSSexp.PredNode, capture_names: string[], comp: TSSexp.CompNode): TSNode[]
function M.get_valid_nodes(pred, capture_names, comp)
  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()

  local query = M.get_query()
  if query == nil then
    return {}
  end

  local nodes = {}
  for id, cnode in query:iter_captures(root, 0, 0, -1) do
    local name = query.captures[id]
    if
      vim.tbl_contains(capture_names, name)
      and (vim.tbl_isempty(nodes) or not cnode:equal(nodes[#nodes]))
      and pred(cnode)
    then
      nodes[#nodes + 1] = cnode
    end
  end
  table.sort(nodes, comp)

  return nodes
end

---@type fun(pred: TSSexp.PredForm, comp: TSSexp.CompForms): TSSexp.Form[]
function M.get_valid_forms(pred, comp)
  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()

  local query = M.get_query()
  if query == nil then
    return {}
  end

  local forms = {}
  for _, match in query:iter_matches(root, 0, 0, -1) do
    local result = {}
    for id, cnode in pairs(match) do
      local name = query.captures[id]
      if name == "sexp.form" then
        result.outer = cnode
      elseif name == "sexp.open" then
        result.open = cnode
      elseif name == "sexp.close" then
        result.close = cnode
      end
    end
    if
      result.outer ~= nil
      and (vim.tbl_isempty(forms) or not result.outer:equal(forms[#forms].outer))
      and pred(result)
    then
      forms[#forms + 1] = result
    end
  end
  table.sort(forms, comp)

  return forms
end

---@type TSSexp.PredNode
function M.is_in_node_range(node)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  return vim.treesitter.is_in_node_range(node, cursor_pos[1] - 1, cursor_pos[2])
end

---@type TSSexp.PredForm
function M.is_in_form_range(form)
  return M.is_in_node_range(form.outer)
end

---@type fun(node1: TSNode, node2: TSNode): boolean
function M.comp_node_start_range(node1, node2)
  local row1, col1 = node1:range()
  local row2, col2 = node2:range()
  return row1 < row2 or (row1 == row2 and col1 < col2)
end

---@type TSSexp.CompNode
function M.comp_node_ancestor(node1, node2)
  return vim.treesitter.is_ancestor(node2, node1)
end

---@type TSSexp.CompForms
function M.comp_form_ancestor(form1, form2)
  return vim.treesitter.is_ancestor(form2.outer, form1.outer)
end

---@type fun(node: TSNode, capture_names: TSSexp.Capture[], count?: integer): TSNode | nil
function M.get_next(node, capture_names, count)
  local parent = node:parent()
  local nodes = M.get_valid_nodes(function(pred_node)
    return parent:equal(pred_node:parent()) and M.comp_node_start_range(node, pred_node)
  end, capture_names, M.comp_node_start_range)
  return nodes[count or 1] or nodes[#nodes]
end

---@type fun(node: TSNode, capture_names: TSSexp.Capture[], count?: integer): TSNode | nil
function M.get_prev(node, capture_names, count)
  local parent = node:parent()
  local nodes = M.get_valid_nodes(
    function(pred_node)
      return parent:equal(pred_node:parent()) and M.comp_node_start_range(pred_node, node)
    end,
    capture_names,
    function(node1, node2)
      return M.comp_node_start_range(node2, node1)
    end
  )
  return nodes[count or 1] or nodes[#nodes]
end

---@type fun(): TSNode|nil
function M.get_elem()
  local elems = M.get_valid_nodes(M.is_in_node_range, { "sexp.elem" }, M.comp_node_ancestor)
  return elems[1]
end

---@type fun(): TSSexp.Form[]
function M.get_forms()
  return M.get_valid_forms(M.is_in_form_range, M.comp_form_ancestor)
end

---@type fun(): TSSexp.Form|nil
function M.get_form()
  local forms = M.get_forms()
  return forms[1]
end

---@type fun(TSNode): TSSexp.Form|nil
function M.get_parent_form(node)
  local forms = M.get_valid_forms(function(form)
    return vim.treesitter.is_ancestor(form.outer, node) and not node:equal(form.outer)
  end, M.comp_form_ancestor)
  return forms[1]
end

---@type fun(): TSSexp.Form|nil
function M.get_top_level_form()
  local forms = M.get_forms()
  return forms[#forms]
end

---@type TSSexp.GetFormRange
function M.get_head_range(form)
  if form.open then
    local next_node = form.open:next_named_sibling()
    local end_row, end_col, _
    if next_node ~= nil then
      end_row, end_col, _, _ = next_node:range()
    elseif form.close ~= nil then
      end_row, end_col, _, _ = form.close:range()
    else
      _, _, end_row, end_col = form.open:range()
    end
    local start_row, start_col, _, _ = form.outer:range()
    return start_row, start_col, end_row, end_col
  else
    local row, col, _, _ = form.outer:range()
    return row, col, row, col
  end
end

---@type TSSexp.GetFormRange
function M.get_tail_range(form)
  if form.close then
    local prev_node = form.close:prev_named_sibling()
    local start_row, start_col, _
    if prev_node ~= nil then
      _, _, start_row, start_col = prev_node:range()
    elseif form.open then
      _, _, start_row, start_col = form.open:range()
    else
      start_row, start_col, _, _ = form.close:range()
    end
    local _, _, end_row, end_col = form.outer:range()
    return start_row, start_col, end_row, end_col
  else
    local _, _, row, col = form.outer:range()
    return row, col, row, col
  end
end

---@type TSSexp.GetNodeRange
function M.get_a_elem_range(elem)
  local start_row, start_col, end_row, end_col = elem:range()
  local next_node = M.get_next(elem, { "sexp.elem", "sexp.close" })
  local next_row, next_col = end_row, end_col
  local _
  if next_node ~= nil then
    end_row, end_col, _, _ = next_node:range()
  end
  if end_row == next_row and end_col == next_col then
    local prev_node = M.get_prev(elem, { "sexp.elem", "sexp.open" })
    if prev_node ~= nil then
      _, _, start_row, start_col = prev_node:range()
    end
  end
  return start_row, start_col, end_row, end_col
end

---@type TSSexp.GetFormRange
function M.get_i_form_range(form)
  local start_row, start_col, end_row, end_col = form.outer:range()
  local _
  if form.open then
    _, _, start_row, start_col = form.open:range()
  end
  if form.close then
    end_row, end_col, _, _ = form.close:range()
  end
  return start_row, start_col, end_row, end_col
end

function M.promote(range1, range2)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local replacement = vim.api.nvim_buf_get_text(0, range1[1], range1[2], range1[3], range1[4], {})
  vim.api.nvim_buf_set_text(0, range2[1], range2[2], range2[3], range2[4], replacement)
  local row = range2[1] + (cursor_pos[1] - range1[1])
  local col
  if row == range2[1] + 1 then
    col = range2[2] + (cursor_pos[2] - range1[2])
  else
    col = cursor_pos[2]
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
end

return M
