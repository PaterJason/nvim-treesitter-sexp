local M = {}

--- @param opts? TSSexpConfig
function M.setup(opts)
  require("treesitter-sexp.mappings").set()
end

return M
