local theme = require("theme")
local semantic = theme.palette()
local raw = semantic.raw

return {
  mode = semantic.mode,
  dark = semantic.dark,
  raw = raw,

  bg = semantic.bg,
  bg2 = semantic.bg_alt,
  panel = semantic.panel,
  panel2 = semantic.panel_hi,
  panel3 = semantic.border,
  gutter = semantic.cursorline,
  sel_bg = semantic.selection,
  sel_soft = semantic.match,
  border = semantic.border,
  shadow = semantic.border_hi,
  lace = semantic.decor,

  fg = semantic.fg,
  fg_alt = semantic.fg,
  fg_dim = semantic.fg_dim,
  comment = semantic.comment,
  muted = semantic.comment,
  on_accent = semantic.on_accent,

  accent = semantic.accent,
  accent2 = semantic.func,
  accent3 = semantic.accent3,
  pink = semantic.constant,
  pink_soft = semantic.panel_hi,
  rose = semantic.accent2,
  rose_dim = semantic.namespace,
  lilac = semantic.type,
  mauve = semantic.namespace,
  sand = semantic.str,
  sand_soft = semantic.panel,
  sage = semantic.ok,
  mint = semantic.ok,
  teal = semantic.method,
  steel = semantic.func,
  sky = semantic.info,
  blue = semantic.func,

  error = semantic.error,
  warn = semantic.warn,
  info = semantic.info,
  hint = semantic.hint,

  git_add = semantic.git_add,
  git_change = semantic.git_change,
  git_delete = semantic.git_delete,

  purple = semantic.accent,
  purple2 = semantic.type,
  purple3 = semantic.namespace,
  violet = semantic.type,
  magenta = semantic.constant,
}
