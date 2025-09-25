# edge.nvim v6.10 (pragmatic)
Rules:
- Strip leading indent for non-<script>/<style> lines
- Single indent level
- Closers + re-openers dedent before emit; re-openers then re-indent
- Openers indent after emit
- Preserve inner indent inside <script>/<style>
