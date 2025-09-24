local indent = require('edge.indent')

local M = {}

local void_tags = {
  area=true, base=true, br=true, col=true, embed=true, hr=true, img=true,
  input=true, link=true, meta=true, param=true, source=true, track=true, wbr=true,
}

local function trim_right(s) return (s:gsub("%s+$", "")) end

local function tag_name_of_open(s)
  local name = s:match("^%s*<([%w:_%-]+)")
  return name
end

local function is_void_tag_line(s)
  local n = tag_name_of_open(s)
  if not n then return false end
  if s:match("/>%s*$") then return true end
  return void_tags[n] or false
end

local function is_edge_directive(s)
  return s:find("^%s*@") ~= nil
end

function M.format_lines(lines)
  local out = {}
  for lnum = 1, #lines do
    local raw = trim_right(lines[lnum] or "")
    local spaces = indent.indent(lnum)
    local prefix = string.rep(" ", spaces)

    if raw == "" then
      table.insert(out, "")
    elseif is_void_tag_line(raw) then
      -- Keep as-is but normalize minimal spacing at '/>'
      table.insert(out, prefix .. raw:gsub("%s*/>", " />"))
    elseif is_edge_directive(raw) then
      table.insert(out, prefix .. raw)
    else
      table.insert(out, prefix .. raw)
    end
  end
  return out
end

function M.format_text(text)
  local lines = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  local formatted = M.format_lines(lines)
  return table.concat(formatted, "\n")
end

return M
