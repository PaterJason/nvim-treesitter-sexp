---@type TSSexp.Config
local defaults = {
  commands = {
    keymaps = {
      swap_prev_elem = "<e",
      swap_next_elem = ">e",
      swap_prev_form = "<f",
      swap_next_form = ">f",
      promote_elem = "<LocalLeader>O",
      promote_form = "<LocalLeader>o",
      splice = "<LocalLeader>@",
      slurp_left = "<(",
      slurp_right = ">)",
      barf_left = ">(",
      barf_right = "<)",
    },
  },
  motions = {
    keymaps = {
      form_start = "(",
      form_end = ")",
      prev_elem = "[e",
      next_elem = "]e",
      prev_top_level = "[[",
      next_top_level = "]]",
    },
  },
  textobjects = {
    keymaps = {
      inner_elem = "ie",
      inner_form = "if",
      inner_top_level = "iF",
      outer_elem = "ae",
      outer_form = "af",
      outer_top_level = "aF",
    },
  },
  parent_node_overrides = {
    clojure = { "kwd_lit", "sym_lit" },
    javascript = { "member_expression" },
    json = { "string" },
    lua = { "string" },
    rust = { "field_expression" },
    typescript = { "string" },
    fennel = { "multi_symbol", "string" },
  },
}

local M = {}

---@type TSSexp.Config
M.options = {}

---@param options? TSSexp.Config
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", defaults, options or {})
end

return M
