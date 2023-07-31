---@meta

---@class TSSexp.Form
---@field outer TSNode
---@field open? TSNode
---@field close? TSNode

---@alias TSSexp.Capture
---| "sexp.elem"
---| "sexp.form"
---| "sexp.open"
---| "sexp.close"

--- Get range from element
---@alias TSSexp.GetElemRange fun(elem: TSNode): integer, integer, integer, integer
--- Get range from form
---@alias TSSexp.GetFormRange fun(form: TSSexp.Form): integer, integer, integer, integer

--- Element predicate
---@alias TSSexp.PredElem fun(node: TSNode): boolean
--- Compare Elements
---@alias TSSexp.CompElem fun(node1: TSNode, node2: TSNode): boolean

--- Form predicate
---@alias TSSexp.PredForm fun(form1: TSSexp.Form): boolean
--- Compare forms
---@alias TSSexp.CompForms fun(form1: TSSexp.Form, form2: TSSexp.Form): boolean

---@class TSSexp.Command
---@field desc string Description
---@field call fun(): nil
---@overload fun(): nil

---@class TSSexp.Textobject
---@field desc string Description
---@field get_range fun(): integer[]|nil
---@overload fun(): nil

---@class TSSexp.Motion
---@field desc string Description
---@field get_pos fun(): integer[]|nil
---@overload fun(): nil

--- Configuration table
---@class TSSexp.Config
--- Key mappings, set entry to disable
---@field keymaps? TSSexp.Keymaps|false

--- Key mappings, set entry to false to disable
---@alias TSSexp.Keymaps.Keys table<string, string|false>

---@class TSSexp.Keymaps
--- Command keymaps
---@field commands? TSSexp.Keymaps.Keys
--- Motion keymaps
---@field motions? TSSexp.Keymaps.Keys
--- Text object keymaps
---@field textobjects? TSSexp.Keymaps.Keys

---@alias TSSexp.Config.ParentNodeOverrides table<string, string[]>
