vim.cmd [[set expandtab]]
-- expand a inserted <Tab> to two spaces
vim.cmd [[set softtabstop=2]]
-- a real <Tab> looks like two spaces
vim.cmd [[set tabstop=2]]
-- for intend
vim.cmd [[set shiftwidth=2]]
--vim.cmd [[set foldmethod=indent]]

vim.cmd [[let mapleader="\<space>"]]

local key_pairs = {['['] = ']', ['('] = ')', ['{'] = '}'}
for k, v in pairs(key_pairs) do
  local opts = {noremap = true, silent = true}
  vim.api.nvim_set_keymap('i', k, k .. v .. '<ESC>i', opts)
  vim.api.nvim_set_keymap('i', v, 'getline(".")[col(".") - 1] == "' .. v ..
                              '" ? "\\<ESC>la" : "' .. v .. '"', {expr = true})

end

vim.cmd [[inoremap <expr> ' getline('.')[col('.')-1] == "'" ? '<ESC>la' : "''\<ESC>i"]]
vim.cmd [[inoremap <expr> " getline('.')[col('.')-1] == '"' ? '<ESC>la' : '""<ESC>i']]
-- vim.cmd [[inoremap [ []<ESC>i]]
-- vim.cmd [[inoremap ( ()<ESC>i]]
-- vim.cmd [[inoremap { {}<ESC>i]]

vim.cmd [[nnoremap <expr> <leader>t NERDTree.IsOpen() == 0 ? ":NERDTreeFind<CR>" : ":NERDTreeToggle<CR>"]]

local use = require('packer').use
require('packer').startup(function()
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin

  use 'preservim/nerdtree'
  use 'tpope/vim-surround'
  use 'tomasiser/vim-code-dark'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
end)

-- vim.cmd [[colorscheme codedark]]

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')
symbol = require('symbol')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = {noremap = true, silent = true}

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa',
                 '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr',
                 '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl',
                 '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
                 opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
                 opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                 opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>',
                 opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>',
                 opts)
  --- 
  buf_set_keymap('n', '<leader>f',
                 '<cmd>lua vim.lsp.buf.formatting({tabSize = 2, convertTabsToSpaces = true, semicolons = "insert"})<CR>',
                 opts)
  buf_set_keymap('n', '<leader>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)

  buf_set_keymap('n', '[f','<cmd>lua symbol.prev(12, "start")<CR>', opts)
  buf_set_keymap('n', ']f','<cmd>lua symbol.next(12, "start")<CR>', opts)
  buf_set_keymap('n', '[F','<cmd>lua symbol.prev(12, "end")<CR>', opts)
  buf_set_keymap('n', ']F','<cmd>lua symbol.next(12, "end")<CR>', opts)
  buf_set_keymap('n', '[c','<cmd>lua symbol.prev(14, "start")<CR>', opts)
  buf_set_keymap('n', ']c','<cmd>lua symbol.next(14, "start")<CR>', opts)
  buf_set_keymap('n', '[C','<cmd>lua symbol.prev(14, "end")<CR>', opts)
  buf_set_keymap('n', ']C','<cmd>lua symbol.next(14, "end")<CR>', opts)
  buf_set_keymap('n', '[p','<cmd>lua symbol.prev(7, "start")<CR>', opts)
  buf_set_keymap('n', ']p','<cmd>lua symbol.next(7, "start")<CR>', opts)
end

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = {
  'clangd', 'rust_analyzer', 'pyright', 'tsserver', 'sumneko_lua', 'tailwindcss'
}
local settings = {
  sumneko_lua = {
    Lua = {
      completion = {keywordSnippet = "Disable"},
      diagnostics = {globals = {"vim", "use"}, disable = {"lowercase-global"}},
      runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
        }
      }
    }
  }
}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = settings[lsp]
  }
end

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'

cmp.setup {
  snippet = {
    expand = function(args) require('luasnip').lsp_expand(args.body) end
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    },
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
    end
  },
  sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}}
}

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "tsx" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ap"] = "@parameter.outer",
        ["ip"] = "@parameter.inner",
      },
    },
  },
}
