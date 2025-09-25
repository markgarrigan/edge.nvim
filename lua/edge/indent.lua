local M = {}
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
function M.indent(lnum)
  if lnum <= 0 then return 0 end
  local curr = vim.fn.getline(lnum); local prev = vim.fn.getline(lnum-1)
  local sw = tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth; if not sw or sw == 0 then sw = 2 end
  local cur_delta, prev_delta = 0, 0
  if is_edge_close(curr) or is_reopener(curr) or is_html_close(curr) then cur_delta = cur_delta - 1 end
  if is_edge_open(prev) or is_reopener(prev) or is_html_open(prev) then prev_delta = prev_delta + 1 end
  local prev_levels = math.max(0, math.floor(vim.fn.indent(lnum - 1) / sw))
  local levels = math.max(0, prev_levels + prev_delta + cur_delta)
  return levels * sw
end
return M
