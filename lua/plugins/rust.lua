return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false,
    init = function()
      require("languages.rust").setup()
    end,
  },
  {
    "Saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml", "BufNewFile Cargo.toml" },
    config = function()
      local crates = require("crates")
      crates.setup({
        completion = { cmp = { enabled = false } },
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
        popup = { autofocus = true, border = "rounded" },
      })

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("UserCargoActions", { clear = true }),
        pattern = "Cargo.toml",
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
          end
          map("<leader>rc", crates.show_popup, "Crate details")
          map("<leader>rf", crates.show_features_popup, "Crate features")
          map("<leader>rv", crates.show_versions_popup, "Crate versions")
          map("<leader>ru", crates.update_crate, "Update crate")
          map("<leader>rU", crates.upgrade_crate, "Upgrade crate")
          map("<leader>rA", crates.upgrade_all_crates, "Upgrade all crates")
        end,
      })
    end,
  },
}
