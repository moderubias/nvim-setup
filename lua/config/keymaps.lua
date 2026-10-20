local map = vim.keymap.set

vim.g.mapleader = vim.g.mapleader or " "
vim.g.maplocalleader = vim.g.maplocalleader or " "

map("n", "<leader>us", function()
  vim.wo.spell = not vim.wo.spell
end, { desc = "Toggle spell checking" })
map("n", "<leader>uh", "<cmd>checkhealth config<CR>", { desc = "Configuration health" })

for _, key in ipairs({ "d", "D", "c", "C", "x", "X", "s", "S" }) do
  map({ "n", "x" }, key, function()
    local register = vim.v.register
    local clipboard = vim.opt.clipboard:get()
    if
      register == '"'
      or (register == "+" and vim.tbl_contains(clipboard, "unnamedplus"))
      or (register == "*" and vim.tbl_contains(clipboard, "unnamed"))
    then
      register = "_"
    end
    return '"' .. register .. key
  end, { expr = true, desc = "Edit without replacing copied text" })
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search" })
map("n", "K", function()
  local ok, doxygen = pcall(require, "languages.doxygen")
  if ok and doxygen.hover() then
    return
  end
  if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
    vim.lsp.buf.hover()
  end
end, { silent = true, desc = "Hover docs" })

map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { silent = true, desc = "Find files" })
map("n", "<C-S-p>", "<cmd>Telescope commands<CR>", { silent = true, desc = "Commands" })
map("n", "<C-f>", "<cmd>Telescope live_grep<CR>", { silent = true, desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true, desc = "Buffers" })
map("n", "<leader>fB", "<cmd>Telescope builtin<CR>", { silent = true, desc = "Builtin pickers" })
map("n", "<leader>fc", "<cmd>Telescope colorscheme<CR>", { silent = true, desc = "Colorschemes" })
map("n", "<leader>ut", function()
  require("theme").toggle()
end, { silent = true, desc = "Apply Stemdark theme" })
map("n", "<leader>fC", "<cmd>Telescope command_history<CR>", { silent = true, desc = "Command history" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { silent = true, desc = "Diagnostics" })
map("n", "<leader>fG", "<cmd>Telescope grep_string<CR>", { silent = true, desc = "Grep word" })
map("n", "<leader>fg", "<cmd>Telescope git_files<CR>", { silent = true, desc = "Git files" })
map("n", "<leader>fH", "<cmd>Telescope search_history<CR>", { silent = true, desc = "Search history" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { silent = true, desc = "Help" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { silent = true, desc = "Keymaps" })
map("n", "<leader>fL", "<cmd>Telescope loclist<CR>", { silent = true, desc = "Location list" })
map("n", "<leader>fM", "<cmd>Telescope man_pages<CR>", { silent = true, desc = "Man pages" })
map("n", "<leader>fm", "<cmd>Telescope marks<CR>", { silent = true, desc = "Marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { silent = true, desc = "Recent files" })
map("n", "<leader>fQ", "<cmd>Telescope quickfix<CR>", { silent = true, desc = "Quickfix" })
map("n", "<leader>fR", "<cmd>Telescope resume<CR>", { silent = true, desc = "Resume picker" })
map("n", "<leader>fr", "<cmd>Telescope registers<CR>", { silent = true, desc = "Registers" })
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true, desc = "Buffer search" })
map("n", "<leader>fS", "<cmd>Telescope spell_suggest<CR>", { silent = true, desc = "Spell suggest" })
map("n", "<leader>ft", "<cmd>Telescope treesitter<CR>", { silent = true, desc = "Treesitter symbols" })

map("n", "<C-b>", "<cmd>Neotree toggle<CR>", { silent = true, desc = "Toggle explorer" })
map("n", "<leader>e", "<cmd>Neotree reveal<CR>", { silent = true, desc = "Reveal file" })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { silent = true, desc = "Workspace diagnostics" })
map(
  "n",
  "<leader>xw",
  "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
  { silent = true, desc = "Buffer diagnostics" }
)
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { silent = true, desc = "Previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { silent = true, desc = "Next diagnostic" })
map("n", "<leader>xd", vim.diagnostic.open_float, { silent = true, desc = "Line diagnostic" })

map("n", "<S-l>", function()
  require("ui.buffers").cycle(1)
end, { silent = true, desc = "Next buffer" })
map("n", "<S-h>", function()
  require("ui.buffers").cycle(-1)
end, { silent = true, desc = "Previous buffer" })
map("n", "<leader>bd", function()
  require("ui.buffers").close()
end, { silent = true, desc = "Close buffer" })
map("n", "<leader>bD", function()
  require("ui.buffers").close(nil, true)
end, { silent = true, desc = "Force close buffer" })
map("n", "<leader>bo", function()
  require("ui.buffers").close_others()
end, { silent = true, desc = "Close other buffers" })
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { silent = true, desc = "Pick buffer" })

map("n", "<leader>gg", "<cmd>Git<CR>", { silent = true, desc = "Git status" })
map("n", "<leader>tc", "<cmd>Cord toggle<CR>", { silent = true, desc = "Toggle Discord presence" })
map("n", "<leader>td", "<cmd>TodoTelescope<CR>", { silent = true, desc = "TODOs" })
map("n", "<leader>tg", "<cmd>ToggleTerm direction=float<CR>", { silent = true, desc = "Terminal" })
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true, desc = "Terminal normal mode" })
