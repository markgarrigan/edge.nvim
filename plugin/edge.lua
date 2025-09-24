-- edge.nvim: plugin entrypoint
-- - extend html-ls to include 'edge'
-- - register treesitter mapping (edge -> html)
-- - call setup() with defaults if user hasn't

-- Extend html-ls
pcall(function()
  vim.lsp.config.html = vim.tbl_deep_extend('force', vim.lsp.config.html or {}, {
    filetypes = { 'html', 'edge' },
    init_options = { provideFormatter = true },
  })
  vim.lsp.enable('html')
end)

-- Treesitter mapping (optional)
pcall(function()
  vim.treesitter.language.register('html', 'edge')
end)

-- Auto-setup with defaults if not already required by user
pcall(function()
  if not package.loaded['edge'] then
    require('edge').setup({})
  end
end)
