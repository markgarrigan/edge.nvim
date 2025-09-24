-- edge.nvim: plugin entrypoint
pcall(function()
  vim.lsp.config.html = vim.tbl_deep_extend('force', vim.lsp.config.html or {}, {
    filetypes = { 'html', 'edge' },
    init_options = { provideFormatter = true },
  })
  vim.lsp.enable('html')
end)

pcall(function()
  vim.treesitter.language.register('html', 'edge')
end)

pcall(function()
  if not package.loaded['edge'] then
    require('edge').setup({})
  end
end)
