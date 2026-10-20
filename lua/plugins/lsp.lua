return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "Mason", "LspRefresh" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })

      require("mason-lspconfig").setup({
        ensure_installed = {},
        automatic_enable = false,
      })

      require("lsp").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
    opts = {
      ensure_installed = {
        "astro",
        "bashls",
        "clangd",
        "cssls",
        "emmet_language_server",
        "eslint",
        "glsl_analyzer",
        "html",
        "jdtls",
        "jsonls",
        "lua_ls",
        "marksman",
        "pyright",
        "ruff",
        "texlab",
        "tailwindcss",
        "taplo",
        "ts_ls",
        "yamlls",
        "rust_analyzer",
        "codelldb",
        "debugpy",
        "google-java-format",
        "java-debug-adapter",
        "java-test",
        "prettier",
        "shellcheck",
        "shfmt",
        "stylua",
      },
      auto_update = false,
      run_on_start = false,
      start_delay = 3000,
    },
  },
}
