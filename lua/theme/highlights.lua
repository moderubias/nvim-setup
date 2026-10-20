local M = {}

local function set_highlights(groups)
  local hl = vim.api.nvim_set_hl
  for group, opts in pairs(groups) do
    hl(0, group, opts)
  end
end

local function base_highlights(p)
  return {
    Normal = { fg = p.fg, bg = "NONE" },
    NormalNC = { fg = p.fg, bg = "NONE" },
    NormalFloat = { fg = p.fg, bg = p.bg2 },
    FloatBorder = { fg = p.border, bg = p.bg2 },
    FloatTitle = { fg = p.accent, bg = p.bg2, bold = true },
    Visual = { bg = p.sel_bg },
    Search = { fg = p.fg, bg = p.sel_bg, underline = true },
    CurSearch = { fg = p.bg, bg = p.accent2 },
    IncSearch = { fg = p.bg, bg = p.accent2 },
    MatchParen = { fg = p.accent, bg = p.sel_soft, bold = true },
    CursorLine = { bg = p.gutter },
    CursorColumn = { bg = p.gutter },
    CursorLineNr = { fg = p.accent, bg = p.gutter, bold = true },
    ColorColumn = { bg = p.panel },
    RenderMarkdownCode = { bg = p.panel },
    RenderMarkdownCodeBorder = { fg = p.border, bg = p.panel },
    RenderMarkdownCodeInline = { fg = p.fg_dim, bg = p.panel },
    SignColumn = { fg = p.comment, bg = "NONE" },
    LineNr = { fg = p.comment, bg = "NONE" },
    NonText = { fg = p.lace },
    EndOfBuffer = { fg = p.lace },
    Whitespace = { fg = p.lace },
    SpecialKey = { fg = p.muted },
    Folded = { fg = p.fg_dim, bg = p.panel },
    FoldColumn = { fg = p.comment, bg = "NONE" },
    Conceal = { fg = p.fg_dim },
    VertSplit = { fg = p.border, bg = "NONE" },
    WinSeparator = { fg = p.border, bg = "NONE" },
    StatusLine = { fg = p.fg, bg = p.panel },
    StatusLineNC = { fg = p.fg_dim, bg = p.panel },
    WinBar = { fg = p.fg_dim, bg = p.bg, bold = true },
    WinBarNC = { fg = p.muted, bg = p.bg },
    Pmenu = { fg = p.fg, bg = p.panel },
    PmenuSel = { fg = p.fg, bg = p.sel_bg, bold = true },
    PmenuSbar = { bg = p.panel2 },
    PmenuThumb = { bg = p.shadow },
    Title = { fg = p.accent, bold = true },
    Directory = { fg = p.accent, bold = true },
    Question = { fg = p.accent2, bold = true },
    MoreMsg = { fg = p.accent2, bold = true },
    ModeMsg = { fg = p.accent, bold = true },
    ErrorMsg = { fg = p.error, bold = true },
    WarningMsg = { fg = p.warn, bold = true },

    Comment = { fg = p.comment, italic = true },
    Keyword = { fg = p.accent, bold = true },
    Statement = { fg = p.accent2, bold = true },
    Conditional = { fg = p.accent2, bold = true },
    Repeat = { fg = p.accent2, bold = true },
    Operator = { fg = p.fg, bold = true },
    Delimiter = { fg = p.fg_dim },
    Function = { fg = p.steel, bold = true },
    Identifier = { fg = p.fg_dim },
    Type = { fg = p.lilac, italic = true },
    StorageClass = { fg = p.lilac, bold = true },
    Structure = { fg = p.lilac, bold = true },
    PreProc = { fg = p.mauve },
    Include = { fg = p.mauve },
    Define = { fg = p.mauve },
    Macro = { fg = p.mauve },
    Special = { fg = p.pink, bold = true },
    Constant = { fg = p.pink, bold = true },
    String = { fg = p.sand },
    Character = { fg = p.sand },
    Number = { fg = p.pink, bold = true },
    Float = { fg = p.pink, bold = true },
    Boolean = { fg = p.pink, bold = true },

    NeoTreeNormal = { fg = p.fg, bg = "NONE" },
    NeoTreeNormalNC = { fg = p.fg, bg = "NONE" },
    NeoTreeFloatNormal = { fg = p.fg, bg = p.bg2 },
    NeoTreeFloatBorder = { fg = p.border, bg = p.bg2 },
    NeoTreeTitleBar = { fg = p.bg, bg = p.accent, bold = true },
    NeoTreeDirectoryIcon = { fg = p.accent2, bold = true },
    NeoTreeDirectoryName = { fg = p.fg_alt },
    NeoTreeRootName = { fg = p.accent, bold = true },
    NeoTreeIndentMarker = { fg = p.lace },
    NeoTreeExpander = { fg = p.comment },
    NeoTreeFileNameOpened = { fg = p.fg, bold = true },
    NeoTreeGitModified = { fg = p.git_change },
    NeoTreeGitAdded = { fg = p.git_add },
    NeoTreeGitDeleted = { fg = p.git_delete },
    NeoTreeGitConflict = { fg = p.error, bold = true, underline = true },
    NeoTreeGitUntracked = { fg = p.fg_dim, italic = true },
    NeoTreeGitUnstaged = { fg = p.git_change, italic = true },
    NeoTreeGitStaged = { fg = p.git_add, bold = true },
    NeoTreeGitRenamed = { fg = p.fg_dim, underline = true },
    NeoTreeGitIgnored = { fg = p.comment },
    NeoTreeModified = { fg = p.fg, bold = true },
    NeoTreeFileIcon = { fg = p.fg_dim },
    NeoTreeFileName = { fg = p.fg },
    NeoTreeCursorLine = { bg = p.panel_hi, bold = true },
    NeoTreeDotfile = { fg = p.comment },
    NeoTreeIgnored = { fg = p.comment },
    NeoTreeTabActive = { fg = p.fg, bg = p.panel, bold = true },
    NeoTreeTabInactive = { fg = p.comment, bg = p.bg },
    NeoTreeTabSeparatorActive = { fg = p.border, bg = p.panel },
    NeoTreeTabSeparatorInactive = { fg = p.border, bg = p.bg },
    NeoTreeDirUtils = { fg = p.accent },
    NeoTreeDirSrc = { fg = p.steel },
    NeoTreeDirTest = { fg = p.rose },
    NeoTreeDirDocs = { fg = p.sand },
    NeoTreeDirConfig = { fg = p.accent2 },

    ["@comment"] = { fg = p.comment, italic = true },
    ["@keyword"] = { fg = p.accent, bold = true },
    ["@keyword.conditional"] = { fg = p.accent, bold = true },
    ["@keyword.repeat"] = { fg = p.accent, bold = true },
    ["@keyword.return"] = { fg = p.accent, bold = true },
    ["@keyword.function"] = { fg = p.accent, bold = true },
    ["@keyword.operator"] = { fg = p.accent, bold = true },
    ["@operator"] = { fg = p.fg, bold = true },
    ["@punctuation"] = { fg = p.fg_dim },
    ["@punctuation.bracket"] = { fg = p.fg_dim },
    ["@punctuation.delimiter"] = { fg = p.fg_dim },
    ["@punctuation.special"] = { fg = p.rose },
    ["@function"] = { fg = p.steel, bold = true },
    ["@function.call"] = { fg = p.steel, bold = true },
    ["@function.builtin"] = { fg = p.mauve, italic = true },
    ["@function.method"] = { fg = p.teal, bold = true },
    ["@function.method.call"] = { fg = p.teal },
    ["@method"] = { fg = p.teal, bold = true },
    ["@method.call"] = { fg = p.teal },
    ["@constructor"] = { fg = p.lilac, bold = true },
    ["@type"] = { fg = p.lilac, italic = true },
    ["@type.builtin"] = { fg = p.lilac, italic = true },
    ["@type.definition"] = { fg = p.lilac, italic = true },
    ["@class"] = { fg = p.lilac, italic = true },
    ["@structure"] = { fg = p.lilac, italic = true },
    ["@namespace"] = { fg = p.mauve, italic = true },
    ["@module"] = { fg = p.mauve, italic = true },
    ["@parameter"] = { fg = p.raw.blossom, italic = true },
    ["@variable"] = { fg = p.fg_dim },
    ["@variable.builtin"] = { fg = p.mauve, italic = true },
    ["@variable.parameter"] = { fg = p.raw.blossom, italic = true },
    ["@variable.member"] = { fg = p.teal },
    ["@field"] = { fg = p.teal },
    ["@property"] = { fg = p.teal },
    ["@constant"] = { fg = p.pink, bold = true },
    ["@constant.builtin"] = { fg = p.pink, bold = true },
    ["@string"] = { fg = p.sand },
    ["@string.escape"] = { fg = p.accent },
    ["@string.special"] = { fg = p.rose },
    ["@character"] = { fg = p.sand },
    ["@number"] = { fg = p.pink, bold = true },
    ["@float"] = { fg = p.pink, bold = true },
    ["@tag"] = { fg = p.lilac, bold = true },
    ["@tag.builtin"] = { fg = p.rose_dim },
    ["@tag.delimiter"] = { fg = p.comment },
    ["@tag.attribute"] = { fg = p.teal },
    ["@attribute"] = { fg = p.teal },
    htmlTag = { fg = p.comment },
    htmlEndTag = { fg = p.comment },
    htmlTagName = { fg = p.rose_dim },
    htmlSpecialTagName = { fg = p.lilac, bold = true },
    htmlArg = { fg = p.teal },
    ["@label"] = { fg = p.accent },
    ["@markup.heading"] = { fg = p.accent, bold = true },
    ["@markup.link"] = { fg = p.steel, underline = true },
    ["@markup.raw"] = { fg = p.sand, bg = p.panel },
    ["@text.todo"] = { fg = p.bg, bg = p.accent, bold = true },

    ["@lsp.type.variable"] = { fg = p.fg_dim },
    ["@lsp.type.parameter"] = { fg = p.raw.blossom, italic = true },
    ["@lsp.type.property"] = { fg = p.teal },
    ["@lsp.type.function"] = { fg = p.steel, bold = true },
    ["@lsp.type.method"] = { fg = p.teal, bold = true },
    ["@lsp.type.class"] = { fg = p.lilac, italic = true },
    ["@lsp.type.struct"] = { fg = p.lilac, italic = true },
    ["@lsp.type.enum"] = { fg = p.lilac, italic = true },
    ["@lsp.type.interface"] = { fg = p.steel, bold = true },
    ["@lsp.type.namespace"] = { fg = p.mauve, italic = true },
    ["@lsp.type.type"] = { fg = p.lilac },
    ["@lsp.type.macro"] = { fg = p.mauve, bold = true },
    ["@lsp.type.enumMember"] = { fg = p.pink, bold = true },
    ["@lsp.type.decorator"] = { fg = p.mauve, italic = true },
    ["@lsp.type.typeParameter"] = { fg = p.lilac, italic = true },
    ["@lsp.mod.readonly"] = { bold = true },
    ["@lsp.mod.deprecated"] = { strikethrough = true },
    ["@boolean"] = { fg = p.pink, bold = true },
    ["@number.float"] = { fg = p.pink, bold = true },
    ["@markup.strong"] = { fg = p.fg, bold = true },
    ["@markup.italic"] = { fg = p.fg_dim, italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.list"] = { fg = p.accent },
    ["@string.regexp"] = { fg = p.sand, underline = true },
  }
end

local function extra_highlights(p)
  return {
    FloatShadow = { bg = p.bg, blend = 70 },
    FloatShadowThrough = { bg = p.bg, blend = 100 },
    Todo = { fg = p.bg, bg = p.fg, bold = true },
    Added = { fg = p.git_add, bold = true },
    Changed = { fg = p.git_change, underline = true },
    Removed = { fg = p.git_delete, strikethrough = true },
    Error = { fg = p.error, bg = p.panel, bold = true, undercurl = true, sp = p.error },
    NvimInternalError = { fg = p.bg, bg = p.fg, bold = true },
    OkMsg = { fg = p.fg },
    QuickFixLine = { fg = p.fg, bg = p.panel_hi, bold = true },
    SpellBad = { undercurl = true, sp = p.fg },
    SpellCap = { underdotted = true, sp = p.fg_dim },
    SpellLocal = { underdotted = true, sp = p.fg_dim },
    SpellRare = { underdashed = true, sp = p.comment },
    DiagnosticDeprecated = { strikethrough = true, sp = p.comment },
    DiagnosticOk = { fg = p.fg_dim },
    DiagnosticUnderlineOk = { underline = true, sp = p.fg_dim },
    RedrawDebugClear = { bg = p.panel },
    RedrawDebugComposed = { bg = p.panel_hi },
    RedrawDebugRecompose = { bg = p.border },
    DiagnosticError = { fg = p.error },
    DiagnosticWarn = { fg = p.warn },
    DiagnosticInfo = { fg = p.info },
    DiagnosticHint = { fg = p.hint },
    DiagnosticSignError = { fg = p.error, bg = "NONE" },
    DiagnosticSignWarn = { fg = p.warn, bg = "NONE" },
    DiagnosticSignInfo = { fg = p.info, bg = "NONE" },
    DiagnosticSignHint = { fg = p.hint, bg = "NONE" },
    DiagnosticVirtualTextError = { fg = p.error, bg = p.panel },
    DiagnosticVirtualTextWarn = { fg = p.warn, bg = p.panel },
    DiagnosticVirtualTextInfo = { fg = p.info, bg = p.panel },
    DiagnosticVirtualTextHint = { fg = p.hint, bg = p.panel },
    DiagnosticUnderlineError = { undercurl = true, sp = p.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.hint },

    DiffAdd = { fg = p.git_add, bg = p.gutter },
    DiffChange = { fg = p.git_change, bg = p.gutter },
    DiffDelete = { fg = p.git_delete, bg = p.gutter },
    DiffText = { fg = p.accent, bg = p.sel_bg, bold = true },
    GitSignsAdd = { fg = p.git_add, bg = "NONE" },
    GitSignsChange = { fg = p.git_change, bg = "NONE" },
    GitSignsDelete = { fg = p.git_delete, bg = "NONE" },

    TelescopeNormal = { fg = p.fg, bg = p.bg2 },
    TelescopeBorder = { fg = p.border, bg = p.bg2 },
    TelescopePromptNormal = { fg = p.fg, bg = p.panel },
    TelescopePromptBorder = { fg = p.border, bg = p.panel },
    TelescopePromptTitle = { fg = p.bg, bg = p.accent, bold = true },
    TelescopePreviewTitle = { fg = p.bg, bg = p.steel, bold = true },
    TelescopeResultsTitle = { fg = p.bg, bg = p.sand, bold = true },
    TelescopeSelection = { fg = p.fg, bg = p.sel_soft, bold = true },
    TelescopeSelectionCaret = { fg = p.accent, bg = p.sel_soft },
    TelescopeMatching = { fg = p.accent2, bold = true },
    TelescopePromptPrefix = { fg = p.accent },

    BufferLineFill = { fg = p.muted, bg = p.bg },
    BufferLineBackground = { fg = p.muted, bg = p.bg },
    BufferLineBufferVisible = { fg = p.fg_dim, bg = p.bg },
    BufferLineBufferSelected = {
      fg = p.fg_alt,
      bg = p.bg,
      bold = true,
      italic = false,
      underline = true,
      sp = p.accent,
    },
    BufferLineSeparator = { fg = p.bg, bg = p.bg },
    BufferLineSeparatorVisible = { fg = p.bg, bg = p.bg },
    BufferLineSeparatorSelected = { fg = p.bg, bg = p.bg },
    BufferLineIndicatorSelected = { fg = p.accent, bg = p.bg, underline = true, sp = p.accent },
    BufferLineIndicatorVisible = { fg = p.bg, bg = p.bg },
    BufferLineModified = { fg = p.rose, bg = p.bg },
    BufferLineModifiedVisible = { fg = p.rose, bg = p.bg },
    BufferLineModifiedSelected = { fg = p.rose, bg = p.bg },
    BufferLineCloseButton = { fg = p.muted, bg = p.bg },
    BufferLineCloseButtonVisible = { fg = p.fg_dim, bg = p.bg },
    BufferLineCloseButtonSelected = { fg = p.rose, bg = p.bg },
    BufferLineTab = { fg = p.muted, bg = p.bg },
    BufferLineTabSelected = { fg = p.fg_alt, bg = p.bg, underline = true, sp = p.accent },
    BufferLineTabSeparator = { fg = p.bg, bg = p.bg },
    BufferLineTabSeparatorSelected = { fg = p.bg, bg = p.bg },
    BufferLineDiagnostic = { fg = p.muted, bg = p.bg },
    BufferLineDiagnosticVisible = { fg = p.fg_dim, bg = p.bg },
    BufferLineDiagnosticSelected = { fg = p.fg_alt, bg = p.bg, bold = true },
    BufferLineHintDiagnosticSelected = { fg = p.hint, bg = p.bg, bold = true },
    BufferLineInfoDiagnosticSelected = { fg = p.info, bg = p.bg, bold = true },
    BufferLineWarningDiagnosticSelected = { fg = p.warn, bg = p.bg, bold = true },
    BufferLineErrorDiagnosticSelected = { fg = p.error, bg = p.bg, bold = true },

    WhichKey = { fg = p.accent, bold = true },
    WhichKeyDesc = { fg = p.fg },
    WhichKeyGroup = { fg = p.steel },
    WhichKeySeparator = { fg = p.comment },
    WhichKeyValue = { fg = p.comment },
    WhichKeyBorder = { fg = p.border, bg = p.bg2 },
    WhichKeyFloat = { fg = p.fg, bg = p.bg2 },
    WhichKeyTitle = { fg = p.accent, bg = p.bg2, bold = true },

    TroubleNormal = { fg = p.fg, bg = "NONE" },
    TroubleNormalNC = { fg = p.fg, bg = "NONE" },
    TroubleText = { fg = p.fg },
    TroubleCount = { fg = p.bg, bg = p.accent },
    TroubleIndent = { fg = p.border },
    TroubleFile = { fg = p.fg_alt },
    TroubleFoldIcon = { fg = p.comment },

    NotifyBackground = { bg = p.bg2 },
    NotifyERRORBorder = { fg = p.error, bg = p.bg2 },
    NotifyWARNBorder = { fg = p.warn, bg = p.bg2 },
    NotifyINFOBorder = { fg = p.info, bg = p.bg2 },
    NotifyDEBUGBorder = { fg = p.accent2, bg = p.bg2 },
    NotifyTRACEBorder = { fg = p.comment, bg = p.bg2 },
    NotifyERRORTitle = { fg = p.error, bg = p.bg2 },
    NotifyWARNTitle = { fg = p.warn, bg = p.bg2 },
    NotifyINFOTitle = { fg = p.info, bg = p.bg2 },
    NotifyDEBUGTitle = { fg = p.accent2, bg = p.bg2 },
    NotifyTRACETitle = { fg = p.comment, bg = p.bg2 },
    NotifyERRORIcon = { fg = p.error, bg = p.bg2 },
    NotifyWARNIcon = { fg = p.warn, bg = p.bg2 },
    NotifyINFOIcon = { fg = p.info, bg = p.bg2 },
    NotifyDEBUGIcon = { fg = p.accent2, bg = p.bg2 },
    NotifyTRACEIcon = { fg = p.comment, bg = p.bg2 },

    IblIndent = { fg = p.lace },
    IblWhitespace = { fg = p.lace },
    IblScope = { fg = p.accent3 },
    IndentBlanklineChar = { fg = p.lace },
    IndentBlanklineContextChar = { fg = p.accent3 },

    CmpItemAbbr = { fg = p.fg },
    CmpItemAbbrMatch = { fg = p.accent2, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = p.rose_dim, italic = true },
    CmpItemMenu = { fg = p.comment },
    CmpItemKind = { fg = p.steel },
    CmpItemKindFunction = { fg = p.steel },
    CmpItemKindMethod = { fg = p.sage },
    CmpItemKindVariable = { fg = p.fg_alt },
    CmpItemKindProperty = { fg = p.sage },
    CmpItemKindField = { fg = p.sage },
    CmpItemKindText = { fg = p.sand },
    CmpItemKindClass = { fg = p.lilac },
    CmpItemKindInterface = { fg = p.steel },

    DropBarCurrentContext = { fg = p.accent2, bg = p.sel_soft, bold = true },
    DropBarCurrentContextIcon = { fg = p.rose, bg = p.sel_soft },
    DropBarIconUISeparator = { fg = p.border },
    DropBarMenuNormalFloat = { fg = p.fg, bg = p.bg2 },
    DropBarMenuFloatBorder = { fg = p.accent3, bg = p.bg2 },

    FidgetTitle = { fg = p.accent2, bold = true },
    FidgetTask = { fg = p.comment },

    MoltenCell = { bg = p.sel_soft },
    MoltenOutputBorder = { fg = p.accent3 },
    MoltenOutputBorderFail = { fg = p.error },
    MoltenOutputBorderSuccess = { fg = p.sage },
    MoltenOutputFooter = { fg = p.comment },
    MoltenOutputWin = { fg = p.fg, bg = p.bg2 },
    MoltenVirtualText = { fg = p.fg_dim, bg = p.bg2 },

    NeotestAdapterName = { fg = p.accent2, bold = true },
    NeotestDir = { fg = p.fg_dim },
    NeotestExpandMarker = { fg = p.comment },
    NeotestMarked = { fg = p.accent, bold = true, underline = true },
    NeotestWatching = { fg = p.accent2, italic = true },
    NeotestWinSelect = { fg = p.accent, bold = true },
    NeotestFailed = { fg = p.error },
    NeotestFile = { fg = p.fg },
    NeotestNamespace = { fg = p.lilac },
    NeotestPassed = { fg = p.sage },
    NeotestRunning = { fg = p.warn },
    NeotestSkipped = { fg = p.comment },
    NeotestTarget = { fg = p.accent },
    NeotestTest = { fg = p.fg_dim },

    CratesNvimError = { fg = p.error },
    CratesNvimLoading = { fg = p.comment },
    CratesNvimNoMatch = { fg = p.comment },
    CratesNvimPreRelease = { fg = p.warn },
    CratesNvimUpgrade = { fg = p.sage },
    CratesNvimVersion = { fg = p.accent2 },
    CratesNvimYanked = { fg = p.error, strikethrough = true },

    BqfPreviewBorder = { fg = p.accent3 },
    BqfPreviewRange = { bg = p.sel_bg },
    CsvViewDelimiter = { fg = p.accent3 },
    CsvViewHeaderLine = { fg = p.accent2, bold = true },
    YankyPut = { bg = p.sel_bg },
    YankyYanked = { bg = p.pink_soft },

    TodoBgTODO = { fg = p.bg, bg = p.accent, bold = true },
    TodoBgNOTE = { fg = p.bg, bg = p.info, bold = true },
    TodoBgHACK = { fg = p.bg, bg = p.sand, bold = true },
    TodoBgWARN = { fg = p.bg, bg = p.warn, bold = true },
    TodoBgFIX = { fg = p.bg, bg = p.error, bold = true },
    TodoBgPERF = { fg = p.bg, bg = p.sage, bold = true },
    TodoFgTODO = { fg = p.accent },
    TodoFgNOTE = { fg = p.info },
    TodoFgHACK = { fg = p.sand },
    TodoFgWARN = { fg = p.warn },
    TodoFgFIX = { fg = p.error },
    TodoFgPERF = { fg = p.sage },
  }
end

local function devicon_color(name, p)
  local lower = name:lower()

  if lower:find("test") or lower:find("spec") then
    return p.rose
  end
  if lower:find("doc") or lower:find("markdown") or lower:find("text") or lower:find("license") then
    return p.sand
  end
  if lower:find("config") or lower:find("json") or lower:find("yaml") or lower:find("toml") then
    return p.accent2
  end
  if lower:find("git") or lower:find("lock") then
    return p.accent
  end
  if lower:find("lua") or lower:find("vim") or lower:find("js") or lower:find("ts") then
    return p.steel
  end
  if lower:find("py") or lower:find("python") or lower:find("sh") or lower:find("bash") then
    return p.sage
  end
  if lower:find("rust") or lower:find("c") or lower:find("cpp") or lower:find("go") then
    return p.fg_alt
  end

  return p.accent2
end

local function recolor_devicons(p)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return
  end

  local overrides = {}
  for key, icon in pairs(devicons.get_icons() or {}) do
    if type(icon) == "table" and icon.name then
      local color = devicon_color(icon.name, p)
      local level = tonumber(color:sub(2, 3), 16)
      overrides[key] = vim.tbl_extend("force", icon, {
        color = color,
        cterm_color = tostring(math.max(232, math.min(255, 232 + math.floor((level - 8) / 10)))),
      })
      vim.api.nvim_set_hl(0, "DevIcon" .. icon.name, { fg = color })
    end
  end

  devicons.set_icon(overrides)
  devicons.set_default_icon(devicons.get_default_icon().icon, p.fg_dim, "250")
end

function M.apply_overrides()
  local p = require("theme").palette()
  set_highlights(base_highlights(p))
  set_highlights(extra_highlights(p))
  recolor_devicons(p)
end

function M.apply()
  local p = require("theme").palette()
  vim.opt.termguicolors = true
  vim.opt.background = p.dark and "dark" or "light"
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = p.ansi[i]
  end
  set_highlights(base_highlights(p))
  set_highlights(extra_highlights(p))
  recolor_devicons(p)
end

function M.setup()
  vim.opt.termguicolors = true
  vim.cmd.colorscheme("stemdark")

  if not M._autocmds_created then
    local group = vim.api.nvim_create_augroup("UserStemdarkPalette", { clear = true })
    vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
      group = group,
      callback = function()
        require("theme.highlights").apply_overrides()
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "LazyLoad",
      callback = function()
        vim.schedule(function()
          require("theme.highlights").apply_overrides()
        end)
      end,
    })
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        local stat = vim.uv.fs_stat(require("theme").palette_path())
        local stamp = stat and (stat.mtime.sec .. ":" .. stat.mtime.nsec)
        if stamp ~= M._palette_stamp then
          M._palette_stamp = stamp
          require("theme").reload()
        end
      end,
    })
    M._autocmds_created = true
  end

  M.apply()
end

return M
