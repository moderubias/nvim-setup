-- ~/.config/nvim/lua/user/options.lua
local o = vim.opt

-- Ensure filetype detection and related plugins are enabled.
vim.cmd("filetype plugin indent on")
if vim.filetype and vim.filetype.on then
  vim.filetype.on()
end

o.termguicolors = true
o.number = true
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.wrap = false
o.scrolloff = 6
o.sidescrolloff = 6
o.showmode = false
o.laststatus = 3
o.showtabline = 2
o.pumblend = 8

o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.completeopt = { "menu", "menuone", "noselect" }

o.ignorecase = true
o.smartcase = true
o.updatetime = 250
o.timeoutlen = 400

o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"

-- системный clipboard (Wayland)
vim.g.clipboard = {
  name = "wl-clipboard",
  copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
  paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
  cache_enabled = 1,
}

vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildoptions = "pum"
vim.cmd.syntax("on")

vim.g.have_nerd_font = true
