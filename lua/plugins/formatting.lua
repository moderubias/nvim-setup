return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        astro = { "prettier", lsp_format = "fallback" },
        bash = { "shfmt" },
        css = { "prettier" },
        groovy = { lsp_format = "fallback" },
        html = { "prettier" },
        java = { "google-java-format", lsp_format = "fallback" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        cls = { "latexindent" },
        sty = { "latexindent" },
        dtx = { "latexindent" },
        ins = { "latexindent" },
        tex = { "latexindent" },
        plaintex = { "latexindent" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        scss = { "prettier" },
        sh = { "shfmt" },
        svelte = { "prettier" },
        toml = { "taplo" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        xml = { "prettier", lsp_format = "fallback" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        if
          vim.bo[bufnr].filetype ~= "python"
          or vim.bo[bufnr].buftype ~= ""
          or vim.g.disable_autoformat
          or vim.b[bufnr].disable_autoformat
          or vim.api.nvim_buf_line_count(bufnr) > 10000
        then
          return
        end
        return { timeout_ms = 1500, lsp_format = "never" }
      end,
      formatters = {
        shfmt = { prepend_args = { "-i", "4", "-ci" } },
        prettier = {
          prepend_args = function(self, ctx)
            if ctx.filename:match("%.astro$") then
              local astro_plugin = vim.fn.stdpath("data")
                .. "/mason/packages/prettier/node_modules/prettier-plugin-astro/dist/index.js"
              if vim.uv.fs_stat(astro_plugin) then
                return { "--plugin", astro_plugin }
              end
            end
            return {}
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { bash = { "shellcheck" }, sh = { "shellcheck" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("UserLint", { clear = true }),
        callback = function(args)
          if
            vim.bo[args.buf].buftype ~= ""
            or not lint.linters_by_ft[vim.bo[args.buf].filetype]
            or vim.fn.executable("shellcheck") ~= 1
          then
            return
          end
          vim.api.nvim_buf_call(args.buf, function()
            lint.try_lint(nil, { ignore_errors = true })
          end)
        end,
      })
    end,
  },
}
