# edge.nvim

A pure-Lua Neovim plugin that makes **EdgeJS (`*.edge`)** templates feel native.
- Smart **indentexpr** for Edge blocks + HTML.
- Built-in **formatter** (via null-ls/none-ls) that re-indents correctly.
- Keeps **html-ls** features; disables its **formatting only** on `.edge`.
- **Explicit setup**: you control load order (`require("edge").setup()` after your other setups).

## Install
Clone into your packpath:
```bash
git clone https://example.com/edge.nvim ~/.config/nvim/pack/lsp/start/edge.nvim
```

## Setup (call this AFTER html/tailwind/null-ls/etc.)
```lua
require("edge").setup({
  indent_width = nil,        -- nil => use &shiftwidth (fallback 2)
  register_null_ls = true,   -- auto-register formatter if null-ls is installed
  enable_snippets = true,    -- load LuaSnip snippets if present
  extra_openers = {},        -- add custom opener regexes
  extra_closers = {},        -- add custom closer regexes
})
```

### What setup() does
- Ensures `*.edge` filetype is recognized (ftdetect also handles this).
- Extends html-ls to include `edge` and re-enables it.
- Registers Tree-sitter `edge → html` (if TS is present).
- Disables **only** html-ls formatting on `.edge` buffers.
- Registers a **null-ls** formatter source (correct return shape).
- Adds a buffer-local `<leader>fe` that formats via null-ls in `.edge` files.
- Loads optional LuaSnip snippets.

## License
MIT
