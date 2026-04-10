return {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',
    'saghen/blink.cmp',
  },
  config = function()
    require('flutter-tools').setup {
      lsp = {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
        settings = {
          analysisExcludedFolders = {
            vim.fn.expand '$HOME/.pub-cache',
            vim.fn.expand '$HOME/fvm',
          },
          completeFunctionCalls = true,
          renameFilesWithClasses = 'prompt',
          updateImportsOnRename = true,
        },
      },
    }
  end,
}

-- vim: ts=2 sts=2 sw=2 et
