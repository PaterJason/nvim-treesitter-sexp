local M = {}

function M.setup(opts)
  require("treesitter-sexp.mappings").set()
end

return M
