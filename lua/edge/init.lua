local M = {}
local defaults = { indent_width = nil, layout_is_block = true, register_null_ls = true }
local function extend_html_filetypes()
  pcall(function()
    vim.lsp.config.html = vim.tbl_deep_extend('force', vim.lsp.config.html or {}, {
      filetypes = { 'html', 'edge' }, init_options = { provideFormatter = true },
    })
    vim.lsp.enable('html')
  end)
end
local function disable_html_format_on_edge()
  local grp = vim.api.nvim_create_augroup("edge_html_fmt_off", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = grp, callback = function(args)
      local c = vim.lsp.get_client_by_id(args.data.client_id); if not c then return end
      if vim.bo[args.buf].filetype == "edge" and c.name == "html" then
        c.server_capabilities.documentFormattingProvider = false
        c.server_capabilities.documentRangeFormattingProvider = false
      end
    end,
  })
end
local function register_formatter()
  local ok, null_ls = pcall(require, 'null-ls'); if not ok then return end
  if vim.g.edge_null_ls_registered then return end
  null_ls.register({
    name = "edgefmt", method = null_ls.methods.FORMATTING, filetypes = { "edge" },
    generator = { fn = function(params)
      local content = params.content; if type(content) == "table" then content = table.concat(content, "\n") end
      local sw = M.opts.indent_width; if not sw then pcall(function() sw = vim.api.nvim_buf_get_option(params.bufnr, 'shiftwidth') end) end
      if not sw or sw == 0 then sw = 2 end
      local formatted = require("edge.formatter").format_text(content, sw)
      return { { text = formatted } }
    end },
  })
  vim.g.edge_null_ls_registered = true
end
local function enforce_indent_width()
  local grp = vim.api.nvim_create_augroup("edge_buf_opts", { clear = true })
  vim.api.nvim_create_autocmd("FileType", { group = grp, pattern = "edge", callback = function(args)
    local sw = M.opts.indent_width or vim.bo[args.buf].shiftwidth; if not sw or sw == 0 then sw = 2 end
    vim.bo[args.buf].shiftwidth = sw; vim.bo[args.buf].tabstop = sw; vim.bo[args.buf].softtabstop = sw; vim.bo[args.buf].expandtab = true
  end })
end
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', defaults, opts or {})
  vim.g.edge_indent_width = M.opts.indent_width
  vim.g.edge_layout_is_block = M.opts.layout_is_block
  vim.filetype.add({ extension = { edge = 'edge' } })
  extend_html_filetypes(); disable_html_format_on_edge(); enforce_indent_width()
  if M.opts.register_null_ls then register_formatter() end
end
return M
