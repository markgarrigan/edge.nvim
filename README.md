# edge.nvim v6.9

Refines `@else/@elseif/@case/@default` handling to avoid rare misalignment:
- Treats those as **close-then-open** at the *Edge* level only.
- Keeps separate **Edge** and **HTML** indent levels.
- Ignores void/self-closing tags for HTML opens.
- Preserves inner indentation in `<script>`/`<style>`.

## Setup
```lua
require("edge").setup({
  -- indent_width = 2,
  -- layout_is_block = true,
})
```
