if vim.fn.has("nvim-0.12") ~= 1 then
  error("This configuration requires Neovim 0.12 or newer")
end

local custom = require("config.custom")
require("config.options")
if custom.init then
  custom.init()
end
require("config.keymaps")
require("config.lazy")
require("theme.highlights").setup()
require("config.autocmds").setup()
require("features.workspace").setup()

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserDoxygen", { clear = true }),
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    require("languages.doxygen").setup()
  end,
})

if custom.setup then
  custom.setup()
end
