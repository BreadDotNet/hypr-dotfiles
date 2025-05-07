local nvlsp = require "nvchad.configs.lspconfig"

require("flutter-tools").setup {
  flutter_path = "~/development/flutter/bin",
  lsp = {
    on_attach = nvlsp.on_attach,
    capabilities = nvlsp.capabilities,
  },
} -- use defaults
