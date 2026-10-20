local M = { selected = {}, terminals = {} }
local markers = {
  "pyproject.toml",
  "pyrightconfig.json",
  "setup.cfg",
  "setup.py",
  "pytest.ini",
  "tox.ini",
  "requirements.txt",
  "Pipfile",
  "uv.lock",
  "ruff.toml",
  ".ruff.toml",
  ".venv",
  ".git",
}

local function directory(context)
  if context == nil then
    if vim.bo.buftype ~= "" and M.last_root then
      return M.last_root
    end
    context = vim.api.nvim_get_current_buf()
  end
  local path = type(context) == "number" and vim.api.nvim_buf_get_name(context) or context
  if not path or path == "" then
    return vim.uv.cwd()
  end
  path = vim.fs.normalize(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory" and path or vim.fs.dirname(path)
end

function M.find_root(context)
  return vim.fs.root(directory(context), markers)
end

function M.root(context)
  return M.find_root(context) or directory(context)
end

local function is_executable(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "file" and vim.uv.fs_access(path, "X") == true
end

local function default_python()
  for path in (vim.uv.os_getenv("PATH") or ""):gmatch("[^:]+") do
    local executable = path .. "/python3"
    if is_executable(executable) then
      return executable
    end
  end
end

function M.candidates(context)
  local root, candidates, seen = M.root(context), {}, {}
  local function add(path, label)
    if is_executable(path) and not seen[path] then
      seen[path] = true
      candidates[#candidates + 1] = { path = path, label = label }
    end
  end
  add(M.selected[root], "Selected for this project")
  for _, name in ipairs({ ".venv", "venv", "env" }) do
    add(root .. "/" .. name .. "/bin/python", "Project " .. name)
  end
  for _, name in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
    local value = vim.uv.os_getenv(name)
    if value then
      add(value .. "/bin/python", "Shell " .. name)
    end
  end
  add(default_python(), "Default Python")
  return candidates
end

function M.executable(context)
  local candidates = M.candidates(context)

  return candidates[1] and candidates[1].path or "python3"
end

function M.select_interpreter(path, root)
  root = root or M.root()
  path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
  if not is_executable(path) then
    vim.notify("Python interpreter is not executable: " .. path, vim.log.levels.ERROR)
    return false
  end
  M.selected[root] = path
  for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
    if client.config.root_dir == root then
      client.config.settings.python = client.config.settings.python or {}
      client.config.settings.python.pythonPath = path
      client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end
  vim.notify("Python: " .. path, vim.log.levels.INFO, { title = "Project environment" })
  return true
end

function M.select()
  local root, choices = M.root(), M.candidates()
  choices[#choices + 1] = { label = "Use automatic project detection", automatic = true }
  choices[#choices + 1] = { label = "Enter another interpreter path…" }
  vim.ui.select(choices, {
    prompt = "Python environment · " .. vim.fs.basename(root),
    format_item = function(item)
      return item.label .. (item.path and " — " .. item.path or "")
    end,
  }, function(item)
    if not item then
      return
    end
    if item.automatic then
      M.selected[root] = nil
      M.select_interpreter(M.executable(root), root)
      M.selected[root] = nil
    elseif item.path then
      M.select_interpreter(item.path, root)
    else
      vim.ui.input(
        { prompt = "Python executable: ", default = root .. "/.venv/bin/python", completion = "file" },
        function(path)
          if path and path ~= "" then
            M.select_interpreter(path, root)
          end
        end
      )
    end
  end)
end

function M.info()
  local root, python, buf = M.root(), M.executable(), vim.api.nvim_get_current_buf()
  local clients = vim.tbl_map(function(c)
    return c.name
  end, vim.lsp.get_clients({ bufnr = buf }))
  local format_status = (vim.g.disable_autoformat or vim.b[buf].disable_autoformat) and "off" or "on"
  if vim.api.nvim_buf_line_count(buf) > 10000 then
    format_status = "manual (large buffer)"
  end
  vim.system({
    python,
    "-c",
    "import sys, importlib.util; print(sys.version.split()[0]); print('available' if importlib.util.find_spec('pytest') else 'not installed in this environment')",
  }, { text = true, cwd = root, timeout = 3000 }, function(result)
    vim.schedule(function()
      local detail = vim.split(vim.trim(result.stdout or ""), "\n")
      local lines = {
        "# Python workspace",
        "",
        "Root: " .. root,
        "Interpreter: " .. python,
        "Version: " .. (detail[1] or "unavailable"),
        "Pytest: " .. (detail[2] or "unavailable"),
        "Format on save: " .. format_status,
        "Language servers: " .. (#clients > 0 and table.concat(clients, ", ") or "starting / not attached"),
        "",
        "Space pv  choose environment     Space pf  format",
        "Space pF  toggle format on save  Space po  organize imports",
        "Space pr  run current file       Space dc  choose debugger launch",
        "Space tT  nearest test           Space tF  file tests",
        "Space tA  project tests          Space tD  debug nearest test",
      }
      if result.code ~= 0 then
        lines[#lines + 1] = "Interpreter check failed; verify the selected executable."
      end
      vim.lsp.util.open_floating_preview(lines, "markdown", { border = "rounded", max_width = 100, focusable = true })
    end)
  end)
end

function M.run_file()
  local file, root, python = vim.api.nvim_buf_get_name(0), M.root(), M.executable()
  if file == "" then
    vim.notify("Save this Python file before running it.", vim.log.levels.WARN)
    return
  end
  vim.cmd.update()
  local active = M.terminals[root]
  if active and active.job_id and vim.fn.jobwait({ active.job_id }, 0)[1] == -1 then
    active:open()
    vim.notify("Python is already running for this project. Ctrl+C in its terminal stops it.")
    return
  end
  if active then
    active:shutdown()
  end
  local command = "cd "
    .. vim.fn.shellescape(root)
    .. " && "
    .. vim.fn.shellescape(python)
    .. " -u "
    .. vim.fn.shellescape(file)
  local Terminal = require("toggleterm.terminal").Terminal
  local terminal = Terminal:new({
    cmd = command,
    direction = "horizontal",
    close_on_exit = false,
    display_name = "Python · " .. vim.fs.basename(file),
  })
  M.terminals[root] = terminal
  terminal:toggle()
end

function M.setup_dap(adapter_python)
  local dap, dap_python = require("dap"), require("dap-python")
  dap_python.setup(adapter_python, {
    pythonPath = function()
      return M.executable()
    end,
  })
  dap_python.resolve_python = function()
    return M.executable()
  end
  dap_python.test_runner = "pytest"
  for _, config in ipairs(dap.configurations.python or {}) do
    if config.request == "launch" then
      config.cwd = function()
        return M.root()
      end
      config.envFile = function()
        return M.root() .. "/.env"
      end
      config.justMyCode = true
    end
  end
  dap.configurations.python[#dap.configurations.python + 1] = {
    name = "module (python -m)",
    type = "python",
    request = "launch",
    module = function()
      local value = vim.fn.input("Python module (e.g. package.bot): ")
      return value ~= "" and value or dap.ABORT
    end,
    args = function()
      return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
    end,
    pythonPath = function()
      return M.executable()
    end,
    cwd = function()
      return M.root()
    end,
    envFile = function()
      return M.root() .. "/.env"
    end,
    console = "integratedTerminal",
    justMyCode = true,
  }
end

function M.neotest_adapter()
  local adapter = require("neotest-python")({ python = M.executable, runner = "pytest", dap = { justMyCode = true } })
  adapter.root = M.find_root
  adapter.filter_dir = function(name)
    return not vim.tbl_contains(
      { ".venv", "venv", "env", ".git", "__pycache__", ".pytest_cache", "node_modules", "build", "dist" },
      name
    )
  end
  local build_spec = adapter.build_spec
  adapter.build_spec = function(args)
    local spec = build_spec(args)
    if not spec then
      return
    end
    local path = args.tree:data().path
    spec.cwd = M.root(path)
    spec.command[1] = M.executable(path)
    if spec.strategy then
      spec.strategy.cwd = spec.cwd
      spec.strategy.python = { spec.command[1] }

      spec.strategy.envFile = "/dev/null"
    end
    return spec
  end
  return adapter
end

function M.setup_buffer(buf)
  M.last_root = M.root(buf)
  if not M._setup then
    M._setup = true
    for name, fn in pairs({ PythonInfo = M.info, PythonSelect = M.select, PythonRun = M.run_file }) do
      vim.api.nvim_create_user_command(name, fn, {})
    end
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("UserPythonEnvironment", { clear = true }),
      pattern = { "*.py", "*.pyi" },
      callback = function(args)
        M.last_root = M.root(args.buf)
      end,
    })
  end
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, silent = true, desc = desc })
  end
  map("<leader>pi", M.info, "Python workspace info")
  map("<leader>pv", M.select, "Python project environment")
  map("<leader>pr", M.run_file, "Run Python file")
  map("<F5>", function()
    require("dap").continue()
  end, "Start / continue Python debug")
  map("<F9>", function()
    require("dap").toggle_breakpoint()
  end, "Toggle breakpoint")
  map("<F10>", function()
    require("dap").step_over()
  end, "Step over")
  map("<F11>", function()
    require("dap").step_into()
  end, "Step into")
  map("<S-F5>", function()
    require("dap").terminate()
  end, "Stop debugger")
  map("<leader>pf", function()
    require("conform").format({ async = true, lsp_format = "never" })
  end, "Format Python")
  map("<leader>po", function()
    require("conform").format({ async = true, formatters = { "ruff_organize_imports" }, lsp_format = "never" })
  end, "Organize Python imports")
  map("<leader>pF", function()
    if vim.g.disable_autoformat then
      vim.notify("Automatic formatting is disabled globally by vim.g.disable_autoformat.")
      return
    end
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify("Python format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
  end, "Toggle Python format on save")
end

return M
