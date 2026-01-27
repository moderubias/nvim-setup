-- ~/.config/nvim/lua/user/keymaps.lua
local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
map("n", "K", function()
  local ok, doxygen = pcall(require, "user.doxygen")
  if ok and doxygen.hover() then
    return
  end
  if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
    vim.lsp.buf.hover()
  end
end, { silent = true })

-- Telescope
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { silent = true })
map("n", "<C-S-p>", "<cmd>Telescope commands<CR>", { silent = true })
map("n", "<C-f>", "<cmd>Telescope live_grep<CR>", { silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true })
map("n", "<leader>fB", "<cmd>Telescope builtin<CR>", { silent = true })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<CR>", { silent = true })
map("n", "<leader>fC", "<cmd>Telescope command_history<CR>", { silent = true })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { silent = true })
map("n", "<leader>fG", "<cmd>Telescope grep_string<CR>", { silent = true })
map("n", "<leader>fg", "<cmd>Telescope git_files<CR>", { silent = true })
map("n", "<leader>fH", "<cmd>Telescope search_history<CR>", { silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { silent = true })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { silent = true })
map("n", "<leader>fL", "<cmd>Telescope loclist<CR>", { silent = true })
map("n", "<leader>fM", "<cmd>Telescope man_pages<CR>", { silent = true })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { silent = true })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { silent = true })
map("n", "<leader>fQ", "<cmd>Telescope quickfix<CR>", { silent = true })
map("n", "<leader>fR", "<cmd>Telescope resume<CR>", { silent = true })
map("n", "<leader>fr", "<cmd>Telescope registers<CR>", { silent = true })
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true })
map("n", "<leader>fS", "<cmd>Telescope spell_suggest<CR>", { silent = true })
map("n", "<leader>ft", "<cmd>Telescope treesitter<CR>", { silent = true })

-- File explorer
map("n", "<C-b>", "<cmd>Neotree toggle<CR>", { silent = true })
map("n", "<leader>e", "<cmd>Neotree reveal<CR>", { silent = true })

-- Diagnostics
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { silent = true })
map("n", "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { silent = true })

-- Buffers
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
