local M = {}

local use_nerd_font = vim.g.have_nerd_font == true

M.folder_icons = use_nerd_font
    and {
      src = { icon = "󰈙", hl = "NeoTreeDirSrc" },
      utils = { icon = "󰛨", hl = "NeoTreeDirUtils" },
      test = { icon = "󰂖", hl = "NeoTreeDirTest" },
      tests = { icon = "󰂖", hl = "NeoTreeDirTest" },
      doc = { icon = "󰈙", hl = "NeoTreeDirDocs" },
      docs = { icon = "󰈙", hl = "NeoTreeDirDocs" },
      config = { icon = "󰒓", hl = "NeoTreeDirConfig" },
      lua = { icon = "", hl = "NeoTreeDirSrc" },
    }
  or {
    src = { icon = "S", hl = "NeoTreeDirSrc" },
    utils = { icon = "U", hl = "NeoTreeDirUtils" },
    test = { icon = "T", hl = "NeoTreeDirTest" },
    tests = { icon = "T", hl = "NeoTreeDirTest" },
    doc = { icon = "D", hl = "NeoTreeDirDocs" },
    docs = { icon = "D", hl = "NeoTreeDirDocs" },
    config = { icon = "C", hl = "NeoTreeDirConfig" },
    lua = { icon = "L", hl = "NeoTreeDirSrc" },
  }

M.default_folder = { icon = use_nerd_font and "" or "F", hl = "NeoTreeDirectoryIcon" }

M.tree_folder_icons = {
  folder_closed = use_nerd_font and "" or ">",
  folder_open = use_nerd_font and "" or "v",
  folder_empty = use_nerd_font and "󰜌" or ".",
  folder_empty_open = use_nerd_font and "󰜌" or ".",
}

function M.get_folder_icon(name)
  local key = (name or ""):lower()
  return M.folder_icons[key] or M.default_folder
end

return M
