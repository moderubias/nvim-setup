return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    opts = {
      color_icons = true,
      default = true,
      strict = true,
      variant = "dark",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("ui.statusline")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local p = require("theme.palette")
      return {
        options = {
          mode = "buffers",
          sort_by = "id",
          persist_buffer_sort = false,
          always_show_bufferline = false,
          auto_toggle_bufferline = false,
          custom_filter = function(bufnr)
            return require("ui.buffers").is_visible(bufnr)
          end,
          close_command = function(bufnr)
            require("ui.buffers").close(bufnr)
          end,
          right_mouse_command = function(bufnr)
            require("ui.buffers").close(bufnr)
          end,
          diagnostics = "nvim_lsp",
          indicator = { style = "underline" },
          separator_style = "thin",
          show_buffer_close_icons = true,
          show_close_icon = false,
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
          },
        },
        highlights = {
          fill = { bg = p.bg },
          background = { fg = p.muted, bg = p.bg },
          buffer_visible = { fg = p.fg_dim, bg = p.bg },
          buffer_selected = { fg = p.fg_alt, bg = p.bg, bold = true, italic = false, underline = true, sp = p.accent },
          separator = { fg = p.bg, bg = p.bg },
          separator_visible = { fg = p.bg, bg = p.bg },
          separator_selected = { fg = p.bg, bg = p.bg },
          indicator_selected = { fg = p.accent, bg = p.bg, underline = true, sp = p.accent },
          indicator_visible = { fg = p.bg, bg = p.bg },
          modified = { fg = p.rose, bg = p.bg },
          modified_visible = { fg = p.rose, bg = p.bg },
          modified_selected = { fg = p.rose, bg = p.bg },
          close_button = { fg = p.muted, bg = p.bg },
          close_button_visible = { fg = p.fg_dim, bg = p.bg },
          close_button_selected = { fg = p.rose, bg = p.bg },
          tab = { fg = p.muted, bg = p.bg },
          tab_selected = { fg = p.fg_alt, bg = p.bg, underline = true, sp = p.accent },
          tab_separator = { fg = p.bg, bg = p.bg },
          tab_separator_selected = { fg = p.bg, bg = p.bg },
          diagnostic = { fg = p.muted, bg = p.bg },
          diagnostic_visible = { fg = p.fg_dim, bg = p.bg },
          diagnostic_selected = { fg = p.fg_alt, bg = p.bg, bold = true },
          hint_diagnostic_selected = { fg = p.hint, bg = p.bg, bold = true },
          info_diagnostic_selected = { fg = p.info, bg = p.bg, bold = true },
          warning_diagnostic_selected = { fg = p.warn, bg = p.bg, bold = true },
          error_diagnostic_selected = { fg = p.error, bg = p.bg, bold = true },
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = { border = "rounded" },
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug/docs" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>j", group = "java/android" },
        { "<leader>l", group = "latex" },
        { "<leader>n", group = "notebook" },
        { "<leader>p", group = "python" },
        { "<leader>q", group = "sessions" },
        { "<leader>r", group = "research/rust" },
        { "<leader>s", group = "search/replace" },
        { "<leader>t", group = "tools" },
        { "<leader>u", group = "ui" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      local p = require("theme.palette")
      notify.setup({
        background_colour = p.bg2,
        render = "minimal",
        stages = "fade",
      })
      vim.notify = notify
    end,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = { border = "rounded" },
      select = { backend = { "telescope", "builtin" } },
    },
  },
  {
    "vyfor/cord.nvim",
    enabled = vim.g.discord_presence ~= false,
    build = ":Cord update",
    lazy = false,
    config = function()
      require("ui.discord").setup()
    end,
  },
}
