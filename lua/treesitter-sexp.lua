local ts_sexp = {}

local function set_config(opts)
  local config = require "treesitter-sexp.config"
  if opts ~= nil then
    for key, value in pairs(opts) do
      config[key] = vim.tbl_extend("keep", value, config[key])
    end
  end
end

--- Setup function to be run by user. Configures the defaults
---@param opts table|nil Configuration options
function ts_sexp.setup(opts)
  set_config(opts)
  require("treesitter-sexp.mappings").set()
end

return ts_sexp
