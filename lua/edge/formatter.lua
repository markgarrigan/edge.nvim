local indent_api = require('edge.indent')

local M = {}

local user_openers = indent_api.user_openers
local user_closers = indent_api.user_closers

local openers = {
  "^%s*@if%b()",
  "^%s*@each%b()",
  "^%s*@for%f[%s%(%w]",
  "^%s*@switch%b()",
  "^%s*@else%s*$",
  "^%s*@elseif%b()%s*$",
  "^%s*<[%w:_%-][^>]*>%s*$",
}

local closers = {
  "^%s*@end%s*$",
  "^%s*@endeach%s*$",
  "^%s*@else%s*$",
  "^%s*@elseif%b()%s*$",
  "^%s*</[%w:_%-]+>%s*$",
}

local function any_match(patterns, line)
  for _, pat in ipairs(patterns) do
    if line:find(pat) then return true end
  end
  return false
end

local function is_open(line)
  return any_match(openers, line) or any_match(user_openers, line)
end

local function is_close(line)
  return any_match(closers, line) or any_match(user_closers, line)
end

local function trim_right(s) return (s:gsub("%s+$", "")) end

function M.format_lines(lines, sw)
  local out = {}
  local level = 0
  sw = tonumber(sw) or tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth
  if sw == 0 or sw == nil then sw = 2 end

  for _, raw in ipairs(lines) do
    local line = trim_right(raw or "")

    if is_close(line) then
      level = math.max(0, level - 1)
    end

    local prefix = string.rep(" ", sw * level)
    if line == "" then
      table.insert(out, "")
    else
      table.insert(out, prefix .. line)
    end

    if is_open(line) then
      level = level + 1
    end
  end

  return out
end

function M.format_text(text, sw)
  local str
  if type(text) == "table" then
    str = table.concat(text, "\n")
  else
    str = tostring(text or "")
  end

  local lines = {}
  for line in (str .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  local formatted = M.format_lines(lines)
  return table.concat(formatted, "\n")
end

return M
