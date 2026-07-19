-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- The CLI atomically replaces ~/.config/dotfiles/theme. Checking the resolved
-- runtime path avoids sending signals that could terminate an older Neovim
-- session which has not loaded this handler yet.
vim.api.nvim_create_autocmd({ 'FocusGained', 'CursorHold', 'TermLeave' }, {
  desc = 'Reload the generated dotfiles theme after a runtime switch',
  group = vim.api.nvim_create_augroup('dotfiles-theme-sync', { clear = true }),
  callback = function()
    require('dotfiles-theme').reload_if_changed()
  end,
})

-- vim: ts=2 sts=2 sw=2 et
