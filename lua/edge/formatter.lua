local M = {}


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


-- Edge tokens
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

local function trim_right(s) return (s:gsub("%s+$", "")) end
local function trim_left(s) return (s:gsub("^%s+", "")) end

function M.format_lines(lines, sw)
  local out = {}
  if not sw or sw == 0 then sw = 2 end
  local edge_level, html_level = 0, 0
  local in_script, in_style = false, false

  for _, raw in ipairs(lines) do
    local raw_r = trim_right(raw or "")
    local line = trim_left(raw_r)

    -- track script/style
    local opens_script = raw_r:find("^%s*<script[%s>].*")
    local closes_script = raw_r:find("^%s*</script>%s*$")
    local opens_style = raw_r:find("^%s*<style[%s>].*")
    local closes_style = raw_r:find("^%s*</style>%s*$")

    -- PRE-EMIT: apply dedents
    if is_edge_close(line) then edge_level = math.max(0, edge_level - 1) end
    if is_reopener(line) then edge_level = math.max(0, edge_level - 1) end
    if is_html_close(line) or closes_script or closes_style then html_level = math.max(0, html_level - 1) end

    local level = edge_level + html_level
    local prefix = string.rep(" ", sw * level)

    local to_emit = ((in_script or in_style) and raw_r or line)
    if to_emit == "" then
      table.insert(out, "")
    else
      table.insert(out, prefix .. to_emit)
    end

    -- POST-EMIT: apply opens
    if is_reopener(line) then edge_level = edge_level + 1 end
    if is_edge_open(line) then edge_level = edge_level + 1 end

    if opens_script or opens_style or is_html_open(line) then
      html_level = html_level + 1
    end

    -- toggle script/style flags after processing
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
