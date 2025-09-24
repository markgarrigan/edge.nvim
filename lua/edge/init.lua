local M = {}

local defaults = {
  indent_width = nil,
  register_null_ls = true,
  extra_openers = {},
  extra_closers = {},
  enable_snippets = true,
}

local function extend_html_filetypes()
  local ok = pcall(function()
    vim.lsp.config.html = vim.tbl_deep_extend('force', vim.lsp.config.html or {}, {
      filetypes = { 'html', 'edge' },
      init_options = { provideFormatter = true },
    })
    vim.lsp.enable('html')
  end)
  return ok
end

local function ts_map_edge_to_html()
  pcall(function()
    vim.treesitter.language.register('html', 'edge')
  end)
end

local function make_html_not_format_edge()
  vim.api.nvim_create_augroup("edge_html_fmt_off", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = "edge_html_fmt_off",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end
      local bufnr = args.buf
      if vim.bo[bufnr].filetype == "edge" and client.name == "html" then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end,
  })
end

local function register_edge_formatter()
  local ok, null_ls = pcall(require, 'null-ls')
  if not ok then return end
  if vim.g.edge_null_ls_registered then return end
  local source = {
    name = "edgefmt",
    method = null_ls.methods.FORMATTING,
    filetypes = { "edge" },
    generator = {
      fn = function(params)
        local content = params.content
        if type(content) == "table" then
          content = table.concat(content, "\n")
        end
        local sw = 2
        pcall(function()
          sw = vim.api.nvim_buf_get_option(params.bufnr, 'shiftwidth')
        end)
        if sw == 0 or sw == nil then sw = 2 end
        local formatted = require("edge.formatter").format_text(content, sw)
        return { { text = formatted } }
      end,
    },
  }
  null_ls.register(source)
  vim.g.edge_null_ls_registered = true
end

local function map_format_key()
  vim.api.nvim_create_augroup("edge_buf_keys", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = "edge_buf_keys",
    pattern = "edge",
    callback = function(args)
      vim.keymap.set('n', '<leader>fe', function()
        vim.lsp.buf.format({
          async = false,
          filter = function(client) return client.name == "null-ls" end,
        })
      end, { buffer = args.buf, desc = "Format Edge (null-ls)" })
    end,
  })
end

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', defaults, opts or {})
  vim.g.edge_indent_width = M.opts.indent_width

  -- Ensure filetype
  vim.filetype.add({ extension = { edge = 'edge' } })

  -- LSP + Treesitter wiring
  extend_html_filetypes()
  ts_map_edge_to_html()
  make_html_not_format_edge()

  -- Register null-ls formatter if desired
  if M.opts.register_null_ls then
    register_edge_formatter()
  end

  -- Snippets
  if M.opts.enable_snippets then
    pcall(require, 'edge.snippets')
  end

  -- User extra patterns
  if #M.opts.extra_openers > 0 or #M.opts.extra_closers > 0 then
    local indent = require('edge.indent')
    vim.list_extend(indent.user_openers, M.opts.extra_openers or {})
    vim.list_extend(indent.user_closers, M.opts.extra_closers or {})
  end

  -- Keymaps
  map_format_key()
end

return M
