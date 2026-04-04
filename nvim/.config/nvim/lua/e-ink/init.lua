local M = {}

function M.setup()
   -- nothing needed for now
end

function M.load()
   vim.cmd("hi clear")
   if vim.fn.exists("syntax_on") == 1 then
      vim.cmd("syntax reset")
   end
   vim.g.colors_name = "e-ink"
   require("e-ink.syntax").generate_syntax()
end

return M
