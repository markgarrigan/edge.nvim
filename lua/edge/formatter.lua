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

local function is_html_single_line_block(line)
  -- opening <tag ...> ... </tag> on the SAME line (non-void)
  local open = line:match("^%s*<([%w:_%-]+)[^>]*>")
  if not open then return false end
  if void_tags[open:lower()] then return false end
  -- must end with matching close; tolerant of inner content
  local pat = "</" .. open .. ">%s*$"
  if line:find(pat) then return true end
  return false
end
local function is_html_open_start(line)
  -- starts with <tag but has no closing >
  return (line:find("^%s*<[%w:_%-]") ~= nil) and (line:find(">%s*$") == nil) and (line:find("^%s*</") == nil)
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

-- JS helpers
local function js_brace_delta(s)
  s = s:gsub("//.*$", "")
  local opens = 0; for _ in s:gmatch("{") do opens = opens + 1 end
  local closes = 0; for _ in s:gmatch("}") do closes = closes + 1 end
  return opens - closes
end
local function is_js_reopener(line)
  -- Reopeners: else, else if, catch, finally
  -- Match when they start the line OR come after a closing brace `}` on the same line.
  if line:find("^%s*else[%s%(%{:]") then return true end
  if line:find("^%s*}%s*else[%s%(%{:]") then return true end
  if line:find("^%s*catch[%s%(%{]") then return true end
  if line:find("^%s*}%s*catch[%s%(%{]") then return true end
  if line:find("^%s*finally[%s%{%:]") then return true end
  if line:find("^%s*}%s*finally[%s%{%:]") then return true end
  return false
end
local function js_pre_dedent(line)
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

local function is_js_iife_tail(line)
  -- Matches "})();" or "})   ;" etc.
  -- Start with '}', then optional spaces, then ')', optional spaces, then optional "()" (invoke) and/or ';'
  return line:find("^%s*}%s*%)%s*%(%s*%)?%s*;?%s*$") ~= nil
end

function M.format_lines(lines, sw)
  if not sw or sw == 0 then sw = 2 end
  local out = {}
  local edge_level, html_level, js_level = 0, 0, 0
  local in_script, in_style = false, false
  local pending_html_open = false  -- inside multi-line start tag

  for _, raw in ipairs(lines) do
    local raw_r = trim_right(raw or "")

    -- detect script/style boundaries
    local opens_script = raw_r:find("^%s*<script[%s>].*")
    local closes_script = raw_r:find("^%s*</script>%s*$")
    local opens_style  = raw_r:find("^%s*<style[%s>].*")
    local closes_style = raw_r:find("^%s*</style>%s*$")

    local stripped = trim_left(raw_r)

    -- PRE-EMIT: level pops
    local pre_edge = (is_edge_close(stripped) or is_edge_reopener(stripped)) and 1 or 0
    local pre_html = ((is_html_close(stripped) or closes_script or closes_style) and 1 or 0)
    local pre_js   = ((in_script or in_style) and (is_js_iife_tail(stripped) and 0 or js_pre_dedent(stripped)) or 0)

    edge_level = math.max(0, edge_level - pre_edge)
    html_level = math.max(0, html_level - pre_html)
    js_level   = math.max(0, js_level   - pre_js)

    -- Determine indent to emit
    local total_level = edge_level + html_level + js_level
    local prefix = string.rep(" ", sw * total_level)
    table.insert(out, (stripped == "") and "" or (prefix .. stripped))

    -- POST-EMIT: pushes
    local post_edge = (is_edge_reopener(stripped) or is_edge_open(stripped)) and 1 or 0

    local post_html = 0
    if pending_html_open then
      -- We're in a multi-line start tag: only when we see the line with '>' do we open html block
      if stripped:find(">%s*$") and not stripped:find("/>%s*$") then
        post_html = 1
        pending_html_open = false
      end
    else
      if is_html_open_start(stripped) then
        pending_html_open = true
      elseif opens_script or opens_style then
        post_html = 1
      elseif (not is_html_single_line_block(stripped)) and is_html_open(stripped) then
        post_html = 1
      end
    end

    local post_js = ((in_script or in_style) and js_post_indent(stripped) or 0) - ((in_script or in_style) and (is_js_iife_tail(stripped) and 1 or 0) or 0)

    edge_level = edge_level + post_edge
    html_level = html_level + post_html
    js_level   = js_level   + post_js

    -- toggle modes after
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
