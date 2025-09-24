local ok, ls = pcall(require, 'luasnip')
if not ok then return end

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets('edge', {
  s('if', {
    t('@if('), i(1, 'condition'), t(')'),
    t({'', ''}), i(0),
    t({'', '@end'})
  }),

  s('ife', {
    t('@if('), i(1, 'condition'), t(')'),
    t({'', ''}), i(2),
    t({'', '@else', ''}), i(0),
    t({'', '@end'})
  }),

  s('each', {
    t('@each('), i(1, 'item in items'), t(')'),
    t({'', ''}), i(0),
    t({'', '@endeach'})
  }),

  s('layout', {
    t('@layout.'), i(1, 'app'), t({'('}), i(2, '{ title }'), t({')', ''}),
  }),

  -- HTML helpers
  s('a', { t('<a href="'), i(1, '#'), t('">'), i(0, 'link'), t('</a>') }),
  s('btn', { t('<button class="'), i(1,'px-4 py-2 rounded'), t('">'), i(0,'Button'), t('</button>') }),
})

-- Also load into html filetype for convenience
ls.add_snippets('html', ls.get_snippets('edge'))
