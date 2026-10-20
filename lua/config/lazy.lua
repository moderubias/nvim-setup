local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

local spec = { { import = "plugins" } }
vim.list_extend(spec, require("config.custom").plugins or {})

require("lazy").setup(spec, {
  defaults = { lazy = true },
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "matchit",
        "netrw",
        "netrwPlugin",
        "rrhelper",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zip",
        "zipPlugin",
      },
    },
  },
})
