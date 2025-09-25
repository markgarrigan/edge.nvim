# edge.nvim v7.1

Delta from v7.0:
- **Multi-line HTML openers** are now indented correctly:
  - `<div` (no `>`) line and following attribute lines indent at the current level.
  - The line that ends the tag with `>` emits at the same level, then starts the HTML block (**html_level += 1**).
- All previous improvements preserved:
  - Edge blocks with reopener semantics
  - JS brace-based indentation inside `<script>/<style>`
  - Void/self-closing tag detection
