vim.bo.commentstring = "<!-- %s -->"
vim.bo.shiftwidth = (vim.bo.shiftwidth > 0) and vim.bo.shiftwidth or 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
vim.bo.smartindent = false
vim.bo.autoindent = false

vim.bo.indentexpr = "v:lua.require('edge.indent').indent(v:lnum)"

vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, buffer = true })

vim.keymap.set('n', '<leader>fe', function()
  vim.lsp.buf.format({ async = false })
end, { buffer = true, desc = 'Format Edge file' })
