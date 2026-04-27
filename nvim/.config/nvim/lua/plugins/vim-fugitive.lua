return {
  'tpope/vim-fugitive',
  keys = {
    { '<leader>gs', vim.cmd.Git, desc = 'Git Status' },
    { '<leader>gd', vim.cmd.Gdiffsplit, desc = 'Git diff current file' },
  },
}
