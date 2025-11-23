require("nvchad.configs.lspconfig").defaults()
local nvlsp = require "nvchad.configs.lspconfig"

-- Базовая конфигурация для всех серверов
local base_config = {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}

-- HTML, CSS, JSON серверы с дефолтной конфигурацией
for _, lsp in ipairs { "html", "cssls", "jsonls" } do
  vim.lsp.config[lsp] = base_config
  vim.lsp.enable(lsp)
end

-- Go
vim.lsp.config.gopls = vim.tbl_extend("force", base_config, {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = { unusedparams = true },
    },
  },
})
vim.lsp.enable "gopls"

-- Bash
vim.lsp.config.bashls = vim.tbl_extend("force", base_config, {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
})
vim.lsp.enable "bashls"
