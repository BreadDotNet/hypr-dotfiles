local M = {}

local function runtime_identity()
   local uv = vim.uv or vim.loop
   local runtime = vim.fn.expand("~/.config/dotfiles/theme")
   return (uv and uv.fs_realpath(runtime)) or runtime
end

function M.setup()
   -- nothing needed for now
end

function M.load()
   local palette = require("dotfiles-theme.palette").get()
   vim.cmd("hi clear")
   if vim.fn.exists("syntax_on") == 1 then
      vim.cmd("syntax reset")
   end
   vim.o.background = palette.appearance == "dark" and "dark" or "light"
   vim.g.colors_name = palette.name or "dotfiles-theme"
   require("dotfiles-theme.syntax").generate_syntax()
   M._runtime_identity = runtime_identity()
end

function M.reload_if_changed()
   local identity = runtime_identity()
   if identity and identity ~= M._runtime_identity then
      local ok, err = pcall(M.load)
      if not ok then
         vim.notify("Could not reload dotfiles theme: " .. tostring(err), vim.log.levels.ERROR)
         return
      end
      vim.cmd("redraw!")
   end
end

return M
