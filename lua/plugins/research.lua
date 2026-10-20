return {
  {
    "nvim-neotest/neotest",
    cmd = "Neotest",
    dependencies = {
      "mrcjkb/rustaceanvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("rustaceanvim.neotest"),
          require("languages.python").neotest_adapter(),
        },
        discovery = { concurrent = 1 },
        floating = { border = "rounded", max_height = 0.75, max_width = 0.8 },
        output = { enabled = true, open_on_run = "short" },
        quickfix = { enabled = true, open = false },
        running = { concurrent = true },
        summary = { animated = true, follow = true, open = "botright vsplit | vertical resize 42" },
      })
    end,
    keys = {
      {
        "<leader>tT",
        function()
          require("neotest").run.run()
        end,
        desc = "Test nearest",
      },
      {
        "<leader>tF",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test file",
      },
      {
        "<leader>tA",
        function()
          local root = require("features.workspace").root()
          require("neotest").run.run(root)
        end,
        desc = "Test project",
      },
      {
        "<leader>tD",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Test output",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Test output panel",
      },
      {
        "<leader>tx",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop test",
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      options = {
        cached_venv_automatic_activation = false,
        set_environment_variables = false,
        activate_venv_in_terminal = false,
        notify_user_on_venv_activation = true,
        on_venv_activate_callback = function()
          local python = require("venv-selector").python()
          if python then
            require("languages.python").select_interpreter(python)
          end
        end,
      },
    },
    keys = { { "<leader>rv", "<cmd>VenvSelect<CR>", desc = "Select Python environment" } },
  },
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    cmd = {
      "MoltenInit",
      "MoltenEvaluateLine",
      "MoltenEvaluateVisual",
      "MoltenReevaluateCell",
      "MoltenShowOutput",
      "MoltenInterrupt",
      "MoltenDelete",
      "MoltenDeinit",
    },
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = vim.env.KITTY_WINDOW_ID and "image.nvim" or "none"
      vim.g.molten_limit_output_chars = 30000
      vim.g.molten_output_show_more = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_output_win_max_height = 18
      vim.g.molten_output_win_max_width = 100
      vim.g.molten_tick_rate = 300
      vim.g.molten_use_border_highlights = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 12
    end,
    keys = {
      { "<leader>ni", "<cmd>MoltenInit<CR>", desc = "Initialize kernel" },
      { "<leader>nl", "<cmd>MoltenEvaluateLine<CR>", desc = "Evaluate line" },
      { "<leader>ne", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Evaluate selection" },
      { "<leader>nr", "<cmd>MoltenReevaluateCell<CR>", desc = "Re-evaluate cell" },
      { "<leader>no", "<cmd>MoltenShowOutput<CR>", desc = "Show cell output" },
      { "<leader>nx", "<cmd>MoltenInterrupt<CR>", desc = "Interrupt kernel" },
      { "<leader>nd", "<cmd>MoltenDelete<CR>", desc = "Delete cell" },
      { "<leader>nq", "<cmd>MoltenDeinit<CR>", desc = "Stop kernel" },
    },
  },
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    cmd = { "CsvViewDisable", "CsvViewEnable", "CsvViewToggle" },
    opts = {
      parser = { comments = { "#", "//" }, async_chunksize = 50 },
      view = {
        display_mode = "border",
        header_lnum = true,
        min_column_width = 5,
        spacing = { left = 1, right = 1 },
        sticky_header = { enabled = true, separator = "─" },
      },
    },
    keys = { { "<leader>uv", "<cmd>CsvViewToggle<CR>", desc = "Toggle CSV table" } },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIAddConnection", "DBUIFindBuffer", "DBUIToggle" },
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_win_position = "right"
      vim.g.db_ui_winwidth = 42
    end,
    keys = { { "<leader>tq", "<cmd>DBUIToggle<CR>", desc = "Database UI" } },
  },
}
