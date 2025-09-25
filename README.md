# edge.nvim

A pure Lua LSP-style formatter and indentation plugin for EdgeJS (`.edge`) templates.

## Features
- Indents HTML properly under `@layout.*(...)` (default enabled)
- Aligns `@if`, `@each`, `@end` blocks correctly
- Preserves internal indentation inside `<script>` and `<style>`
- Disables html-ls formatting for `.edge` files (but keeps hover/completion)
- Includes a built-in `null-ls` formatter (no external binary)

## Setup

Call this **after** your other LSP setup:

```lua
require("edge").setup({
  -- optional
  -- indent_width = 2,       -- uses &shiftwidth if nil
  -- layout_is_block = true, -- default true
})
```
