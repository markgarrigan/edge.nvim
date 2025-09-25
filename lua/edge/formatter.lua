local M = {}
local function trim_right(s) return (s:gsub("%s+$", "")) end
local function trim_left(s) return (s:gsub("^%s+", "")) end
local function is_edge_open(line)
  if vim.g.edge_layout_is_block and line:find("^%s*@layout%.%w+%b()") then return true end
  return line:find("^%s*@if%b()") or line:find("^%s*@each%b()") or line:find("^%s*@for%f[%s%(%w]") or line:find("^%s*@switch%b()")
end
local function is_edge_close(line)
  return line:find("^%s*@end%s*$") or line:find("^%s*@endif%s*$") or line:find("^%s*@endeach%s*$") or
         line:find("^%s*@endforeach%s*$") or line:find("^%s*@endfor%s*$") or line:find("^%s*@endswitch%s*$")
end
local function is_reopener(line)
  return line:find("^%s*@else%s*$") or line:find("^%s*@elseif%b()%s*$") or line:find("^%s*@case%s+") or line:find("^%s*@default%s*$")
end
local function is_html_open(line)
  return line:find("^%s*<[%w:_%-][^>]*>%s*$") and not line:find("^%s*</") and not line:find("/>%s*$")
end
local function is_html_close(line) return line:find("^%s*</[%w:_%-]+>%s*$") end
function M.format_lines(lines, sw)
  local out, level = {}, 0; if not sw or sw == 0 then sw = 2 end
  local in_script, in_style = false, false
  for _, raw in ipairs(lines) do
    local raw_r = trim_right(raw or "")
    local opens_script = raw_r:find("^%s*<script[%s>].*")
    local closes_script = raw_r:find("^%s*</script>%s*$")
    local opens_style  = raw_r:find("^%s*<style[%s>].*")
    local closes_style = raw_r:find("^%s*</style>%s*$")
    local line = (in_script or in_style) and raw_r or trim_left(raw_r)
    if is_edge_close(line) or is_reopener(line) or is_html_close(line) or closes_script or closes_style then
      level = math.max(0, level - 1)
    end
    local prefix = string.rep(" ", sw * level)
    table.insert(out, (line == "") and "" or (prefix .. line))
    if is_reopener(line) then
      level = level + 1
    elseif is_edge_open(line) or is_html_open(line) or opens_script or opens_style then
      level = level + 1
    end
    if opens_script then in_script = true end
    if closes_script then in_script = false end
    if opens_style then in_style = true end
    if closes_style then in_style = false end
  end
  return out
end
function M.format_text(text, sw)
  local str = (type(text) == "table") and table.concat(text, "\n") or tostring(text or "")
  local lines = {}; for line in (str.."\n"):gmatch("([^\n]*)\n") do table.insert(lines, line) end
  return table.concat(M.format_lines(lines, sw), "\n")
end
return M
