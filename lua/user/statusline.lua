-- ~/.config/nvim/lua/user/statusline.lua
local ok, lualine = pcall(require, "lualine")
if not ok then return end

lualine.setup({
  options = {
    theme = "catppuccin",
    globalstatus = true,
    section_separators = "",
    component_separators = "",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
