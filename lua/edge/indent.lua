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
  if vim.g.edge_layout_is_block then
    table.insert(list, "^%s*@layout%.%w+%b()")
  end
  return list
end

local closers = {
  "^%s*@end%s*$",
  "^%s*@endif%s*$",
  "^%s*@endeach%s*$",
  "^%s*@endforeach%s*$",
  "^%s*@endfor%s*$",
  "^%s*@endswitch%s*$",
  "^%s*@else%s*$",
  "^%s*@elseif%b()%s*$",
  "^%s*</[%w:_%-]+>%s*$",
}

local function any_match(patts, line)
  for _, p in ipairs(patts) do
    if line:find(p) then return true end
  end
  return false
end

local function is_open(line) return any_match(build_openers(), line) end
local function is_close(line) return any_match(closers, line) end

function M.indent(lnum)
  if lnum <= 0 then return 0 end
  local curr = vim.fn.getline(lnum)
  local prev = vim.fn.getline(lnum - 1)
  local sw = tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth
  if not sw or sw == 0 then sw = 2 end

  local prev_levels = math.max(0, math.floor(vim.fn.indent(lnum - 1) / sw))
  local cur_delta = is_close(curr) and -1 or 0
  local prev_delta = is_open(prev) and 1 or 0
  local levels = math.max(0, prev_levels + prev_delta + cur_delta)
  return levels * sw
end

return M
