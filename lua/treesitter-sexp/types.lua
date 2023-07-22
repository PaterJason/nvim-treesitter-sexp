--- Get node around cursor
---@alias TSSexp.GetNode fun(): TSNode|nil
---@alias TSSexp.GetRange fun(node: TSNode): integer, integer, integer, integer

--- Action to apply to treesitter node
---@alias TSSexp.Action fun(node: TSNode): nil

---@class TSSexpOperator
---@field desc string Description
---@field action TSSexp.Action
---@field get_node TSSexp.GetNode
---@overload fun(): nil

---@class TSSexpTextobject
---@field desc string Description
---@field get_node TSSexp.GetNode
---@field get_range TSSexp.GetRange
---@overload fun(): nil

---@class TSSexp.Motion
---@field desc string Description
---@field get_node TSSexp.GetNode
---@field pos "start"|"end" Move cursor to start or end of node
---@overload fun(): nil

---@alias TSSexp.Keymaps table<string, string>

---@class TSSexp.Config
---@field operators {keymaps: TSSexp.Keymaps}
---@field motions {keymaps: TSSexp.Keymaps}
---@field textobjects {keymaps: TSSexp.Keymaps}
---@field parent_node_overrides table<string, string[]>
