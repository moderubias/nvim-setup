return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local icons = require("ui.icons")
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true,
          group_empty_dirs = true,
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_hidden = true,
            never_show = { ".git", ".cache", "node_modules", "target", ".gradle", ".DS_Store", "thumbs.db" },
          },
          components = {
            dir_icon = function(_, node)
              local item = icons.get_folder_icon(node.name or "")
              return { text = item.icon .. " ", highlight = item.hl }
            end,
          },
          renderers = {
            directory = {
              { "indent" },
              { "dir_icon" },
              { "name" },
              { "git_status" },
            },
            file = {
              { "indent" },
              { "icon" },
              { "name" },
              { "git_status" },
            },
          },
        },
        default_component_configs = {
          indent = { padding = 0, with_expanders = true },
          icon = icons.tree_folder_icons,
        },
        window = {
          width = 34,
        },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
      extensions = {
        ["ui-select"] = {},
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      opts.extensions["ui-select"] = require("telescope.themes").get_dropdown({})
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 300 },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { focus = true },
  },
  { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread" } },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
