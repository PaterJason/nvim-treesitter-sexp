local utils = require "treesitter-sexp.utils"

local M = {}

---@param opts? TSSexp.Config
function M.setup(opts)
  require("treesitter-sexp.config").setup(opts)

  local augroup = vim.api.nvim_create_augroup("NvimTreesitter-sexp", {})
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local bufnr = args.buf
      local filetype = args.match

      local config = require "treesitter-sexp.config"

      local query = utils.get_query(filetype)
      if query == nil then
        return
      end

      local commands = require "treesitter-sexp.commands"
      local textobjects = require "treesitter-sexp.textobjects"
      local motions = require "treesitter-sexp.motions"

      local keymaps = config.options.keymaps
      if keymaps then
        for key, lhs in pairs(keymaps.commands) do
          local command = commands[key]
          if lhs and command then
            vim.keymap.set("n", lhs, function()
              vim.go.operatorfunc = "v:lua.require'treesitter-sexp.commands'." .. key
              vim.api.nvim_feedkeys("g@l", "n", false)
            end, { buffer = bufnr, desc = command.desc })
          end
        end
        for key, lhs in pairs(keymaps.textobjects) do
          local textobject = textobjects[key]
          if lhs and textobject then
            vim.keymap.set({ "o", "x" }, lhs, function()
              textobject()
            end, { desc = textobject.desc, buffer = bufnr, silent = true })
          end
        end
        for key, lhs in pairs(keymaps.motions) do
          local motion = motions[key]
          if lhs and motion then
            vim.keymap.set({ "n", "o", "x" }, lhs, function()
              motion()
            end, { desc = motion.desc, buffer = bufnr, silent = true })
          end
        end
      end

      vim.api.nvim_buf_create_user_command(bufnr, "TSSexp", function(info)
        local command = commands[info.args]
        if command then
          command()
        end
      end, {
        desc = "Run treesitter sexp command",
        nargs = 1,
        complete = function()
          return vim.tbl_keys(commands)
        end,
      })
    end,
    group = augroup,
  })
end

return M
