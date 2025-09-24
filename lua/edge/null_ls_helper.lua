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
        local formatted = require("edge.formatter").format_text(content)
        -- null-ls expects a list of results; formatting uses { { text = ... } }
        return { { text = formatted } }
      end,
    },
  }
end

return M
