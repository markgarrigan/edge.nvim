local M = {}

local defaults = {
  indent_width = nil,
  register_null_ls = true,
  extra_openers = {},
  extra_closers = {},
  enable_snippets = true,
}

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', defaults, opts or {})
  vim.g.edge_indent_width = M.opts.indent_width

  if M.opts.register_null_ls then
    local ok, null_ls = pcall(require, 'null-ls')
    if ok then
      local edgefmt = {
        name = "edgefmt",
        method = null_ls.methods.FORMATTING,
        filetypes = { "edge" },
        generator = {
          fn = function(params)
            local formatted = require("edge.formatter").format_text(params.content)
            return formatted
          end,
        },
      }
      null_ls.register(edgefmt)
    end
  end

  if M.opts.enable_snippets then
    pcall(require, 'edge.snippets')
  end

  if #M.opts.extra_openers > 0 or #M.opts.extra_closers > 0 then
    local indent = require('edge.indent')
    vim.list_extend(indent.user_openers, M.opts.extra_openers or {})
    vim.list_extend(indent.user_closers, M.opts.extra_closers or {})
  end
end

return M
