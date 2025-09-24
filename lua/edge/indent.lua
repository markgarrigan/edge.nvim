local M = {}

M.user_openers = {}
M.user_closers = {}

local openers = {
  "^%s*@if%b()",
  "^%s*@elseif%b()%s*$",  -- acts as opener for the following line
  "^%s*@else%s*$",        -- acts as opener for the following line
  "^%s*@each%b()",
  "^%s*@for%f[%s%(%w]",
  "^%s*@switch%b()",
  "^%s*@layout%.%w+%b()", -- layout is a true block opener
  "^%s*<[%w:_%-][^>]*>%s*$",
}

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

local function any_match(patterns, line)
  for _, pat in ipairs(patterns) do
    if line:find(pat) then return true end
  end
  return false
end

local function is_opener(line)
  return any_match(openers, line) or any_match(M.user_openers, line)
end

local function is_closer(line)
  return any_match(closers, line) or any_match(M.user_closers, line)
end

function M.indent(lnum)
  if lnum <= 0 then return 0 end
  local curr = vim.fn.getline(lnum)
  local prev = vim.fn.getline(lnum - 1)
  local sw = tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth
  if sw == 0 then sw = 2 end

  local prev_levels = math.max(0, math.floor(vim.fn.indent(lnum - 1) / sw))

  local cur_delta = is_closer(curr) and -1 or 0
  local prev_delta = is_opener(prev) and 1 or 0

  local levels = math.max(0, prev_levels + prev_delta + cur_delta)
  return levels * sw
end

return M
