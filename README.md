# edge.nvim v6.7

EdgeJS (`.edge`) formatter + indenter for Neovim.

**What’s new in v6.7**
- HTML opener detection now **ignores void tags** (`img`, `br`, `input`, etc.) and **self-closing tags** (`<tag ... />`), preventing phantom indentation that could misalign `@else/@end`.
- Keeps v6.6 improvements: `@else/@elseif/@case/@default` behave as close+open, `<script>/<style>` preserve inner indentation, `@layout` indents top-level.

## Setup
```lua
require("edge").setup({
  -- indent_width = 2,
  -- layout_is_block = true,
})
```
