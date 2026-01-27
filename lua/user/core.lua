-- ~/.config/nvim/lua/user/core.lua
require("user.options")
require("user.keymaps")
require("user.lazy")
require("user.lsp_native").setup()

vim.api.nvim_create_augroup("DoxygenHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = "DoxygenHighlight",
  pattern = { "c", "cpp", "objc", "objcpp", "cuda", "h", "hpp" },
  callback = function()
    require("user.doxygen").setup()
  end,
})

vim.api.nvim_create_augroup("DocFloatConceal", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  group = "DocFloatConceal",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local cfg = vim.api.nvim_win_get_config(win)

    -- Только float-окна
    if not cfg.relative or cfg.relative == "" then
      return
    end

    local buf = vim.api.nvim_win_get_buf(win)

    -- Только "документационные" буферы (nofile), которые обычно используют cmp/LSP
    if vim.bo[buf].buftype ~= "nofile" then
      return
    end

    -- В float-окнах включаем conceal
    vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local", win = win })
    vim.api.nvim_set_option_value("concealcursor", "nc", { scope = "local", win = win })

    -- На всякий случай гарантируем, что syntax включён
    vim.api.nvim_set_option_value("syntax", "ON", { scope = "local", buf = buf })
  end,
})
