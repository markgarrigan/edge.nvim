vim.bo.commentstring = "<!-- %s -->"
vim.bo.expandtab = true
vim.bo.indentexpr = "v:lua.require('edge.indent').indent(v:lnum)"
