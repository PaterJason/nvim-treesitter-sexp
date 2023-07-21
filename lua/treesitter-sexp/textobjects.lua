local ts_utils = require "nvim-treesitter.ts_utils"
local utils = require "treesitter-sexp.utils"

---@alias TSSexpTextObj
--- | "elem"
--- | "form"
--- | "top_level"

---@type {name: TSSexpTextObj, ai: "a"|"i", desc: string, get_node: TSSexpGetNode}[]
local textobjects = {
  {
    name = "elem",
    ai = "a",
    desc = "An element",
    get_node = utils.get_elem_node,
  },
  {
    name = "elem",
    ai = "i",
    desc = "Inner element",
    get_node = utils.get_elem_node,
  },
  {
    name = "form",
    ai = "a",
    desc = "A form",
    get_node = utils.get_form_node,
  },
  {
    name = "form",
    ai = "i",
    desc = "Inner form",
    get_node = utils.get_form_node,
  },
  {
    name = "top_level",
    ai = "a",
    desc = "A top level form",
    get_node = utils.get_top_level_node,
  },
  {
    name = "top_level",
    ai = "i",
    desc = "Inner top level form",
    get_node = utils.get_top_level_node,
  },
}

---@type table<TSSexpTextObj, table<"a"|"i", {desc: string, textobj: fun()}>>
local M = {}
for _, textobject in ipairs(textobjects) do
  if M[textobject.name] == nil then
    M[textobject.name] = {}
  end
  M[textobject.name][textobject.ai] = {
    desc = textobject.desc,
  }
  setmetatable(M[textobject.name][textobject.ai], {
    __call = function()
      local node = textobject.get_node()
      if node == nil then
        vim.notify "Node not found"
        return
      end
      if textobject.ai == "i" then
        ts_utils.update_selection(0, { utils.get_i_range(node) }, "v")
      elseif textobject.ai == "a" then
        ts_utils.update_selection(0, { utils.get_a_range(node) }, "v")
      end
    end,
  })
end
return M
