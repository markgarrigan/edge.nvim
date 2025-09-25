local M = {}


local void_tags = {
  area=true, base=true, br=true, col=true, embed=true, hr=true, img=true,
  input=true, link=true, meta=true, param=true, source=true, track=true, wbr=true,
}

local function html_opens_block(line)
  -- match a simple one-line start tag: <tag ...>
  local tag = line:match("^%s*<([%w:_%-]+)[^>]*>%s*$")
  if not tag then return false end
  -- closing tags handled elsewhere
  if line:find("^%s*</") then return false end
  -- self-closing <.../> should not open a block
  if line:find("/>%s*$") then return false end
  -- void elements do not open blocks
  if void_tags[tag:lower()] then return false end
  return true
end


local function is_html_close(line)
  return line:find("^%s*</[%w:_%-]+>%s*$") ~= nil
end

local function is_html_open(line)
  return html_opens_block(line)
end

local function edge_openers()
  local list = {
    "^%s*@if%b()",
    "^%s*@each%b()",
    "^%s*@for%f[%s%(%w]",
    "^%s*@switch%b()",
    -- reopener tokens are handled via prev line (see logic below)
  }
  if vim.g.edge_layout_is_block then
    table.insert(list, "^%s*@layout%.%w+%b()")
  end
  return list
end

local edge_closers = {
  "^%s*@end%s*$",
  "^%s*@endif%s*$",
  "^%s*@endeach%s*$",
  "^%s*@endforeach%s*$",
  "^%s*@endfor%s*$",
  "^%s*@endswitch%s*$",
}

local reopener_tokens = {
  "^%s*@else%s*$",
  "^%s*@elseif%b()%s*$",
  "^%s*@case%s+",
  "^%s*@default%s*$",
}

local function any_match(patts, line)
  for _, p in ipairs(patts) do
    if line:find(p) then return true end
  end
  return false
end

local function is_edge_open(line) return any_match(edge_openers(), line) end
local function is_edge_close(line) return any_match(edge_closers, line) end
local function is_reopener(line) return any_match(reopener_tokens, line) end

function M.indent(lnum)
  if lnum <= 0 then return 0 end
  local curr = vim.fn.getline(lnum)
  local prev = vim.fn.getline(lnum - 1)

  local sw = tonumber(vim.g.edge_indent_width) or vim.bo.shiftwidth
  if not sw or sw == 0 then sw = 2 end

  local prev_indent = vim.fn.indent(lnum - 1)
  local prev_levels = math.max(0, math.floor(prev_indent / sw))

  local cur_delta = 0
  local prev_delta = 0

  -- Current-line closers: HTML close or Edge close or reopener (dedent this line)
  if is_html_close(curr) or is_edge_close(curr) or is_reopener(curr) then
    cur_delta = cur_delta - 1
  end

  -- Previous-line openers: Edge open, HTML open, or reopener (reopener re-opens for the next line)
  if is_edge_open(prev) or is_html_open(prev) or is_reopener(prev) then
    prev_delta = prev_delta + 1
  end

  local levels = math.max(0, prev_levels + prev_delta + cur_delta)
  return levels * sw
end

return M
