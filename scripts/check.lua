local failures, checks = {}, 0
local function check(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  checks = checks + 1
  if not ok then
    failures[#failures + 1] = name .. ": " .. err
  end
end

local errors = {}
local original_notify = vim.notify
vim.notify = function(message, level, opts)
  if level == vim.log.levels.ERROR then
    errors[#errors + 1] = tostring(message)
  end
  return original_notify(message, level, opts)
end

check("Lua syntax", function()
  local files = { "init.lua" }
  for _, dir in ipairs({ "lua", "colors", "ftplugin", "after", "snippets", "scripts" }) do
    vim.list_extend(files, vim.fn.glob(dir .. "/**/*.lua", false, true))
  end
  for _, path in ipairs(files) do
    assert(loadfile(path))
  end
end)

check("Resize preserves the current tab", function()
  vim.cmd.tabnew()
  local tab = vim.api.nvim_get_current_tabpage()
  vim.cmd.tabnew()
  vim.api.nvim_set_current_tabpage(tab)
  vim.api.nvim_exec_autocmds("VimResized", {})
  assert(vim.api.nvim_get_current_tabpage() == tab)
  vim.cmd("tabonly!")
end)

check("Modified buffer cannot be closed accidentally", function()
  vim.cmd.enew()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved" })
  require("ui.buffers").close(buf)
  assert(vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified)
  vim.bo[buf].modified = false
end)

local temp = vim.fn.tempname()
vim.fn.mkdir(temp .. "/web/src", "p")
vim.fn.mkdir(temp .. "/rust/src", "p")
vim.fn.mkdir(temp .. "/python/.venv/bin", "p")
vim.fn.writefile(
  { '{"name":"fixture","packageManager":"pnpm@10.0.0","scripts":{"dev":"astro dev","check":"astro check"}}' },
  temp .. "/web/package.json"
)
vim.fn.writefile(
  { "[package]", 'name = "fixture"', 'version = "0.1.0"', 'edition = "2021"' },
  temp .. "/rust/Cargo.toml"
)
vim.fn.writefile({ "[project]", 'name = "fixture"', 'version = "0.1.0"' }, temp .. "/python/pyproject.toml")

check("Project tasks and working directories", function()
  local workspace = require("features.workspace")
  local tasks = workspace.tasks(temp .. "/web")
  assert(#tasks == 2 and tasks[1].name == "check")
  assert(vim.deep_equal(tasks[1].command, { "pnpm", "run", "check" }))
  vim.fn.writefile({ '{"scripts":{"dev":"node index.js"}}' }, temp .. "/web/package.json")
  vim.fn.writefile({}, temp .. "/pnpm-lock.yaml")
  vim.fn.writefile({}, temp .. "/web/yarn.lock")
  assert(workspace.tasks(temp .. "/web")[1].command[1] == "yarn")
  assert(#workspace.tasks(temp .. "/rust") == 5)
  vim.cmd.edit(vim.fn.fnameescape(temp .. "/rust/src/main.rs"))
  assert(workspace.root() == temp .. "/rust")
  vim.cmd.edit(vim.fn.fnameescape(temp .. "/web/src/index.astro"))
  assert(workspace.root() == temp .. "/web")
end)

check("Python project interpreter takes priority", function()
  local python = require("languages.python")
  local executable = vim.fn.exepath("python3")
  assert(executable ~= "", "python3 required for this check")
  assert(vim.uv.fs_symlink(executable, temp .. "/python/.venv/bin/python"))
  assert(python.executable(temp .. "/python") == temp .. "/python/.venv/bin/python")
  assert(python.root(temp .. "/python/main.py") == temp .. "/python")
end)

check("Malformed and incomplete palettes use the built-in theme", function()
  local theme = require("theme")
  local original = vim.g.stemdark_palette
  local ok, err = pcall(function()
    vim.g.stemdark_palette = temp .. "/palette.json"
    for _, source in ipairs({ "{", "{}", '{"base":"broken"}', "null" }) do
      vim.fn.writefile({ source }, vim.g.stemdark_palette)
      assert(theme.palette().fg == "#D6D6D6", source)
      theme.reload()
    end
  end)
  vim.g.stemdark_palette = original
  theme.reload()
  assert(ok, err)
end)

check("Custom completion modules and configuration health resolve", function()
  require("lazy").load({ plugins = { "blink.cmp" } })
  local providers = require("blink.cmp.config").sources.providers
  for _, name in ipairs({ "rust_derive", "latex_kernel" }) do
    assert(type(require(providers[name].module).new) == "function", name)
  end
  assert(type(require("config.health").check) == "function")
  assert(vim.fn.maparg(vim.g.mapleader .. "uh", "n"):find("checkhealth config", 1, true))
end)

check("Project terminal preserves cwd and reuses a running process", function()
  local workspace = require("features.workspace")
  local root = temp .. "/project 'quoted'"
  vim.fn.mkdir(root, "p")
  local task = {
    name = "terminal test",
    root = root,
    command = { "python3", "-c", "import os,time; print(os.getcwd(), flush=True); time.sleep(0.4)" },
  }
  workspace.run(task)
  local terminal = workspace.terminals[root .. "\n" .. task.name]
  assert(terminal and terminal.job_id)
  local job = terminal.job_id
  workspace.run(task)
  assert(workspace.terminals[root .. "\n" .. task.name].job_id == job)
  assert(vim.wait(3000, function()
    return vim.fn.jobwait({ job }, 0)[1] ~= -1
  end, 20))
  local output = table.concat(vim.api.nvim_buf_get_lines(terminal.bufnr, 0, -1, false), "\n")
  assert(output:gsub("\n", ""):find(root, 1, true), output)
  terminal:shutdown()
end)

check("Language buffers and lazy plugin configuration", function()
  for _, name in ipairs({
    "example.py",
    "example.tex",
    "example.md",
    "example.html",
    "example.lua",
    "example.java",
    "example.sh",
  }) do
    vim.cmd.edit(vim.fn.fnameescape(temp .. "/" .. name))
    assert(vim.bo.filetype ~= "", name)
    assert(vim.v.errmsg == "", vim.v.errmsg)
  end
  require("lazy").load({ plugins = { "overseer.nvim", "neotest", "nvim-dap", "csvview.nvim" } })
  assert(not require("lint").linters_by_ft.javascript)
  assert(require("conform").formatters_by_ft["markdown.mdx"])
  local snippets = dofile("snippets/python.lua")
  assert(#snippets == 7)
  assert(#dofile("snippets/tex.lua") > 0)
end)

check("LSP setup is repeatable and missing servers are configured", function()
  local lsp = require("lsp")
  lsp.setup()
  lsp.setup()
  assert(lsp.servers.astro and lsp.servers.pyright and lsp.servers.texlab)
  assert(vim.lsp.config.astro and vim.lsp.config.pyright)
  assert(vim.fn.exists(":LspRefresh") == 2)
end)

check("Writing templates preserve the existing buffer", function()
  local writing = require("features.writing")
  vim.cmd.enew()
  local previous = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(previous, 0, -1, false, { "Keep this text" })
  for _, name in ipairs({ "research", "proof", "video", "stream" }) do
    writing.template(name)
    assert(vim.bo.filetype == "markdown")
    assert(vim.api.nvim_buf_line_count(0) > 10)
    assert(writing.stats().words > 0)
  end
  assert(vim.api.nvim_buf_get_lines(previous, 0, -1, false)[1] == "Keep this text")
end)

vim.wait(1500, function()
  return false
end, 50)
check("No asynchronous configuration errors", function()
  assert(#errors == 0, table.concat(errors, "\n"))
  assert(vim.v.errmsg == "", vim.v.errmsg)
end)

vim.fn.delete(temp, "rf")
vim.notify = original_notify
if #failures > 0 then
  io.stderr:write(table.concat(failures, "\n") .. "\n")
  vim.cmd("cquit 1")
else
  print(string.format("PASS: %d configuration checks", checks))
  vim.cmd("qa!")
end
