--- @class TSSexpConfig
--- @field ignored_node_types table<string, string[]>
--- @field keymaps table<TSSexpOpName, string>
--- @field textobjects table<TSSexpTextObj, string>
local default_config = {
  ignored_node_types = {
    clojure = { "kwd_name", "sym_name", "sym_ns" },
    lua = { "string_content" },
  },
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
  textobjects = {
    elem = "e",
    form = "f",
    top_level = "F",
  },
}

--- @type TSSexpConfig
local M = default_config

return M
