# edge.nvim v6.8

Fixes top-level mis-indents by tracking **Edge level** and **HTML level** separately:
- Edge blocks (`@layout/@if/@each/@for/@switch`) control a base indent.
- HTML tags control a nested indent.
- Reopener tokens (`@else/@elseif/@case/@default`) behave as close+open at the **Edge** level.
- `<script>/<style>` preserve internal indentation; only get the outer offset.

## Setup
```lua
require("edge").setup({
  -- indent_width = 2,
  -- layout_is_block = true,
})
```
