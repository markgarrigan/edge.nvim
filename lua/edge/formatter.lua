local M = {}

local function build_openers()
  local list = {
    "^%s*@if%b()",
    "^%s*@elseif%b()%s*$",
    "^%s*@else%s*$",
    "^%s*@each%b()",
    "^%s*@for%f[%s%(%w]",
    "^%s*@switch%b()",
    "^%s*<[%w:_%-][^>]*>%s*$",
  }
  if vim.g.edge_layout_is_block then table.insert(list, "^%s*@layout%.%w+%b()") end
  return list
end
local closers = {
  "^%s*@end%s*$","^%s*@endif%s*$","^%s*@endeach%s*$","^%s*@endforeach%s*$",
  "^%s*@endfor%s*$","^%s*@endswitch%s*$","^%s*@else%s*$","^%s*@elseif%b()%s*$",
  "^%s*</[%w:_%-]+>%s*$",
}
local function any_match(patts, line) for _,p in ipairs(patts) do if line:find(p) then return true end end return false end
local function is_open(line) return any_match(build_openers(), line) end
local function is_close(line) return any_match(closers, line) end

local function trim_right(s) return (s:gsub("%s+$", "")) end
local function trim_left(s) return (s:gsub("^%s+", "")) end

function M.format_lines(lines, sw)
  local out, level = {}, 0
  if not sw or sw == 0 then sw = 2 end
  for _, raw in ipairs(lines) do
    local line = trim_left(trim_right(raw or ""))
    if is_close(line) then level = math.max(0, level - 1) end
    local prefix = string.rep(" ", sw * level)
    table.insert(out, (line == "") and "" or (prefix .. line))
    if is_open(line) then level = level + 1 end
  end
  return out
end

function M.format_text(text, sw)
  local str = (type(text) == "table") and table.concat(text, "\n") or tostring(text or "")
  local lines = {}; for line in (str.."\n"):gmatch("([^\n]*)\n") do table.insert(lines, line) end
  return table.concat(M.format_lines(lines, sw), "\n")
end

return M
