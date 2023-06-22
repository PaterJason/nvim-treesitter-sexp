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
    promote_form = "<LocalLeader>o",
    promote_elem = "<LocalLeader>O",
    splice = "<LocalLeader>@",

    slurp_left = "<(",
    slurp_right = ">)",
    barf_left = ">(",
    barf_right = "<)"
  },
  textobjects = {
    elem = "e",
    form = "f",
  }
}

local M = default_config

return M
