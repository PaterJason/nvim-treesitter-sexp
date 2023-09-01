# nvim-treesitter-sexp

A plugin for [Neovim](https://github.com/neovim/neovim) for editing code by
manipulating the Treesitter AST. Basically a reimplementation of
[vim-sexp](https://github.com/guns/vim-sexp) using treesitter queries. This is
particularly useful for editing Lisps and manipulating data structures

## Requirements
- Neovim 0.9.1 or later
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with
the relevant language parsers installed

## Configuration

Calling setup is not required to use nvim-treesitter-sexp, it is only needed
for configuration

Example with default config values:

```lua
require("treesitter-sexp").setup {
  -- Enable/disable
  enabled = true,
  -- Move cursor when applying commands
  set_cursor = true,
  -- Set to false to disable all keymaps
  keymaps = {
    -- Set to false to disable keymap type
    commands = {
      -- Set to false to disable individual keymaps
      swap_prev_elem = "<e",
      swap_next_elem = ">e",
      swap_prev_form = "<f",
      swap_next_form = ">f",
      promote_elem = "<LocalLeader>O",
      promote_form = "<LocalLeader>o",
      splice = "<LocalLeader>@",
      slurp_left = "<(",
      slurp_right = ">)",
      barf_left = ">(",
      barf_right = "<)",
      insert_head = "<I",
      insert_tail = ">I",
    },
    motions = {
      form_start = "(",
      form_end = ")",
      prev_elem = "[e",
      next_elem = "]e",
      prev_elem_end = "[E",
      next_elem_end = "]E",
      prev_top_level = "[[",
      next_top_level = "]]",
    },
    textobjects = {
      inner_elem = "ie",
      outer_elem = "ae",
      inner_form = "if",
      outer_form = "af",
      inner_top_level = "iF",
      outer_top_level = "aF",
    },
  },
}
```

## Commands

The commands can be called using `:TSSexp` with any of the following arguments:

`swap_prev_elem`, `swap_next_elem`, `swap_prev_form`, `swap_next_form`,
`promote_elem`, `promote_form`, `splice`, `slurp_left`, `slurp_right`,
`barf_left`, `barf_right`

## Mappings

The default mappings are taken from vim-sexp and
vim-sexp-mappings-for-regular-people. I've avoided any use of the meta key

## Supported languages

For `nvim-treesitter-sexp` to support a language requires a query file. I'm
open to adding more queries and welcome contributions to support more
languages.

- `clojure`
- `fennel`
- `janet`
- `query` tree-sitter query language
