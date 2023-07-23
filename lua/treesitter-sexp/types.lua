--- Get node around cursor
---@alias TSSexp.GetNode fun(): TSNode|nil
--- Get range from treesitter node
---@alias TSSexp.GetRange fun(node: TSNode): integer, integer, integer, integer

--- Action to apply to treesitter node
---@alias TSSexp.Action fun(node: TSNode): nil

---@class TSSexp.Command
---@field desc string Description
---@field action TSSexp.Action
---@field get_node TSSexp.GetNode
---@overload fun(): nil

---@class TSSexp.Textobject
---@field desc string Description
---@field get_node TSSexp.GetNode
---@field get_range TSSexp.GetRange
---@overload fun(): nil

---@class TSSexp.Motion
---@field desc string Description
---@field get_node TSSexp.GetNode
---@field pos "start"|"end" Move cursor to start or end of node
---@overload fun(): nil

--- Key mappings, set entry to false to disable
---@alias TSSexp.Keymaps table<string, string|false>

--- Configuration table
---@class TSSexp.Config
---@field commands? TSSexp.Config.Commands
---@field motions? TSSexp.Config.Motions
---@field textobjects? TSSexp.Config.Textobjects
---@field parent_node_overrides? TSSexp.Config.ParentNodeOverrides

--- Command Configuration
---@class TSSexp.Config.Commands
---@field keymaps? TSSexp.Keymaps

--- Motion Configuration
---@class TSSexp.Config.Motions
---@field keymaps? TSSexp.Keymaps

--- Text object Configuration
---@class TSSexp.Config.Textobjects
---@field keymaps? TSSexp.Keymaps

---@alias TSSexp.Config.ParentNodeOverrides table<string, string[]>
