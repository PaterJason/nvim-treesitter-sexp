local config = require "treesitter-sexp.config"

local M = {}

function M.set()
  -- Operators
  local operators = require "treesitter-sexp.operators"
  for key, lhs in pairs(config.keymaps) do
    local operator = operators[key]
    if lhs and operator then
      vim.keymap.set("n", lhs, function()
          vim.go.operatorfunc = "v:lua.require'treesitter-sexp.operators'." .. key .. ".func"
          return "g@l"
      end, {
        expr = true,
        desc = operator.desc,
      })
    end
  end

  -- Text objects
  local textobjects = require "treesitter-sexp.textobjects"
  for key, char in pairs(config.textobjects) do
    local textobject = textobjects[key]
    if char and textobject then
      for _, ai in ipairs { "a", "i" } do
        vim.keymap.set(
          { "o", "x" },
          ai .. char,
          ":<C-U> lua require'treesitter-sexp.textobjects'." .. key .. "." .. ai .. ".textobj()<CR>",
          { desc = textobjects[key][ai].desc, silent = true }
        )
      end
    end
  end
end

return M
