require 'core.options'
require 'core.keymaps'
require 'core.autocmds'
if vim.fn.filereadable(vim.fn.expand '~/.config/dotfiles/theme/nvim.lua') == 1 then
  require('dotfiles-theme').load()
end
require 'core.lazy'

-- vim: ts=2 sts=2 sw=2 et
