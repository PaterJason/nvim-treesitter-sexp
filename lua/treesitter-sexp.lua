local M = {}

---@param opts? TSSexp.Config
function M.setup(opts)
  require("treesitter-sexp.config").setup(opts)

  local augroup = vim.api.nvim_create_augroup("NvimTreesitter-sexp", {})
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local bufnr = args.buf
      local filetype = args.match

      local lang = vim.treesitter.language.get_lang(filetype)
      local config = require "treesitter-sexp.config"
      if lang == nil or vim.tbl_isempty(config.options) then
        return
      end

      local commands = require "treesitter-sexp.commands"
      for key, lhs in pairs(config.options.commands.keymaps) do
        local command = commands[key]
        if lhs and command then
          vim.keymap.set("n", lhs, function()
            vim.go.operatorfunc = "v:lua.require'treesitter-sexp.commands'." .. key
            return "g@l"
          end, { expr = true, buffer = bufnr, desc = command.desc })
        end
      end
      vim.api.nvim_buf_create_user_command(bufnr, "TSSexp", function(info)
        local command = require "treesitter-sexp.commands"[info.args]
        if command then
          command()
        end
      end, {
        nargs = 1,
        complete = function()
          return vim.tbl_keys(commands)
        end,
      })

      for key, lhs in pairs(config.options.textobjects.keymaps) do
        local textobject = require("treesitter-sexp.textobjects")[key]
        if lhs and textobject then
          vim.keymap.set({ "o", "x" }, lhs, function()
            textobject()
          end, { desc = textobject.desc, buffer = bufnr, silent = true })
        end
      end
      for key, lhs in pairs(config.options.motions.keymaps) do
        local motion = require("treesitter-sexp.motions")[key]
        if lhs and motion then
          vim.keymap.set({ "n", "o", "x" }, lhs, function()
            motion()
          end, { desc = motion.desc, buffer = bufnr, silent = true })
        end
      end
    end,
    group = augroup,
  })
end

return M
