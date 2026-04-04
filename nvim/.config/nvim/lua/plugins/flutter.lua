return {
  'nvim-flutter/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim',
    'saghen/blink.cmp',
  },
  config = function()
    require('flutter-tools').setup {}
  end,
}

-- vim: ts=2 sts=2 sw=2 et
