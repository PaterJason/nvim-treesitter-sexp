local M = {}

---@type fun(filetype?: string): Query|nil
function M.get_query(filetype)
  filetype = filetype or vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(filetype) or ""
  return vim.treesitter.query.get(lang, "sexp")
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
      if name == "sexp.outer" then
        result.outer = cnode
      elseif name == "sexp.open" then
        result.open = cnode
      elseif name == "sexp.close" then
        result.close = cnode
      end
    end
    if result.outer ~= nil and pred(result) then
      forms[#forms + 1] = result
    end
  end
  table.sort(forms, comp)

  return forms
end

---@type TSSexp.PredForm
function M.is_in_range(form)
  local start = vim.fn.getpos "v"
  local end_ = vim.fn.getpos "."
  return vim.treesitter.is_in_node_range(form.outer, start[2] - 1, start[3] - 1)
    and vim.treesitter.is_in_node_range(form.outer, end_[2] - 1, end_[3] - 1)
end

---@type fun(node1: TSNode, node1: TSNode): boolean
function M.is_sibling(node1, node2)
  local parent1 = node1:parent()
  local parent2 = node2:parent()
  return parent1:equal(parent2)
end

---@type fun(node1: TSNode, node2: TSNode): boolean
function M.comp_node_start_range(node1, node2)
  local row1, col1 = node1:range()
  local row2, col2 = node2:range()
  return row1 < row2 or (row1 == row2 and col1 < col2)
end

---@type TSSexp.CompForms
function M.comp_form_start_range(form1, form2)
  local row1, col1 = form1.outer:range()
  local row2, col2 = form2.outer:range()
  return row1 < row2 or (row1 == row2 and col1 < col2)
end

---@type TSSexp.CompForms
function M.comp_form_ancestor(form1, form2)
  return vim.treesitter.is_ancestor(form2.outer, form1.outer)
end

---@type fun(node: TSNode, count?: integer): TSSexp.Form | nil
function M.get_next_form(node, count)
  local parent = node:parent()
  local forms = M.get_valid_forms(function(pred_form)
    return parent:equal(pred_form.outer:parent()) and M.comp_node_start_range(node, pred_form.outer)
  end, M.comp_form_start_range)
  return forms[count or 1]
end

---@type fun(node: TSNode, count?: integer): TSSexp.Form | nil
function M.get_prev_form(node, count)
  local parent = node:parent()
  local forms = M.get_valid_forms(function(pred_form)
    return parent:equal(pred_form.outer:parent()) and M.comp_node_start_range(pred_form.outer, node)
  end, function(form1, form2)
    return M.comp_form_start_range(form2, form1)
  end)
  return forms[count or 1]
end

---@type fun(node: TSNode, count?: integer): TSSexp.Form | nil
function M.get_parent_form(node, count)
  local forms = M.get_valid_forms(function(pred_form)
    return vim.treesitter.is_ancestor(pred_form.outer, node) and not node:equal(pred_form.outer)
  end, M.comp_form_ancestor)
  return forms[count or 1]
end

---@type TSSexp.GetForm
function M.get_elem()
  local forms = M.get_valid_forms(M.is_in_range, M.comp_form_ancestor)
  return forms[1]
end

---@type TSSexp.GetForm
function M.get_form()
  local forms = M.get_valid_forms(M.is_in_range, M.comp_form_ancestor)
  return forms[2]
end

---@type TSSexp.GetForm
function M.get_form_count()
  local forms = M.get_valid_forms(M.is_in_range, M.comp_form_ancestor)
  return forms[vim.v.count1 + 1]
end

---@type TSSexp.GetForm
function M.get_top_level_form()
  local forms = M.get_valid_forms(M.is_in_range, M.comp_form_ancestor)
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

---@type TSSexp.GetFormRange
function M.get_i_range(form)
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

---@type TSSexp.GetFormRange
function M.get_a_range(form)
  local start_row, start_col, end_row, end_col = form.outer:range()
  return start_row, start_col, end_row, end_col
end

return M
