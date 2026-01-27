-- ~/.config/nvim/lua/user/colors.lua
local M = {}

function M.setup()
  local p = require("user.palette")
  local ok, catppuccin = pcall(require, "catppuccin")
  if not ok then
    return
  end

  catppuccin.setup({
    flavour = "mocha",
    transparent_background = false,
    term_colors = true,
    color_overrides = {
      mocha = {
        base = p.bg,
        mantle = p.bg2,
        crust = p.bg,
        text = p.fg,
        subtext1 = p.fg_dim,
        subtext0 = p.comment,
        overlay2 = p.fg_dim,
        overlay1 = p.comment,
        overlay0 = p.comment,
        surface2 = p.sel_bg,
        surface1 = p.panel,
        surface0 = p.panel,
        mauve = p.purple2,
        lavender = p.purple,
        pink = p.magenta,
        red = p.error,
        maroon = p.error,
        peach = p.magenta,
        yellow = p.magenta,
        green = p.purple3,
        teal = p.purple3,
        sapphire = p.purple,
        blue = p.purple,
        sky = p.purple,
        flamingo = p.rose,
        rosewater = p.rose,
      },
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      telescope = true,
      which_key = true,
      bufferline = true,
      native_lsp = { enabled = true, underlines = { errors = "underline" } },
    },
    custom_highlights = function()
      return {
        Normal = { fg = p.fg, bg = p.bg },
        NormalFloat = { fg = p.fg, bg = p.bg2 },
        FloatBorder = { fg = p.purple2, bg = p.bg2 },
        Visual = { bg = p.sel_bg },
        CursorLine = { bg = p.bg2 },
        CursorLineNr = { fg = p.purple2, bg = p.bg2, bold = true },
        LineNr = { fg = p.comment },
        Comment = { fg = p.comment, italic = true },
        Keyword = { fg = p.purple2, bold = true },
        Function = { fg = p.purple2 },
        Identifier = { fg = p.fg },
        Type = { fg = p.purple },
        Constant = { fg = p.magenta },
        String = { fg = p.rose },
        Number = { fg = p.magenta },
        Boolean = { fg = p.magenta },
        Operator = { fg = p.purple3 },
        Pmenu = { fg = p.fg, bg = p.panel },
        PmenuSel = { fg = p.fg, bg = p.sel_bg, bold = true },
        PmenuThumb = { bg = p.purple2 },
        VertSplit = { fg = p.bg2 },
        WinSeparator = { fg = p.bg2 },
        Title = { fg = p.purple2, bold = true },
        Directory = { fg = p.purple2, bold = true },
        NeoTreeDirectoryIcon = { fg = p.purple2, bold = true },
        NeoTreeDirectoryName = { fg = p.fg },
        NeoTreeRootName = { fg = p.purple2, bold = true },
        NeoTreeGitModified = { fg = p.purple },
        NeoTreeGitAdded = { fg = p.purple2 },
        NeoTreeGitDeleted = { fg = p.error },
        NeoTreeDirUtils = { fg = p.purple3 },
        NeoTreeDirSrc = { fg = p.purple2 },
        NeoTreeDirTest = { fg = p.magenta },
        NeoTreeDirDocs = { fg = p.rose },
        NeoTreeDirConfig = { fg = p.purple },
        ["@comment"] = { fg = p.comment, italic = true },
        ["@keyword"] = { fg = p.purple2, bold = true },
        ["@keyword.return"] = { fg = p.purple2, bold = true },
        ["@keyword.function"] = { fg = p.purple2, bold = true },
        ["@operator"] = { fg = p.purple3 },
        ["@punctuation.bracket"] = { fg = p.fg_dim },
        ["@punctuation.delimiter"] = { fg = p.fg_dim },
        ["@function"] = { fg = p.purple2 },
        ["@function.call"] = { fg = p.purple2 },
        ["@function.builtin"] = { fg = p.purple2, italic = true },
        ["@method"] = { fg = p.purple },
        ["@method.call"] = { fg = p.purple },
        ["@constructor"] = { fg = p.purple2 },
        ["@type"] = { fg = p.purple },
        ["@type.builtin"] = { fg = p.purple, italic = true },
        ["@class"] = { fg = p.purple, bold = true },
        ["@namespace"] = { fg = p.purple3 },
        ["@module"] = { fg = p.purple3 },
        ["@parameter"] = { fg = p.fg_dim },
        ["@variable"] = { fg = p.fg },
        ["@variable.builtin"] = { fg = p.purple3, italic = true },
        ["@field"] = { fg = p.fg_dim },
        ["@property"] = { fg = p.fg_dim },
        ["@constant"] = { fg = p.magenta },
        ["@constant.builtin"] = { fg = p.magenta, italic = true },
        ["@string"] = { fg = p.rose },
        ["@string.escape"] = { fg = p.magenta },
        ["@character"] = { fg = p.rose },
        ["@number"] = { fg = p.magenta },
        ["@boolean"] = { fg = p.magenta },
        ["@tag"] = { fg = p.purple },
        ["@tag.attribute"] = { fg = p.magenta },
        ["@attribute"] = { fg = p.magenta },
        ["@label"] = { fg = p.purple2 },
        ["@markup.heading"] = { fg = p.purple2, bold = true },
      }
    end,
  })

  vim.opt.termguicolors = true
  vim.opt.background = "dark"
  vim.cmd.colorscheme("catppuccin")

  local hl = vim.api.nvim_set_hl
  hl(0, "DiagnosticError", { fg = p.error })
  hl(0, "DiagnosticWarn", { fg = p.warn })
  hl(0, "DiagnosticInfo", { fg = p.info })
  hl(0, "DiagnosticHint", { fg = p.hint })
end

return M
