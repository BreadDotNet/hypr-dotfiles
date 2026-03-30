local function read_theme()
  local f = io.open(vim.fn.expand '~/.cache/e-ink-theme', 'r')
  if f then
    local mode = f:read('*l')
    f:close()
    if mode == 'light' or mode == 'dark' then
      return mode
    end
  end
  return 'dark'
end

return {
  'e-ink-colorscheme/e-ink.nvim',
  priority = 1000,
  config = function()
    require('e-ink').setup()
    vim.cmd.colorscheme 'e-ink'
    vim.o.background = read_theme()
  end,
}

-- vim: ts=2 sts=2 sw=2 et
