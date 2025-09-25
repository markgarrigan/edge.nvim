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


local function is_html_single_line_block(line)
  local open = line:match("^%s*<([%w:_%-]+)[^>]*>")
  if not open then return false end
  if void_tags[open:lower()] then return false end
  local pat = "</" .. open .. ">%s*$"
  if line:find(pat) then return true end
  return false
end
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

function M.indent(lnum)
  if lnum <= 0 then return 0 end
  local curr = vim.fn.getline(lnum)
  local prev = vim.fn.getline(lnum - 1)
  local sw = tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth
  if not sw or sw == 0 then sw = 2 end

  local cur_delta = 0
  local prev_delta = 0

  if is_edge_close(curr) or is_edge_reopener(curr) or is_html_close(curr) then
    cur_delta = cur_delta - 1
  end
  if is_edge_open(prev) or is_edge_reopener(prev) or (is_html_open(prev) and not is_html_single_line_block(prev)) then
    prev_delta = prev_delta + 1
  end

  local prev_levels = math.max(0, math.floor(vim.fn.indent(lnum - 1) / sw))
  local levels = math.max(0, prev_levels + prev_delta + cur_delta)
  return levels * sw
end

return M
