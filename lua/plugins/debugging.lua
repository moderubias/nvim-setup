return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
      { [[<C-\>]], "<cmd>ToggleTerm direction=float<CR>", mode = { "n", "t" }, desc = "Toggle terminal" },
    },
    opts = {
      direction = "float",
      float_opts = { border = "rounded" },
      shade_terminals = false,
      start_in_insert = true,
    },
  },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug continue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug UI",
      },
    },
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("nvim-dap-virtual-text").setup({})
      dapui.setup({ floating = { border = "rounded" } })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      local function mason_path(package)
        local ok_registry, registry = pcall(require, "mason-registry")
        if not ok_registry then
          return nil
        end
        local ok_package, pkg = pcall(registry.get_package, package)
        if not ok_package or not pkg:is_installed() then
          return nil
        end
        return pkg:get_install_path()
      end

      local debugpy = mason_path("debugpy")
      local python = debugpy and (debugpy .. "/venv/bin/python") or vim.fn.exepath("python3")
      local ok_python = pcall(require, "dap-python")
      if ok_python then
        require("languages.python").setup_dap(python ~= "" and python or "python")
      end

      local codelldb = mason_path("codelldb")
      local adapter = codelldb and (codelldb .. "/extension/adapter/codelldb")
      if adapter and vim.fn.executable(adapter) == 1 then
        dap.adapters.codelldb = {
          type = "server",
          port = "${port}",
          executable = {
            command = adapter,
            args = { "--port", "${port}" },
          },
        }
        local native = {
          {
            name = "Launch executable",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        }
        dap.configurations.c = native
        dap.configurations.cpp = native
        dap.configurations.rust = native
      end
    end,
  },
}
