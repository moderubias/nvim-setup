return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "markdown.mdx" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preset = "obsidian",
      render_modes = { "n", "c", "t" },
      anti_conceal = { enabled = true, above = 0, below = 0 },
      file_types = { "markdown", "markdown.mdx" },
      code = {
        width = "block",
        border = "none",
        language_border = " ",
        left_pad = 1,
        right_pad = 1,
        sign = false,
      },
    },
  },
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    ft = { "markdown", "markdown.mdx" },
    opts = { border = "rounded" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>uz", "<cmd>ZenMode<CR>", desc = "Zen mode" } },
    opts = {
      window = {
        backdrop = 0.92,
        width = function()
          return math.max(1, math.min(82, vim.o.columns - 4))
        end,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = true,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = { enabled = true, ruler = false, showcmd = false },
        gitsigns = { enabled = false },
        tmux = { enabled = false },
        kitty = { enabled = false },
      },
    },
  },
  {
    "lervag/vimtex",
    ft = { "tex", "plaintex", "bib", "cls", "sty", "dtx", "ins" },
    init = function()
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_complete_enabled = 1
      vim.g.vimtex_complete_close_braces = 1
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_automatic = 1
      vim.g.vimtex_view_forward_search_on_start = 1
      vim.g.vimtex_view_zathura_use_synctex = 1
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-xelatex",
        pdflatex = "-pdf",
        lualatex = "-lualatex",
        luatex = "-lualatex",
        xelatex = "-xelatex",
      }
      vim.g.vimtex_compiler_latexmk = {
        out_dir = "build",
        callback = 1,
        continuous = 1,
        options = {
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_compiler_silent = 1
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_autojump = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        texTabularChar = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
    end,
  },
  {
    "3rd/image.nvim",
    cond = function()
      return #vim.api.nvim_list_uis() > 0 and vim.env.KITTY_WINDOW_ID ~= nil and vim.fn.executable("magick") == 1
    end,
    ft = { "markdown", "vimwiki", "html", "css" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          floating_windows = false,
          only_render_image_at_cursor = false,
          only_render_image_at_cursor_mode = "popup",
          filetypes = { "markdown", "vimwiki" },
        },
        html = { enabled = true },
        css = { enabled = true },
      },
      max_width_window_percentage = 80,
      max_height_window_percentage = 60,
      hijack_file_patterns = {
        "*.png",
        "*.jpg",
        "*.jpeg",
        "*.gif",
        "*.webp",
        "*.avif",
        "*.svg",
        "*.ico",
        "*.PNG",
        "*.JPG",
        "*.JPEG",
        "*.GIF",
        "*.WEBP",
        "*.AVIF",
        "*.SVG",
        "*.ICO",
      },
    },
  },
}
