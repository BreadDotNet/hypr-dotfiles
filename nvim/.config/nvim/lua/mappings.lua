require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

local api = require "nvim-tree.api"

map("n", "<C-b>", function()
  api.tree.open { current_window = true }
end, { noremap = true })
-- map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
