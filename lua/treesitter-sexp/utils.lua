local config = require "treesitter-sexp.config"

local M = {}

---@param filetype? string
---@return Query|nil
function M.get_query(filetype)
  filetype = filetype or vim.bo.filetype
  local lang = vim.treesitter.language.get_lang(filetype) or ""
  local _, query = pcall(vim.treesitter.query.get, lang, "sexp")
  if query then
    return query
  end
end

---@param pred TSSexp.PredNode
---@param comp TSSexp.CompNode
---@param capture_names TSSexp.Capture[]
---@param opts? TSSexp.GetNodeOpts
---@return TSNode[]
function M.get_valid_nodes(pred, comp, capture_names, opts)
  opts = opts or {}
  local node = opts.node or vim.treesitter.get_parser():parse()[1]:root()
  local start, stop
  if opts.cursor then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    start = cursor_pos[1] - 1
    stop = cursor_pos[1]
  end

  local query = M.get_query()
  if query == nil then
    return {}
  end

  local nodes = {}
  for id, cnode in query:iter_captures(node, 0, start, stop) do
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

---@param pred TSSexp.PredForm
---@param comp TSSexp.CompForms
---@return TSSexp.Form[]
function M.get_valid_forms(pred, comp)
  local parser = vim.treesitter.get_parser()
  local root = parser:parse()[1]:root()

  local query = M.get_query()
  if query == nil then
    return {}
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local forms = {}
  for _, match in query:iter_matches(root, 0, cursor_pos[1] - 1, cursor_pos[1]) do
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

---@type TSSexp.CompNode
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

---@param node TSNode
---@param capture_names TSSexp.Capture[]
---@return TSNode[]
function M.get_next_nodes(node, capture_names)
  local parent = node:parent()
  local nodes = M.get_valid_nodes(
    function(pred_node)
      return parent:equal(pred_node:parent()) and M.comp_node_start_range(node, pred_node)
    end,
    M.comp_node_start_range,
    capture_names,
    {
      node = parent,
    }
  )
  return nodes
end

---@param node TSNode
---@param capture_names TSSexp.Capture[]
---@param count? integer
---@return TSNode|nil
function M.get_next(node, capture_names, count)
  local nodes = M.get_next_nodes(node, capture_names)
  return nodes[count or 1] or nodes[#nodes]
end

---@param node TSNode
---@param capture_names TSSexp.Capture[]
---@return TSNode[]
function M.get_prev_nodes(node, capture_names)
  local parent = node:parent()
  local nodes = M.get_valid_nodes(
    function(pred_node)
      return parent:equal(pred_node:parent()) and M.comp_node_start_range(pred_node, node)
    end,
    function(node1, node2)
      return M.comp_node_start_range(node2, node1)
    end,
    capture_names,
    {
      node = parent,
    }
  )
  return nodes
end

---@param node TSNode
---@param capture_names TSSexp.Capture[]
---@param count? integer
---@return TSNode|nil
function M.get_prev(node, capture_names, count)
  local nodes = M.get_prev_nodes(node, capture_names)
  return nodes[count or 1] or nodes[#nodes]
end

---@return TSNode|nil
function M.get_elem()
  local elems = M.get_valid_nodes(M.is_in_node_range, M.comp_node_ancestor, { "sexp.elem" }, { cursor = true })
  return elems[1]
end

---@return TSSexp.Form[]
function M.get_forms()
  return M.get_valid_forms(M.is_in_form_range, M.comp_form_ancestor)
end

---@return TSSexp.Form|nil
function M.get_form()
  local forms = M.get_forms()
  return forms[1]
end

---@param node TSNode
---@return TSSexp.Form[]
function M.get_parent_forms(node)
  local forms = M.get_valid_forms(function(form)
    return vim.treesitter.is_ancestor(form.outer, node) and not node:equal(form.outer)
  end, M.comp_form_ancestor)
  return forms
end

---@return TSSexp.Form|nil
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

---@param pos integer[]
---@return integer[]
function M.pos_to_range(pos)
  return { pos[1], pos[2], pos[1], pos[2] }
end

---@param range integer[]
---@return string[]
local function get_buf_text(range)
  return vim.api.nvim_buf_get_text(0, range[1], range[2], range[3], range[4], {})
end

---@param range integer[]
---@param replacement string[]
local function set_buf_text(range, replacement)
  vim.api.nvim_buf_set_text(0, range[1], range[2], range[3], range[4], replacement)
end

--- Set cursor by range offset by pos
---@param range integer[]
---@param target_pos integer[] (0,0) indexed
---@param pos integer[] (0,1) indexed
local function set_cursor_basic(range, target_pos, pos)
  if not config.options.set_cursor then
    return
  end
  local row = target_pos[1] + (pos[1] - range[1])
  local col
  if row == target_pos[1] + 1 then
    col = target_pos[2] + (pos[2] - range[2])
  else
    col = pos[2]
  end
  vim.api.nvim_win_set_cursor(0, { row, col })
end

--- Set cursor for range swaps
---@param range1 integer[]
---@param range2 integer[]
---@param pos integer[] (1,0) indexed
local function set_cursor_swap(range1, range2, pos)
  if not config.options.set_cursor then
    return
  end
  local row_delta = 0
  local col_delta = 0

  local text1 = get_buf_text(range1)
  local text2 = get_buf_text(range2)

  if range1[3] < range2[1] or (range1[3] == range2[1] and range1[4] < range2[2]) then
    row_delta = #text2 - #text1
  end

  if range1[3] == range2[1] and range1[4] <= range2[2] then
    if row_delta ~= 0 then
      col_delta = #text2[#text2] - range1[4]
      if range1[1] == range2[1] + row_delta then
        col_delta = col_delta + range1[2]
      end
    else
      col_delta = #text2[#text2] - #text1[#text1]
    end
  end

  set_cursor_basic(range1, { range2[1] + row_delta, range2[2] + col_delta }, pos)
end

---@param range1 integer[]
---@param range2 integer[]
---@return nil
function M.promote_range(range1, range2)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local replacement = get_buf_text(range1)
  set_buf_text(range2, replacement)
  set_cursor_basic(range1, range2, cursor_pos)
end

---@param range integer[]
---@param target_pos integer[] (0,0) indexed
---@param pos integer[] (1,0) indexed
---@return nil
function M.move_range(range, target_pos, pos)
  local text = get_buf_text(range)
  local target_range = M.pos_to_range(target_pos)
  if target_pos[1] < range[1] or (target_pos[1] == range[1] and target_pos[2] < range[2]) then
    set_buf_text(range, {})
    set_buf_text(target_range, text)
  else
    set_buf_text(target_range, text)
    set_buf_text(range, {})
  end
  set_cursor_swap(range, target_range, pos)
end

---@param range1 integer[]
---@param range2 integer[]
---@return nil
function M.swap_ranges(range1, range2)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local text1 = get_buf_text(range1)
  local text2 = get_buf_text(range2)

  if range2[1] < range1[1] or (range2[1] == range1[1] and range2[2] < range1[2]) then
    set_buf_text(range1, text2)
    set_buf_text(range2, text1)
  else
    set_buf_text(range2, text1)
    set_buf_text(range1, text2)
  end

  set_cursor_swap(range1, range2, cursor_pos)
end

return M
