local M = {}

---@param opts? TSSexp.Config
function M.setup(opts)
  require("treesitter-sexp.config").setup(opts)

  local augroup = vim.api.nvim_create_augroup("NvimTreesitter-sexp", {})
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      local config = require "treesitter-sexp.config"
      if lang == nil or vim.tbl_isempty(config.options) then
        return
      end

      for key, lhs in pairs(config.options.operators.keymaps) do
        local operator = require("treesitter-sexp.operators")[key]
        if lhs and operator then
          vim.keymap.set("n", lhs, function()
            vim.go.operatorfunc = "v:lua.require'treesitter-sexp.operators'." .. key
            return "g@l"
          end, { expr = true, buffer = args.buf, desc = operator.desc })
        end
      end
      for key, lhs in pairs(config.options.textobjects.keymaps) do
        local textobject = require("treesitter-sexp.textobjects")[key]
        if lhs and textobject then
          vim.keymap.set({ "o", "x" }, lhs, function()
            textobject()
          end, { desc = textobject.desc, buffer = args.buf, silent = true })
        end
      end
      for key, lhs in pairs(config.options.textobjects.keymaps) do
        local motion = require("treesitter-sexp.motions")[key]
        if lhs and motion then
          vim.keymap.set({ "n", "o", "x" }, lhs, function()
            motion()
          end, { desc = motion.desc, buffer = args.buf, silent = true })
        end
      end
    end,
    group = augroup,
  })
end

return M
