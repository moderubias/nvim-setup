vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
if vim.fn.has("nvim-0.12") == 1 then
  vim.g.no_markdown_maps = 1
end

local o = vim.opt

vim.cmd("filetype plugin indent on")
if vim.filetype and vim.filetype.on then
  vim.filetype.on()
end

o.termguicolors = true
o.guifont = "Iosevka Nerd Font:h13"
o.mouse = "a"
o.number = true
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.cursorlineopt = "both"
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
o.wrap = false
o.linebreak = true
o.scrolloff = 6
o.sidescrolloff = 6
o.showmode = false
o.laststatus = 3
o.showtabline = 1
o.pumblend = 0
o.pumheight = 12
o.foldcolumn = "1"
o.foldenable = true
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldmethod = "expr"

o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.completeopt = { "menu", "menuone", "noselect" }
o.fillchars = {
  eob = " ",
  fold = " ",
  foldclose = "▸",
  foldopen = "▾",
  foldsep = " ",
  horiz = "─",
  horizdown = "┬",
  horizup = "┴",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
o.list = false
o.listchars = {
  tab = "│ ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}

o.ignorecase = true
o.smartcase = true
o.updatetime = 200
o.timeoutlen = 350

o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"
o.confirm = true
o.autoread = true
o.undofile = true
o.swapfile = false
o.backup = false
o.writebackup = false
o.inccommand = "split"
o.jumpoptions = "view"
o.sessionoptions = { "curdir", "folds", "help", "tabpages", "winsize", "terminal", "globals" }
o.diffopt:append("linematch:60")

local function executable(name)
  return vim.fn.executable(name) == 1
end

if vim.env.WAYLAND_DISPLAY and executable("wl-copy") and executable("wl-paste") then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
    paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
    cache_enabled = 1,
  }
  o.clipboard = "unnamedplus"
elseif vim.env.DISPLAY and executable("xclip") then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 1,
  }
  o.clipboard = "unnamedplus"
end

vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildoptions = "pum"
if executable("rg") then
  o.grepprg = "rg --vimgrep --smart-case --hidden"
  o.grepformat = "%f:%l:%c:%m"
end
vim.cmd.syntax("on")
pcall(function()
  o.winborder = "rounded"
end)
pcall(function()
  o.smoothscroll = true
end)

vim.g.have_nerd_font = true
