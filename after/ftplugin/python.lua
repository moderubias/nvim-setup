vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
require("languages.python").setup_buffer(vim.api.nvim_get_current_buf())
