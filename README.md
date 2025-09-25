# edge.nvim v6.6

EdgeJS (`.edge`) formatter + indenter for Neovim.

## Highlights

- ✅ Top-level HTML indents under `@layout`
- ✅ Preserves internal indentation in `<script>` and `<style>`
- ✅ `@else`, `@elseif`, `@case`, and `@default` align with their parent block
- ✅ Nested blocks indent correctly and `@end` pops indentation cleanly

## Setup

```lua
require("edge").setup({
  -- indent_width = 2,
  -- layout_is_block = true,
})
```
