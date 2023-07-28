# nvim-treesitter-sexp **(WIP)**

A plug-in for [Neovim](https://github.com/neovim/neovim) for editing code by
manipulating the Tree-sitter AST. Inspired by
[vim-sexp](https://github.com/guns/vim-sexp). This is particularly useful for
editing Lisps

## Configuration

(Default values are shown below)

```lua
require("treesitter-sexp").setup {
  keymaps = {
    commands = {
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
    },
    motions = {
      form_start = "(",
      form_end = ")",
      prev_elem = "[e",
      next_elem = "]e",
      prev_top_level = "[[",
      next_top_level = "]]",
    },
    textobjects = {
      inner_elem = "ie",
      inner_form = "if",
      inner_top_level = "iF",
      outer_elem = "ae",
      outer_form = "af",
      outer_top_level = "aF",
    },
  },
}
```

## Commands

`TSSexp`

## Mappings

