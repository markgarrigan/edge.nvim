# edge.nvim

A lightweight, pure-Lua Neovim plugin that gives **EdgeJS (`*.edge`) templates** first-class editing:
- Smart **on-type indentation** for Edge blocks (`@if/@else/@end`, `@each/@endeach`, `@layout.*(...)`) and HTML tags.
- A conservative **formatter** (via `null-ls`) that normalizes indentation using the same rules.
- Works with existing **html-language-server** and **tailwindcss-language-server** for LSP features (hover, diagnostics, completion).
- Optional **LuaSnip** snippets for common Edge/HTML blocks.

No external binaries. No Mason package required. Just drop this folder in your `packpath` or add via your manager.

---

## Install

If you use a custom manager that clones repos into `~/.config/nvim/pack/<group>/start`:

```bash
git clone https://example.com/your/edge.nvim.git   ~/.config/nvim/pack/lsp/start/edge.nvim
```

> Replace the URL with your fork. This repo is self-contained (no build step).

Neovim will auto-load plugins in `pack/*/start/*` on startup.

### With lazy.nvim (optional)

```lua
{
  dir = vim.fn.expand("~/.config/nvim/pack/lsp/start/edge.nvim"),
  config = function()
    require("edge").setup({
      -- indent_width = nil,       -- nil = use &shiftwidth
      -- register_null_ls = true,  -- auto-register formatter if null-ls present
      -- extra_openers = {},       -- additional opener regexes
      -- extra_closers = {},       -- additional closer regexes
      -- enable_snippets = true,   -- load LuaSnip snippets if available
    })
  end,
}
```

---

## What you get

- **Filetype**: `*.edge` → `edge` (ftdetect).
- **Indentation while typing**: Edge and HTML blocks indent correctly (`indentexpr`).
- **Formatting**: `:lua vim.lsp.buf.format()` reindents using the same logic (through `null-ls` if installed).
- **LSP features**: your existing `html` and `tailwindcss` LSPs will also attach to `edge` buffers.
- **Snippets**: handy LuaSnip snippets for Edge and HTML (optional).

---

## Requirements

- Neovim 0.9+ (tested with 0.9/0.10/0.11).
- Optional:
  - **null-ls / none-ls** for formatting (`:LspInstall` not required).
  - **LuaSnip** if you want the included snippets.
  - **nvim-treesitter** (optional) — we map `edge` to `html` for highlighting.

---

## Configuration

Call `setup()` **once** (your plugin manager's `config` is a good place). Defaults are sensible.

```lua
require("edge").setup({
  indent_width = nil,        -- nil -> use &shiftwidth; set number to force
  register_null_ls = true,   -- auto-register format source if null-ls is available
  extra_openers = {},        -- table of Lua patterns treated as "open" lines
  extra_closers = {},        -- table of Lua patterns treated as "close" lines
  enable_snippets = true,    -- try to load LuaSnip snippets
})
```

The plugin also:
- Extends `html` LSP to include `edge`: `filetypes = { "html", "edge" }`.
- Registers Tree-sitter language mapping: `edge` → `html` (if TS is present).

---

## Usage

Open any `*.edge` file and start typing. On Enter, the next line is placed at the correct indent.  
To format the buffer:

- Built-in mapping in this ftplugin: `<leader>fe`
- Or call: `:lua vim.lsp.buf.format()`

> The formatter is conservative: it won’t rewrite attributes or join/split tags—just indentation/trailing spaces.

---

## Files

```
edge.nvim/
├─ plugin/edge.lua           -- LSP integration & defaults
├─ ftdetect/edge.lua         -- maps *.edge → edge
├─ ftplugin/edge.lua         -- buffer opts, indentexpr, keys
└─ lua/edge/
   ├─ init.lua               -- setup(opts), null-ls registration, snippets
   ├─ indent.lua             -- smart indent engine (used by both typing & fmt)
   ├─ formatter.lua          -- conservative formatter
   └─ snippets.lua           -- LuaSnip snippets (optional)
```

---

## Notes

- You still get all html-ls features: hover, completion, diagnostics, go-to-definition for HTML semantics, etc.
- Tailwind LSP can be told to treat `edge` as HTML:
  ```lua
  vim.lsp.config["tailwindcss"] = {
    init_options = { userLanguages = { edge = "html" } },
    settings = { tailwindCSS = { includeLanguages = { edge = "html" } } },
  }
  vim.lsp.enable("tailwindcss")
  ```

---

## License

MIT


### Null-ls registration helper

To avoid load-order gotchas and return-shape bugs, you can register the formatter like this:

```lua
local null_ls = require("null-ls")
local edge_source = require("edge.null_ls_helper").source()

null_ls.setup({
  sources = vim.tbl_filter(function(s) return s end, {
    null_ls.builtins.formatting.stylua,
    edge_source, -- returns nil if null-ls missing
  }),
})
```
