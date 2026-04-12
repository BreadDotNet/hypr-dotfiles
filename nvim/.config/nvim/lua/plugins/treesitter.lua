return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  build = ':TSUpdate',
  init = function()
    local ensureInstalled = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'css' }

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        if vim.bo.filetype ~= 'ruby' then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    local alreadyInstalled = require('nvim-treesitter.config').get_installed()
    local parsersToInstall = vim
      .iter(ensureInstalled)
      :filter(function(parser)
        return not vim.tbl_contains(alreadyInstalled, parser)
      end)
      :totable()

    if #parsersToInstall > 0 then
      require('nvim-treesitter').install(parsersToInstall)
    end
  end,
}

-- vim: ts=2 sts=2 sw=2 et
