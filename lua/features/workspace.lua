local M = { terminals = {} }

function M.root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype == "python" then
    return require("languages.python").root(buf)
  end
  local markers = vim.bo[buf].filetype == "rust" and { "Cargo.toml", ".git" }
    or { "package.json", "Cargo.toml", "pyproject.toml", ".git" }
  local name = vim.api.nvim_buf_get_name(buf)
  return vim.fs.root(buf, markers) or (name ~= "" and vim.fs.dirname(name)) or vim.uv.cwd()
end

function M.tasks(root)
  local tasks = {}
  local function add(name, command)
    tasks[#tasks + 1] = { name = name, command = command, root = root }
  end
  if vim.uv.fs_stat(root .. "/Cargo.toml") then
    for _, action in ipairs({ "check", "clippy", "test", "bench", "run" }) do
      add("cargo " .. action, { "cargo", action })
    end
  end
  local package = root .. "/package.json"
  if vim.uv.fs_stat(package) then
    local ok, data = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(package), "\n"))
    end)
    if not ok or type(data) ~= "table" then
      vim.notify("Invalid package.json: " .. package, vim.log.levels.WARN)
      return tasks
    end
    local manager = type(data.packageManager) == "string" and data.packageManager:match("^(%w+)@") or nil
    if not vim.tbl_contains({ "npm", "pnpm", "yarn", "bun" }, manager) then
      local managers = {
        ["pnpm-lock.yaml"] = "pnpm",
        ["yarn.lock"] = "yarn",
        ["bun.lock"] = "bun",
        ["bun.lockb"] = "bun",
        ["package-lock.json"] = "npm",
      }
      local lockfile = vim.fs.find(
        { "pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb", "package-lock.json" },
        { path = root, upward = true, limit = 1 }
      )[1]
      manager = lockfile and managers[vim.fs.basename(lockfile)] or "npm"
    end
    if type(data.scripts) == "table" then
      for _, name in ipairs(vim.fn.sort(vim.tbl_keys(data.scripts))) do
        add(name, { manager, "run", name })
      end
    end
  end
  return tasks
end

function M.run(task)
  if vim.fn.executable(task.command[1]) ~= 1 then
    vim.notify("Executable not found: " .. task.command[1], vim.log.levels.ERROR)
    return
  end
  local key = task.root .. "\n" .. task.name
  local active = M.terminals[key]
  if active and active.job_id and vim.fn.jobwait({ active.job_id }, 0)[1] == -1 then
    active:open()
    return
  end
  if active then
    active:shutdown()
  end
  local command = table.concat(vim.tbl_map(vim.fn.shellescape, task.command), " ")
  local terminal = require("toggleterm.terminal").Terminal:new({
    cmd = command,
    dir = task.root,
    direction = "horizontal",
    close_on_exit = false,
    display_name = task.name,
  })
  M.terminals[key] = terminal
  terminal:open()
end

function M.choose_task(name)
  local tasks = M.tasks(M.root())
  if name and name ~= "" then
    for _, task in ipairs(tasks) do
      if task.name == name then
        M.run(task)
        return
      end
    end
    vim.notify("Unknown project task: " .. name, vim.log.levels.WARN)
    return
  end
  if #tasks == 0 then
    vim.notify("No Cargo manifest or package scripts found. Use Space pr for Python.")
    return
  end
  vim.ui.select(tasks, {
    prompt = "Project task",
    format_item = function(task)
      return task.name
    end,
  }, function(task)
    if task then
      M.run(task)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("ProjectTask", function(args)
    M.choose_task(args.args)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_map(function(t)
        return t.name
      end, M.tasks(M.root()))
    end,
    desc = "Run a project package script or Cargo task",
  })
  vim.keymap.set("n", "<leader>tp", M.choose_task, { desc = "Project task" })
  vim.api.nvim_create_user_command("NoteTemplate", function(args)
    require("features.writing").template(args.args)
  end, {
    nargs = "?",
    complete = function()
      return { "research", "proof", "video", "stream" }
    end,
  })
  vim.api.nvim_create_user_command("WritingStats", function()
    require("features.writing").stats()
  end, {})
  vim.keymap.set("n", "<leader>wn", "<cmd>NoteTemplate<CR>", { desc = "New writing template" })
  vim.keymap.set("n", "<leader>wc", "<cmd>WritingStats<CR>", { desc = "Word count and speaking time" })
end

return M
