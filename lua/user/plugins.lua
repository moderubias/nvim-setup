-- ~/.config/nvim/lua/user/plugins.lua
return {
  ---------------------------------------------------------------------------
  -- Theme
  ---------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("user.colors").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- Icons
  ---------------------------------------------------------------------------
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      require("nvim-web-devicons").setup({ color_icons = true })
    end,
  },

  ---------------------------------------------------------------------------
  -- Statusline
  ---------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("user.statusline")
    end,
  },

  ---------------------------------------------------------------------------
  -- Bufferline
  ---------------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "tabs",
        always_show_bufferline = true,
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Treesitter
  ---------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        return
      end

      ts_configs.setup({
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- File explorer
  ---------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local icons = require("user.icons")

      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false,
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
          indent = { padding = 0 },
          icon = icons.tree_folder_icons,
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Telescope
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Diagnostics UI
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { focus = true },
  },

  ---------------------------------------------------------------------------
  -- Git signs
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 300 },
    },
  },

  ---------------------------------------------------------------------------
  -- Which-key
  ---------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    lazy = false,
    opts = { win = { border = "rounded" } },
  },

  ---------------------------------------------------------------------------
  -- Indent guides
  ---------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },

  ---------------------------------------------------------------------------
  -- Comments
  ---------------------------------------------------------------------------
  { "numToStr/Comment.nvim", main = "Comment", opts = {} },

  ---------------------------------------------------------------------------
  -- Autopairs
  ---------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  ---------------------------------------------------------------------------
  -- TODO comments
  ---------------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({ signs = true })
      pcall(function()
        require("telescope").load_extension("todo-comments")
      end)
    end,
  },

  ---------------------------------------------------------------------------
  -- Better UI
  ---------------------------------------------------------------------------
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        stages = "fade",
        render = "minimal",
      })
      vim.notify = notify
    end,
  },
  {
    "stevearc/dressing.nvim",
    opts = {
      input = { border = "rounded" },
      select = { backend = { "telescope", "builtin" } },
    },
  },

  ---------------------------------------------------------------------------
  -- Mason + LSPConfig
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "clangd", "pyright", "bashls", "rust_analyzer", "ts_ls" },
      automatic_installation = true,
    },
  },
  { "neovim/nvim-lspconfig", lazy = false },

  ---------------------------------------------------------------------------
  -- Completion
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })

      local ok_pairs, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
      if ok_pairs then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  {
      "iamcco/markdown-preview.nvim",
      build = "cd app && npm install",
      ft = { "markdown" },
  },

}
