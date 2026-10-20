local M = {}

local THEME_DIR = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/theme"
local MODE_FILE = THEME_DIR .. "/current"
local DEFAULT_MODE = "stemdark"

function M.palette_path()
  return vim.fn.expand(vim.g.stemdark_palette or (THEME_DIR .. "/active/palette.json"))
end

function M.mode()
  local ok, lines = pcall(vim.fn.readfile, MODE_FILE)
  if ok and lines and lines[1] then
    local m = vim.trim(lines[1])
    if m:match("^[%w_-]+$") then
      return m
    end
  end
  return DEFAULT_MODE
end

function M.tokens()
  package.loaded["theme.tokens"] = nil
  local ok, tokens = pcall(require, "theme.tokens")
  if not ok then
    return {
      dark = true,
      name = "stemdark",
      base = "#090909",
      mantle = "#111111",
      surface = "#1B1B1B",
      surface2 = "#333333",
      overlay = "#404040",
      overlay2 = "#606060",
      text = "#D6D6D6",
      subtext = "#B8B8B8",
      muted = "#898989",
      faint = "#505050",
      periwinkle = "#F1F1F1",
      azure = "#DEDEDE",
      teal = "#C4C4C4",
      mint = "#AFAFAF",
      iris = "#E6E6E6",
      orchid = "#ABABAB",
      pink = "#CCCCCC",
      blossom = "#A3A3A3",
      gold = "#C4C4C4",
      rose = "#E4E4E4",
      ansi = {},
    }
  end
  return tokens
end

function M.palette()
  local t = M.tokens()

  local p = {

    mode = t.name,
    dark = t.dark,
    ansi = t.ansi or {},

    bg = t.base,
    bg_alt = t.mantle,
    panel = t.surface,
    panel_hi = t.surface2,
    border = t.overlay,
    border_hi = t.overlay2,

    cursorline = t.mantle,

    selection = t.surface2,
    match = t.overlay,

    fg = t.text,
    fg_dim = t.subtext,
    comment = t.muted,
    decor = t.faint,
    on_accent = t.base,

    keyword = t.periwinkle,
    func = t.azure,
    method = t.teal,
    str = t.mint,
    type = t.iris,
    namespace = t.orchid,
    constant = t.pink,
    special = t.blossom,

    operator = t.text,
    punct = t.subtext,

    error = t.rose,
    warn = t.gold,
    info = t.periwinkle,
    hint = t.teal,
    ok = t.mint,

    accent = t.periwinkle,
    accent2 = t.blossom,
    accent3 = t.iris,

    git_add = t.mint,
    git_change = t.subtext,
    git_delete = t.rose,
  }

  p.bg2 = p.bg_alt
  p.panel2 = p.panel_hi
  p.panel3 = p.border
  p.gutter = p.cursorline
  p.sel_bg = p.selection
  p.sel_soft = p.match
  p.shadow = p.border_hi
  p.lace = p.decor
  p.fg_alt = p.fg
  p.muted = p.comment
  p.pink = p.constant
  p.pink_soft = p.panel_hi
  p.rose = p.accent2
  p.rose_dim = p.namespace
  p.lilac = p.type
  p.mauve = p.namespace
  p.sand = p.str
  p.sand_soft = p.panel
  p.sage = p.ok
  p.mint = p.ok
  p.teal = p.method
  p.steel = p.func
  p.sky = p.info
  p.blue = p.func
  p.purple = p.accent
  p.purple2 = p.type
  p.purple3 = p.namespace
  p.violet = p.type
  p.magenta = p.constant

  p.raw = t
  return p
end

function M.set(mode)
  mode = mode or "stemdark"
  if not mode:match("^[%w_-]+$") then
    return
  end

  local dir = vim.fn.fnamemodify(MODE_FILE, ":h")
  vim.fn.mkdir(dir, "p")
  local ok = pcall(vim.fn.writefile, { mode }, MODE_FILE)
  if not ok then
    vim.notify("stemdark: could not write " .. MODE_FILE, vim.log.levels.ERROR)
    return
  end

  M.reload()

  local switcher = THEME_DIR .. "/themux.sh"
  if vim.fn.executable(switcher) == 1 then
    vim.fn.jobstart({ switcher, mode }, { detach = true })
  end

  vim.notify("Stemdark - steel-black focus", vim.log.levels.INFO, { title = "Stemdark" })
end

function M.reload()
  package.loaded["theme.palette"] = nil
  if package.loaded["colorizer"] and not vim.g.stemdark_color_previews then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      pcall(require("colorizer").detach_from_buffer, buf)
    end
  end
  package.loaded["theme.highlights"] = nil
  require("theme.highlights").setup()
  pcall(function()
    require("ui.statusline").setup()
  end)
  return true
end

function M.toggle()
  M.set("stemdark")
end

return M
