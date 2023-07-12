local M = {}

local function set_config(opts)
  local config = require("treesitter-sexp.config")
  if opts ~= nil then
    for key, value in pairs(opts) do
      config[key] = vim.tbl_extend("keep", value, config[key])
    end
  end
end

--- @param opts? TSSexpConfig
function M.setup(opts)
  set_config(opts)
  require("treesitter-sexp.mappings").set()
end

return M
