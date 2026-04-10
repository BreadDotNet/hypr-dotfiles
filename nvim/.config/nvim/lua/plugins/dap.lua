return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
      local dap = require 'dap'

      -- Flutter adapter (uses flutter debug_adapter with full Flutter SDK)
      dap.adapters.flutter = {
        type = 'executable',
        command = 'flutter',
        args = { 'debug_adapter' },
      }

      -- Default launch config
      dap.configurations.dart = {
        {
          type = 'flutter',
          request = 'launch',
          name = 'Flutter: Launch',
          program = '${workspaceFolder}/lib/main.dart',
          cwd = '${workspaceFolder}',
        },
      }

      -- Keymaps
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue / Start' })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })

      -- Hot reload/restart via DAP custom requests
      vim.keymap.set('n', '<leader>dR', function()
        local session = dap.session()
        if session then
          session:request('hotReload', { reason = 'manual' }, function(err)
            if err then
              vim.notify('Hot reload failed: ' .. tostring(err), vim.log.levels.WARN)
            end
          end)
        end
      end, { desc = 'Debug: Hot Reload' })

      vim.keymap.set('n', '<leader>drs', function()
        local session = dap.session()
        if session then
          session:request('hotRestart', { reason = 'manual' }, function(err)
            if err then
              vim.notify('Hot restart failed: ' .. tostring(err), vim.log.levels.WARN)
            end
          end)
        end
      end, { desc = 'Debug: Hot Restart' })

      -- DAP-UI setup with auto open/close
      local dapui = require 'dapui'
      dapui.setup()

      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })

      -- nvim-dap-virtual-text setup
      require('nvim-dap-virtual-text').setup {}
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
