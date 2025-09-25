return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    config = true,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "go",
        "dart",
        "markdown_inline",
      },
    },
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },

  {
    "mfussenegger/nvim-dap",
    recommended = true,
    desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "williamboman/mason.nvim",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

  -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },

    config = function()
      local dap_go = require "dap-go"
      local dap = require "dap"
      local dap_ui = require "dapui"

      require("dapui").setup()

      dap_go.setup()
      -- For One
      table.insert(dap.configurations.go, {
        type = "delveone",
        name = "One CONTAINER debugging",
        mode = "remote",
        request = "attach",
        substitutePath = {
          { from = "/opt/homebrew/Cellar/go/1.23.1/libexec", to = "/usr/local/go" },
          { from = "${workspaceFolder}", to = "/path/in/container" },
        },
      })

      -- For Two
      table.insert(dap.configurations.go, {
        type = "delvetwo",
        name = "Two CONTAINER debugging",
        mode = "remote",
        request = "attach",
        substitutePath = {
          { from = "/opt/homebrew/Cellar/go/1.23.1/libexec", to = "/usr/local/go" },
          { from = "${workspaceFolder}", to = "/path/in/contianer" },
        },
      })

      -- adapters configuration
      dap.adapters.delveone = {
        type = "server",
        host = "127.0.0.1",
        port = "2345",
      }

      dap.adapters.delvetwo = {
        type = "server",
        host = "127.0.0.1",
        port = "2346",
      }

      dap.listeners.before.attach.dapui_config = function()
        dap_ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dap_ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dap_ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dap_ui.close()
      end
    end,
  },
}
