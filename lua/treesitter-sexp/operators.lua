local actions = require "treesitter-sexp.actions"
local utils = require "treesitter-sexp.utils"

local M = {}

function M.swap_prev_elem()
  actions.swap_prev(utils.get_elem_node())
end

function M.swap_next_elem()
  actions.swap_next(utils.get_elem_node())
end

function M.swap_prev_form()
  actions.swap_prev(utils.get_form_node())
end

function M.swap_next_form()
  actions.swap_next(utils.get_form_node())
end

function M.promote_elem()
  actions.promote(utils.get_elem_node())
end

function M.promote_form()
  actions.promote(utils.get_form_node())
end

function M.splice()
  actions.splice(utils.get_elem_node())
end

function M.slurp_left()
  actions.slurp_left(utils.get_elem_node())
end

function M.slurp_right()
  actions.slurp_right(utils.get_elem_node())
end

function M.barf_left()
  actions.barf_left(utils.get_elem_node())
end

function M.barf_right()
  actions.barf_right(utils.get_elem_node())
end

return M
