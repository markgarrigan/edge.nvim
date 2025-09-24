
local M = {}

function M.source()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then return nil end
  return {
    name = "edgefmt",
    method = null_ls.methods.FORMATTING,
    filetypes = { "edge" },
    generator = {
      fn = function(params)
        local content = params.content
        if type(content) == "table" then
          content = table.concat(content, "\n")
        end
        return require("edge.formatter").format_text(content)
      end,
    },
  }
end

return M
