-- EdgeJS ftplugin
vim.bo.commentstring = "<!-- %s -->"
vim.bo.shiftwidth = (vim.bo.shiftwidth > 0) and vim.bo.shiftwidth or 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
vim.bo.smartindent = false
vim.bo.autoindent = false

-- Single source of truth for indent: edge.indent.indent(lnum)
vim.bo.indentexpr = "v:lua.require('edge.indent').indent(v:lnum)"

-- Enter key: accept completion or insert newline (indentexpr handles indent)
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, buffer = true })

-- Format Edge buffer
vim.keymap.set('n', '<leader>fe', function()
  vim.lsp.buf.format({ async = false })
end, { buffer = true, desc = 'Format Edge file' })
