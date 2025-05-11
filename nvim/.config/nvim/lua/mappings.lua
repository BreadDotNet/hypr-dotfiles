require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Add LSP code action mappings
map("n", "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP Code Action" })

map("v", "<leader>ca", function()
  vim.lsp.buf.range_code_action()
end, { desc = "LSP Range Code Action" })

map("n", "<leader>sr", function()
  vim.lsp.buf.references()
end, { desc = "Show references" })
