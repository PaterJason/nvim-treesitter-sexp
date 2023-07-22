local configs = require "nvim-treesitter.configs"

local M = {}

function M.attach(bufnr, lang)
  local config = configs.get_module "sexp"

  local operators = require "nvim-treesitter.sexp.operators"
  local textobjects = require "nvim-treesitter.sexp.textobjects"
  local motions = require "nvim-treesitter.sexp.motions"

  for key, lhs in pairs(config.keymaps) do
    if lhs then
      local operator = operators[key]
      local textobject = textobjects[key]
      local motion = motions[key]

      if operator then
        vim.keymap.set("n", lhs, function()
          vim.go.operatorfunc = "v:lua.require'nvim-treesitter.sexp.operators'." .. key
          return "g@l"
        end, { expr = true, desc = operator.desc, buffer = bufnr })
      elseif textobject then
        vim.keymap.set({ "o", "x" }, lhs, function()
          textobject()
        end, { desc = textobject.desc, buffer = bufnr, silent = true })
      elseif motion then
        vim.keymap.set({ "n", "o", "x" }, lhs, function()
          motion()
        end, { desc = motion.desc, buffer = bufnr, silent = true })
      end
    end
  end
end

function M.detach(bufnr, lang)
  local operators = require "nvim-treesitter.sexp.operators"
  local textobjects = require "nvim-treesitter.sexp.textobjects"
  local config = configs.get_module "sexp"

  for key, lhs in pairs(config.keymaps) do
    if lhs then
      local operator = operators[key]
      if operator then
        vim.keymap.del("n", lhs, { buffer = bufnr })
      end

      local textobject = textobjects[key]
      if textobject then
        vim.keymap.del({ "o", "x" }, lhs, { buffer = bufnr })
      end
    end
  end
end

return M
