--- @class TSSexpConfig
--- @field ignored_node_types table<string, string[]>
--- @field keymaps table<TSSexpOpName, string>
--- @field textobjects table<TSSexpTextObj, string>

local ts_sexp_config = {}

--- Select parent node when it is one of these types
---@type table<string, string[]>
ts_sexp_config.take_parent_node_types = {
  clojure = { "kwd_lit", "sym_lit" },
  javascript = { "member_expression" },
  json = { "string" },
  lua = { "string" },
  rust = { "field_expression" },
  typescript = { "string" },
  fennel = { "multi_symbol", "string" },
}

--- Operator keymaps
---@type table<string, string|false>
ts_sexp_config.keymaps = {
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
}

--- Textobject keymaps
---@type table<string, string|false>
ts_sexp_config.textobjects = {
  --- Element
  elem = "e",
  --- Form
  form = "f",
  --- Top level form
  top_level = "F",
}

return ts_sexp_config
