local util = require 'lspconfig.util'
local configs = require 'lspconfig.configs'
configs['unocss'] = { default_config = {
  cmd = { 'unocss-language-server', '--stdio' },
  filetypes = {
    'html',
    'javascriptreact',
    'rescript',
    'typescriptreact',
    'vue',
    'svelte',
  },
  on_new_config = function(new_config)
  end,
  root_dir = function(fname)
    return util.root_pattern('unocss.config.js', 'unocss.config.ts')(fname)
  end,
} }
