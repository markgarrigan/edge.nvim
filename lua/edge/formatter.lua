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

local function build_html_open_check(line)
  return html_opens_block(line)
end

local function build_openers()
  -- Edge openers (non-HTML)
  local list = {
    "^%s*@if%b()",
    "^%s*@each%b()",
    "^%s*@for%f[%s%(%w]",
    "^%s*@switch%b()",
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
}

-- Tokens that act as close + open at same level
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

local function is_edge_open(line) return any_match(build_openers(), line) end
local function is_edge_close(line) return any_match(closers, line) end
local function is_reopener(line) return any_match(reopener_tokens, line) end

local function trim_right(s) return (s:gsub("%s+$", "")) end
local function trim_left(s) return (s:gsub("^%s+", "")) end

function M.format_lines(lines, sw)
  local out, level = {}, 0
  if not sw or sw == 0 then sw = 2 end
  local in_script, in_style = false, false

  for _, raw in ipairs(lines) do
    local raw_r = trim_right(raw or "")
    local stripped = trim_left(raw_r)
    local line = stripped

    -- <script>/<style> block tracking
    if raw_r:find("^%s*<script[%s>].*") then in_script = true end
    if raw_r:find("^%s*</script>%s*$") then in_script = false end
    if raw_r:find("^%s*<style[%s>].*") then in_style = true end
    if raw_r:find("^%s*</style>%s*$") then in_style = false end

    -- Dedent for closes and re-openers
    if is_edge_close(line) or is_reopener(line) or is_html_close(line) then
      level = math.max(0, level - 1)
    end

    local prefix = string.rep(" ", sw * level)

    local to_emit
    if in_script or in_style then
      to_emit = raw_r
    else
      -- Outside script/style, remove leading spaces before re-applying indent
      to_emit = line
    end

    if to_emit == "" then
      table.insert(out, "")
    else
      table.insert(out, prefix .. to_emit)
    end

    -- After emitting, push for openers and re-openers
    if is_reopener(line) then
      level = level + 1
    else
      -- Edge openers
      if is_edge_open(line) then
        level = level + 1
      else
        -- HTML openers (non-void, not self-closing)
        if build_html_open_check(line) or raw_r:find("^%s*<script[%s>].*") or raw_r:find("^%s*<style[%s>].*") then
          level = level + 1
        end
      end
    end
  end

  return out
end

function M.format_text(text, sw)
  local str = (type(text) == "table") and table.concat(text, "\n") or tostring(text or "")
  local lines = {}
  for line in (str .. "\n"):gmatch("([^\n]*)\n") do
    table.insert(lines, line)
  end
  return table.concat(M.format_lines(lines, sw), "\n")
end

return M
