return {
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local api = require("dropbar.api")
      vim.keymap.set("n", "<leader>;", api.pick, { desc = "Pick breadcrumb" })
      vim.keymap.set("n", "[;", api.goto_context_start, { desc = "Context start" })
      vim.keymap.set("n", "];", api.select_next_context, { desc = "Next context" })
    end,
  },
  {
    "j-hui/fidget.nvim",
    version = "*",
    event = "LspAttach",
    opts = {
      progress = {
        suppress_on_insert = true,
        display = {
          done_icon = "󰄬",
          progress_icon = { "dots" },
          render_limit = 4,
        },
      },
      notification = {
        override_vim_notify = false,
        window = {
          border = "rounded",
          normal_hl = "NormalFloat",
          winblend = 0,
          avoid = { "dapui_scopes", "neo-tree", "neotest-summary" },
        },
      },
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore project session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Do not save session",
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {
      headerMaxWidth = 72,
      transient = true,
      windowCreationCommand = "botright vsplit",
    },
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open({ transient = true })
        end,
        mode = { "n", "x" },
        desc = "Search and replace project",
      },
      {
        "<leader>sw",
        function()
          require("grug-far").open({
            transient = true,
            prefills = { search = vim.fn.expand("<cword>") },
          })
        end,
        desc = "Replace word under cursor",
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
    opts = {
      strategy = { "toggleterm", direction = "horizontal", quit_on_exit = "success" },
      task_list = {
        direction = "bottom",
        min_height = 10,
        max_height = 18,
      },
    },
    keys = {
      { "<leader>tr", "<cmd>OverseerRun<CR>", desc = "Run task" },
      { "<leader>tt", "<cmd>OverseerToggle<CR>", desc = "Task list" },
    },
  },
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      highlight = { timer = 180 },
      ring = { history_length = 80, storage = "shada", sync_with_numbered_registers = true },
      system_clipboard = { sync_with_ring = true },
    },
    keys = {
      { "<leader>fy", "<cmd>YankyRingHistory<CR>", mode = { "n", "x" }, desc = "Yank history" },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after and move" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before and move" },
      { "]y", "<Plug>(YankyNextEntry)", desc = "Next yank" },
      { "[y", "<Plug>(YankyPreviousEntry)", desc = "Previous yank" },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      preview = { auto_preview = true, border = "rounded", show_title = true },
    },
  },
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = { auto_cmd = true, override_editorconfig = false },
  },
}
