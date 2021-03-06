local M = {}

function M.setup()
  -- Load custom tree-sitter grammar for org filetype
  require('orgmode').setup_ts_grammar()

  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'bash',
      'css',
      'dockerfile',
      'go',
      'graphql',
      'html',
      'javascript',
      'json',
      'lua',
      'org',
      'ruby',
      'rust',
      'scss',
      'typescript',
      'yaml',
    },
    highlight = {
      enable = true,              -- false will disable the whole extension
      disable = { 'org' },        -- TS highlighthing is still experimental
      additional_vim_regex_highlighting = { 'org' }, -- TS doesn't support all features, eg. conceal
    },
    indent = {
      enable = false,
    },
  })
end

return M
