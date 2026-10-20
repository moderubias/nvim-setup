local treesitter_parsers = {
  "astro",
  "bash",
  "c",
  "cmake",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "gdscript",
  "gitcommit",
  "gitignore",
  "glsl",
  "go",
  "gomod",
  "gowork",
  "graphql",
  "groovy",
  "hlsl",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "jsonc",
  "latex",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "properties",
  "python",
  "query",
  "regex",
  "ron",
  "rust",
  "scss",
  "sql",
  "svelte",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "wgsl",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = function()
      require("nvim-treesitter").install(treesitter_parsers):wait(300000)
    end,
    opts = {
      ensure_installed = treesitter_parsers,
    },
    config = function(_, opts)
      require("nvim-treesitter").setup({})

      local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
      local latex_filetypes = {
        tex = true,
        plaintex = true,
        bib = true,
        cls = true,
        sty = true,
        dtx = true,
        ins = true,
      }
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if latex_filetypes[ft] then
            pcall(vim.treesitter.stop, args.buf)
          else
            pcall(vim.treesitter.start, args.buf)
          end
          if not latex_filetypes[ft] and ft ~= "markdown" and ft ~= "yaml" then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      vim.api.nvim_create_user_command("TSInstallConfigured", function()
        require("nvim-treesitter").install(opts.ensure_installed)
      end, {})
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
          enable_autocmd = false,
          languages = {
            astro = {
              __default = "<!-- %s -->",
              frontmatter = "// %s",
            },
          },
        },
      },
    },
    config = function()
      local ok, tscss = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      require("Comment").setup({
        pre_hook = ok and tscss.create_pre_hook() or nil,
      })
    end,
  },
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.ai", version = false, event = "VeryLazy", opts = {} },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup({ signs = true })
      pcall(function()
        require("telescope").load_extension("todo-comments")
      end)
    end,
  },
  {
    "NvChad/nvim-colorizer.lua",
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer" },
    keys = {
      {
        "<leader>uC",
        function()
          vim.g.stemdark_color_previews = not vim.g.stemdark_color_previews
          if vim.g.stemdark_color_previews then
            require("colorizer").attach_to_buffer(0)
          else
            require("colorizer").detach_from_buffer(0)
          end
        end,
        desc = "Toggle literal color previews",
      },
    },
    opts = {
      filetypes = {},
      user_default_options = {
        mode = "background",
        names = false,
        tailwind = true,
      },
    },
  },
}
