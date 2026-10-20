return {
  init = function()
    vim.g.discord_presence = false
    vim.g.disable_autoformat = false
    vim.opt.guifont = "Iosevka Nerd Font:h13"
  end,
  plugins = {
    {
      "nvim-telescope/telescope.nvim",
      opts = { defaults = { layout_strategy = "vertical" } },
    },
  },
  setup = function()
    vim.opt.relativenumber = true
    vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
  end,
}
