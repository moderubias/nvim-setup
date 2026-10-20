local M = {}

local function lsp_status()
  local seen, names = {}, {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    local name = client.name:gsub("_", "-")
    if not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  return #names > 0 and ("󰒋 " .. table.concat(names, ",")) or ""
end

local function python_environment()
  if vim.bo.filetype ~= "python" then
    return ""
  end
  local env = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
  return env and env ~= "" and (" " .. vim.fn.fnamemodify(env, ":t")) or ""
end

local function molten_status()
  if not package.loaded["molten.status"] then
    return ""
  end
  local ok, status = pcall(require, "molten.status")
  return ok and status.initialized() or ""
end

local function recording()
  local register = vim.fn.reg_recording()
  return register ~= "" and ("󰑋 " .. register) or ""
end

local function wide()
  return vim.o.columns >= 110
end

function M.setup()
  local ok, lualine = pcall(require, "lualine")
  if not ok then
    return
  end

  local p = require("theme").palette()
  local function mode(bg, fg)
    return { fg = fg or p.on_accent, bg = bg, gui = "bold" }
  end

  local theme = {
    normal = { a = mode(p.accent), b = { fg = p.fg, bg = p.panel }, c = { fg = p.fg_dim, bg = p.bg_alt } },
    insert = { a = mode(p.ok), b = { fg = p.fg, bg = p.panel }, c = { fg = p.fg_dim, bg = p.bg_alt } },
    visual = { a = mode(p.accent2), b = { fg = p.fg, bg = p.panel }, c = { fg = p.fg_dim, bg = p.bg_alt } },
    replace = { a = mode(p.accent), b = { fg = p.fg, bg = p.panel }, c = { fg = p.fg_dim, bg = p.bg_alt } },
    command = { a = mode(p.accent2), b = { fg = p.fg, bg = p.panel }, c = { fg = p.fg_dim, bg = p.bg_alt } },
    inactive = {
      a = { fg = p.comment, bg = p.bg_alt, gui = "bold" },
      b = { fg = p.comment, bg = p.bg_alt },
      c = { fg = p.comment, bg = p.bg_alt },
    },
  }

  lualine.setup({
    options = {
      theme = theme,
      globalstatus = true,
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
      section_separators = { left = "", right = "" },
      component_separators = { left = "·", right = "·" },
      refresh = { statusline = 500, tabline = 1000, winbar = 1000 },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(value)
            return value:sub(1, 3)
          end,
        },
      },
      lualine_b = { "branch", { "diff", cond = wide }, { "diagnostics", cond = wide } },
      lualine_c = {
        {
          "filename",
          path = 1,
          shorting_target = 36,
          symbols = { modified = " ●", readonly = " ", unnamed = "Untitled", newfile = "New" },
        },
      },
      lualine_x = {
        recording,
        molten_status,
        python_environment,
        { lsp_status, cond = wide },
        { "filetype", colored = false },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    extensions = { "lazy", "mason", "neo-tree", "quickfix", "trouble" },
  })
end

M.setup()

return M
