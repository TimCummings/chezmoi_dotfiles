-- linting tie-ins with LSP
require("null-ls").setup({
    sources = {
      require("null-ls").builtins.diagnostics.actionlint,
      require("null-ls").builtins.diagnostics.eslint,
      require("null-ls").builtins.diagnostics.rubocop,
      require("null-ls").builtins.diagnostics.shellcheck,
      require("null-ls").builtins.diagnostics.yamllint,
    },
})

-- use an on_attach function to only map the following keys after the language
-- server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Mappings
  -- local opts = { silent = true }
  local opts = { buffer = bufnr }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
  -- vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  -- vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  -- vim.keymap.set('n', '<Leader>wl', function()
  --   vim.inspect(vim.lsp.buf.list_workspace_folders())
  -- end, opts)
  -- vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.settings({
  ui = {
    icons = {
      server_installed = '??? ',
      server_pending = '??? ',
      server_uninstalled = '??? '
    }
  }
})

lsp_installer.on_server_ready(function(server)
  local opts = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  if server.name == 'sumneko_lua' then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  end
  server:setup(opts)
end)

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,menuone,noselect'

-- luasnip setup
local luasnip = require('luasnip')

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    -- ['<CR>'] = cmp.mapping.confirm {
    --   behavior = cmp.ConfirmBehavior.Replace,
    --   select = true,
    -- },

    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
    { name = 'orgmode' },
  }, {
    { name = 'buffer' },
    { name = 'nvim_lua' },
  })
})
