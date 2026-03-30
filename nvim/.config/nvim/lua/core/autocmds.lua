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

-- Sync e-ink theme on SIGUSR1 (sent by theme/switch.sh)
vim.api.nvim_create_autocmd('Signal', {
  pattern = 'SIGUSR1',
  group = vim.api.nvim_create_augroup('e-ink-theme-sync', { clear = true }),
  callback = function()
    local f = io.open(vim.fn.expand '~/.cache/e-ink-theme', 'r')
    if f then
      local mode = f:read('*l')
      f:close()
      if mode == 'light' or mode == 'dark' then
        vim.o.background = mode
      end
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
