---@meta

---@class TSSexp.Form
---@field outer TSNode
---@field open? TSNode
---@field close? TSNode

--- Get node around cursor
---@alias TSSexp.GetNode fun(): TSNode|nil
--- Get form around cursor
---@alias TSSexp.GetForm fun(): TSSexp.Form|nil
--- Get range from form
---@alias TSSexp.GetFormRange fun(node: TSSexp.Form): integer, integer, integer, integer
--- Get position from form
---@alias TSSexp.GetFormPos fun(node: TSSexp.Form): integer, integer

--- Node predicate
---@alias TSSexp.PredForm fun(form1: TSSexp.Form): boolean
--- Compare forms
---@alias TSSexp.CompForms fun(form1: TSSexp.Form, form2: TSSexp.Form): boolean

--- Action to apply to treesitter node
---@alias TSSexp.Action fun(form: TSSexp.Form): nil

---@class TSSexp.Command
---@field desc string Description
---@field action TSSexp.Action
---@field get_form TSSexp.GetForm
---@overload fun(): nil

---@class TSSexp.Textobject
---@field desc string Description
---@field get_form TSSexp.GetForm
---@field get_range TSSexp.GetFormRange
---@overload fun(): nil

---@class TSSexp.Motion
---@field desc string Description
---@field get_form TSSexp.GetForm
---@field get_pos TSSexp.GetFormPos
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
