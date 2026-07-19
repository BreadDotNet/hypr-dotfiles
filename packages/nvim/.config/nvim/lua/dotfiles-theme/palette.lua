local M = {}

function M.get()
  local path = vim.fn.expand '~/.config/dotfiles/theme/nvim.lua'
  local chunk, load_error = loadfile(path)
  if not chunk then
    error(('Cannot load generated dotfiles theme %s: %s'):format(path, load_error))
  end

  local ok, palette = pcall(chunk)
  if not ok or type(palette) ~= 'table' then
    error(('Invalid generated dotfiles theme %s: %s'):format(path, palette))
  end
  return palette
end

return M
