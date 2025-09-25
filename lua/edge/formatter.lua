local M = {}

local function trim_right(s) return (s:gsub("%s+$", "")) end
local function trim_left(s) return (s:gsub("^%s+", "")) end

-- HTML helpers
local void_tags = {
  area=true, base=true, br=true, col=true, embed=true, hr=true, img=true,
  input=true, link=true, meta=true, param=true, source=true, track=true, wbr=true,
}

local function is_html_open(line)
  if line:find("^%s*</") then return false end
  if not line:find("^%s*<[%w:_%-]") then return false end
  if line:find("/>%s*$") then return false end
  local tag = line:match("^%s*<([%w:_%-]+)")
  if not tag then return false end
  if void_tags[tag:lower()] then return false end
  return line:find(">%s*$") ~= nil
end
local function is_html_close(line)
  return line:find("^%s*</[%w:_%-]+>%s*$") ~= nil
end

-- Edge helpers
local function is_edge_open(line)
  if vim.g.edge_layout_is_block and line:find("^%s*@layout%.%w+%b()") then return true end
  return line:find("^%s*@if%b()") or line:find("^%s*@each%b()") or line:find("^%s*@for%f[%s%(%w]") or line:find("^%s*@switch%b()")
end
local function is_edge_close(line)
  return line:find("^%s*@end%s*$") or line:find("^%s*@endif%s*$") or line:find("^%s*@endeach%s*$") or
         line:find("^%s*@endforeach%s*$") or line:find("^%s*@endfor%s*$") or line:find("^%s*@endswitch%s*$")
end
local function is_edge_reopener(line)
  return line:find("^%s*@else%s*$") or line:find("^%s*@elseif%b()%s*$") or
         line:find("^%s*@case%s+") or line:find("^%s*@default%s*$")
end

-- JS helpers (very pragmatic)
local function js_brace_delta(s)
  -- remove simple // comments
  s = s:gsub("//.*$", "")
  -- very naive: count braces; this is good enough for inline handlers
  local opens = 0; for _ in s:gmatch("{") do opens = opens + 1 end
  local closes = 0; for _ in s:gmatch("}") do closes = closes + 1 end
  return opens - closes
end
local function is_js_reopener(line)
  return line:find("^%s*else[%s%{%:]") or line:find("^%s*catch[%s%(%{]") or line:find("^%s*finally[%s%{%:]")
end
local function js_pre_dedent(line)
  -- Dedent before if the line starts with } or ] or ) or is a JS reopener token
  if line:find("^%s*[}%]%)]") then return 1 end
  if is_js_reopener(line) then return 1 end
  local delta = js_brace_delta(line)
  if delta < 0 then return -delta end
  return 0
end
local function js_post_indent(line)
  if is_js_reopener(line) then return 1 end
  local delta = js_brace_delta(line)
  if delta > 0 then return delta end
  return 0
end

function M.format_lines(lines, sw)
  if not sw or sw == 0 then sw = 2 end

  local out = {}
  local edge_level, html_level, js_level = 0, 0, 0
  local in_script, in_style = false, false

  for _, raw in ipairs(lines) do
    local raw_r = trim_right(raw or "")

    -- Detect mode transitions
    local opens_script = raw_r:find("^%s*<script[%s>].*")
    local closes_script = raw_r:find("^%s*</script>%s*$")
    local opens_style  = raw_r:find("^%s*<style[%s>].*")
    local closes_style = raw_r:find("^%s*</style>%s*$")

    local stripped = trim_left(raw_r)

    -- PRE-EMIT: compute dedents
    local pre_edge = 0
    if is_edge_close(stripped) or is_edge_reopener(stripped) then pre_edge = pre_edge + 1 end

    local pre_html = 0
    if is_html_close(stripped) or closes_script or closes_style then pre_html = pre_html + 1 end

    local pre_js = 0
    if in_script or in_style then
      pre_js = js_pre_dedent(stripped)
    end

    edge_level = math.max(0, edge_level - pre_edge)
    html_level = math.max(0, html_level - pre_html)
    js_level   = math.max(0, js_level   - pre_js)

    local total_level = edge_level + html_level + js_level
    local prefix = string.rep(" ", sw * total_level)

    -- For script/style body, we format like JS: trim left then apply prefix + js indent
    local to_emit = stripped
    table.insert(out, (to_emit == "") and "" or (prefix .. to_emit))

    -- POST-EMIT: compute increments
    local post_edge = 0
    if is_edge_reopener(stripped) or is_edge_open(stripped) then post_edge = post_edge + 1 end

    local post_html = 0
    if opens_script or opens_style or is_html_open(stripped) then post_html = post_html + 1 end

    local post_js = 0
    if in_script or in_style then
      post_js = js_post_indent(stripped)
    end

    edge_level = edge_level + post_edge
    html_level = html_level + post_html
    js_level   = js_level   + post_js

    -- Toggle modes AFTER using open/close info
    if opens_script then in_script = true end
    if closes_script then in_script = false end
    if opens_style then in_style = true end
    if closes_style then in_style = false end
  end

  return out
end

function M.format_text(text, sw)
  local str = (type(text) == "table") and table.concat(text, "\n") or tostring(text or "")
  local lines = {}
  for line in (str .. "\n"):gmatch("([^\n]*)\n") do table.insert(lines, line) end
  return table.concat(M.format_lines(lines, sw), "\n")
end

return M
