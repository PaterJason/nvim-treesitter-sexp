local M = {}

---@type TSSexp.Config
M.defaults = {
  keymaps = {
    commands = {
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
    motions = {
      form_start = "(",
      form_end = ")",
      prev_elem = "[e",
      next_elem = "]e",
      prev_top_level = "[[",
      next_top_level = "]]",
    },
    textobjects = {
      inner_elem = "ie",
      outer_elem = "ae",
      inner_form = "if",
      outer_form = "af",
      inner_top_level = "iF",
      outer_top_level = "aF",
    },
  },
}

---@type TSSexp.Config
M.options = {}

---@param options? TSSexp.Config
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", M.defaults, options or {})
end

return M
