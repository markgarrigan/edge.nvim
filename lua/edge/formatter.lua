local M = {}

local function build_openers()
  local list = {
    "^%s*@if%b()",
    "^%s*@elseif%b()%s*$",
    "^%s*@else%s*$",
    "^%s*@each%b()",
    "^%s*@for%f[%s%(%w]",
    "^%s*@switch%b()",
    "^%s*@case%s+",
    "^%s*@default%s*$",
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
  "^%s*</[%w:_%-]+>%s*$",
}

-- Tokens that are close + open pairs (align siblings)
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

local function is_open(line) return any_match(build_openers(), line) end
local function is_close(line) return any_match(closers, line) end
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

    if raw_r:find("^%s*<script[%s>].*") then in_script = true end
    if raw_r:find("^%s*</script>%s*$") then in_script = false end
    if raw_r:find("^%s*<style[%s>].*") then in_style = true end
    if raw_r:find("^%s*</style>%s*$") then in_style = false end

    -- If this line is a closer (like @end), pop
    if is_close(line) then
      level = math.max(0, level - 1)
    end

    -- If it's a reopener (@else, @case), pop then immediately re-push
    if is_reopener(line) then
      level = math.max(0, level - 1)
    end

    local prefix = string.rep(" ", sw * level)
    local to_emit = ((in_script or in_style) and raw_r or line)
    if to_emit == "" then
      table.insert(out, "")
    else
      table.insert(out, prefix .. to_emit)
    end

    -- After printing a reopener, push back
    if is_reopener(line) then
      level = level + 1
    elseif is_open(line) or raw_r:find("^%s*<script[%s>].*") or raw_r:find("^%s*<style[%s>].*") then
      level = level + 1
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
