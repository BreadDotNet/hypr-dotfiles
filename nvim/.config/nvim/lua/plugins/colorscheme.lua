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

-- e-ink is a local module in lua/e-ink/, not a lazy.nvim plugin.
-- Load it directly at startup with highest priority.
vim.o.background = read_theme()
require('e-ink').load()

return {}

-- vim: ts=2 sts=2 sw=2 et
