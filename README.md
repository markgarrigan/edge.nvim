# edge.nvim v7.0

A pragmatic, **single-pass** formatter/indenter for EdgeJS (`.edge`) with JS-aware `<script>` handling.

## What’s new
- Deterministic **line-by-line** algorithm with three levels:
  - **edge_level** for `@layout/@if/@each/@for/@switch` (reopeners: `@else/@elseif/@case/@default`)
  - **html_level** for **non-void, non-self-closing** HTML elements
  - **js_level** inside `<script>`/**<style>** using **brace-based** indentation (`{}`), plus `else/catch/finally` as re-openers
- Handles mixed content: Edge + HTML + inline JS.
- Honors your `shiftwidth` (fallback 2).

## Setup
```lua
require("edge").setup({
  -- indent_width = 2,
  -- layout_is_block = true,
})
```
