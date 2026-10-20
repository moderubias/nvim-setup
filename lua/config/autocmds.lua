local M = {}

local function augroup(name)
  return vim.api.nvim_create_augroup("User" .. name, { clear = true })
end

function M.setup()
  vim.filetype.add({
    extension = {
      env = "sh",
      tex = "tex",
      ltx = "tex",
      cls = "tex",
      sty = "tex",
      dtx = "tex",
      ins = "tex",
      mdx = "markdown.mdx",
      wgsl = "wgsl",
    },
    filename = {
      [".env"] = "sh",
      [".envrc"] = "sh",
      ["Brewfile"] = "ruby",
      ["Dockerfile"] = "dockerfile",
      ["docker-compose.yml"] = "yaml.docker-compose",
      ["docker-compose.yaml"] = "yaml.docker-compose",
      ["Jenkinsfile"] = "groovy",
    },
    pattern = {
      ["%.env%.[%w_.-]+"] = "sh",
      ["Dockerfile%.[%w_.-]+"] = "dockerfile",
    },
  })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("HighlightYank"),
    callback = function()
      vim.highlight.on_yank({ timeout = 160 })
    end,
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("RestoreCursor"),
    callback = function(args)
      local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
      local line_count = vim.api.nvim_buf_line_count(args.buf)
      if mark[1] > 1 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("ResizeSplits"),
    callback = function()
      local current = vim.api.nvim_get_current_tabpage()
      vim.cmd("tabdo wincmd =")
      if vim.api.nvim_tabpage_is_valid(current) then
        vim.api.nvim_set_current_tabpage(current)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("WritingMode"),
    pattern = { "gitcommit", "markdown", "markdown.mdx", "text", "tex", "plaintex", "cls", "sty", "dtx", "ins" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      local extension = vim.fn.expand("%:e")
      local is_latex_code = vim.tbl_contains({ "cls", "sty", "dtx", "ins" }, extension)
      vim.opt_local.spell = false
      vim.opt_local.conceallevel = is_latex_code and 0 or 2
      vim.opt_local.concealcursor = is_latex_code and "" or "nc"
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("LatexEditing"),
    pattern = { "tex", "plaintex", "cls", "sty", "dtx", "ins" },
    callback = function(args)
      require("languages.latex_completion").ensure_loaded()
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "vimtex#fold#level(v:lnum)"
      vim.opt_local.foldtext = "vimtex#fold#text()"
      vim.opt_local.iskeyword:append({ "_", ":" })
      local extension = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":e")
      vim.b[args.buf].vimtex_auto_compile = extension == "tex" or extension == "ltx"

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
      end

      map("<leader>ll", "<cmd>VimtexCompile<CR>", "Compile LaTeX")
      map("<leader>lL", "<cmd>VimtexCompileSS<CR>", "Compile LaTeX once")
      map("<leader>lv", "<cmd>VimtexView<CR>", "View PDF")
      map("<leader>le", "<cmd>VimtexErrors<CR>", "LaTeX errors")
      map("<leader>lc", "<cmd>VimtexClean<CR>", "Clean LaTeX build")
      map("<leader>lk", "<cmd>VimtexStop<CR>", "Stop LaTeX compiler")
      map("<leader>lt", "<cmd>VimtexTocToggle<CR>", "Toggle LaTeX TOC")
      map("<leader>lo", "<cmd>VimtexCompileOutput<CR>", "LaTeX compiler output")
      map("<leader>li", "<cmd>VimtexInfo<CR>", "LaTeX project and engine info")
      map("<leader>ls", "<cmd>VimtexStatus<CR>", "LaTeX compiler status")
      vim.keymap.set("n", "<leader>lm", function()
        vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
      end, { buffer = args.buf, silent = true, desc = "Show raw TeX / pretty symbols" })
      map("<leader>lz", "<cmd>ZenMode<CR>", "LaTeX focus mode")
      vim.keymap.set("n", "<leader>la", function()
        vim.b.vimtex_auto_compile = not vim.b.vimtex_auto_compile
        if not vim.b.vimtex_auto_compile then
          vim.cmd("silent! VimtexStop")
        end
        local state = vim.b.vimtex_auto_compile and "enabled" or "disabled"
        vim.notify("LaTeX auto-compile " .. state)
      end, { buffer = args.buf, silent = true, desc = "Toggle LaTeX auto-compile" })
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup("LatexCompileOnSave"),
    pattern = { "*.tex", "*.ltx" },
    callback = function(args)
      if not vim.b[args.buf].vimtex_auto_compile then
        return
      end
      if vim.fn.exists(":VimtexCompileSS") ~= 2 or not vim.b[args.buf].vimtex then
        return
      end
      vim.api.nvim_buf_call(args.buf, function()
        if vim.fn.eval("b:vimtex.compiler.is_running()") == 0 then
          vim.cmd("silent VimtexCompileSS")
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("IndentWidth"),
    pattern = {
      "astro",
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "json",
      "jsonc",
      "lua",
      "scss",
      "svelte",
      "typescript",
      "typescriptreact",
      "vue",
      "yaml",
    },
    callback = function()
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("AstroSetup"),
    pattern = "astro",
    callback = function()
      vim.opt_local.commentstring = "<!-- %s -->"
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("QuickClose"),
    pattern = { "checkhealth", "help", "lspinfo", "man", "qf", "query", "startuptime" },
    callback = function(args)
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
    end,
  })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup("Terminal"),
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
    end,
  })

  vim.api.nvim_create_autocmd("QuitPre", {
    group = augroup("CloseQuitBuffer"),
    callback = function(args)
      local win = vim.api.nvim_get_current_win()
      local buf = args.buf
      vim.schedule(function()
        if
          not vim.api.nvim_win_is_valid(win)
          and vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buftype == ""
          and vim.bo[buf].buflisted
          and not vim.bo[buf].modified
          and #vim.fn.win_findbuf(buf) == 0
        then
          require("ui.buffers").close(buf)
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufWipeout", "BufEnter", "TabEnter", "SessionLoadPost" }, {
    group = augroup("RefreshBufferline"),
    callback = function()
      require("ui.buffers").refresh()
    end,
  })
  vim.api.nvim_create_autocmd("OptionSet", {
    group = "UserRefreshBufferline",
    pattern = { "buflisted", "buftype" },
    callback = function()
      require("ui.buffers").refresh()
    end,
  })
  require("ui.buffers").refresh()
end

return M
