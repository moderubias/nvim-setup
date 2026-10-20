local M = {}

local function rust_analyzer_command()
  local mason = vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer"
  if vim.fn.executable(mason) == 1 then
    return { mason }
  end
  if vim.fn.executable("rustup") == 1 then
    local result = vim
      .system({ "rustup", "run", "stable", "rust-analyzer", "--version" }, { text = true, timeout = 2000 })
      :wait()

    if result.code == 0 then
      local which = vim
        .system({ "rustup", "which", "--toolchain", "stable", "rust-analyzer" }, { text = true, timeout = 2000 })
        :wait()

      local path = vim.trim(which.stdout or "")

      if which.code == 0 and path ~= "" and vim.fn.executable(path) == 1 then
        return { path }
      end
    end
  end

  local system = vim.fn.exepath("rust-analyzer")
  if system ~= "" then
    return { system }
  end

  return { "rust-analyzer" }
end

local warned_manifests = {}
local function auto_attach(bufnr)
  if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
    return false
  end
  local root = vim.fs.root(bufnr, { "Cargo.toml" })
  if root then
    local manifest = root .. "/Cargo.toml"
    local ok, lines = pcall(vim.fn.readfile, manifest)
    local has_content = false
    for _, line in ipairs(ok and lines or {}) do
      if not line:match("^%s*$") and not line:match("^%s*#") then
        has_content = true
        break
      end
    end
    if ok and not has_content then
      if not warned_manifests[manifest] then
        warned_manifests[manifest] = true
        vim.schedule(function()
          vim.notify(
            "Empty Cargo.toml: " .. manifest .. "\nAdd a [package] or [workspace] manifest, then :RustAnalyzer start.",
            vim.log.levels.WARN,
            { title = "Rust workspace" }
          )
        end)
      end
      return false
    end
    warned_manifests[manifest] = nil
  end
  return vim.fn.executable(rust_analyzer_command()[1]) == 1
end

local function run_in_terminal(cmd, title)
  local ok_term, _ = pcall(require, "toggleterm")
  if ok_term then
    local Term = require("toggleterm.terminal").Terminal
    local term = Term:new({
      cmd = cmd,
      direction = "float",
      close_on_exit = false,
      display_name = title or "Rust",
      float_opts = { border = "rounded" },
    })
    term:toggle()
  else
    vim.cmd("botright 15split | terminal " .. cmd)
  end
end

function M.build_android()
  local root = vim.fs.root(0, { "Cargo.toml" }) or vim.uv.cwd()
  local cmd
  if vim.fn.executable("cargo-ndk") == 1 then
    cmd = string.format(
      "cd %s && cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 build --release",
      vim.fn.shellescape(root)
    )
  else
    cmd = string.format("cd %s && cargo build --release", vim.fn.shellescape(root))
  end
  run_in_terminal(cmd, "Rust Android / Native Build")
end

local function rust_on_attach(client, bufnr)
  local lsp = require("lsp")
  lsp.on_attach(client, bufnr)

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "K", function()
    vim.cmd.RustLsp({ "hover", "actions" })
  end, "Rust hover actions")
  map("n", "<leader>ra", function()
    vim.cmd.RustLsp("codeAction")
  end, "Rust code action")
  map("n", "<leader>rb", M.build_android, "Build Rust native/Android")
  map("n", "<leader>rc", function()
    vim.cmd.RustLsp("openCargo")
  end, "Open Cargo.toml")
  map("n", "<leader>rd", function()
    vim.cmd.RustLsp("debuggables")
  end, "Rust debuggables")
  map("n", "<leader>rD", function()
    vim.cmd.RustLsp("openDocs")
  end, "Open docs.rs")
  map("n", "<leader>re", function()
    vim.cmd.RustLsp("expandMacro")
  end, "Expand Rust macro")
  map("n", "<leader>rE", function()
    vim.cmd.RustLsp({ "explainError", "current" })
  end, "Explain Rust error")
  map("n", "<leader>rp", function()
    vim.cmd.RustLsp("parentModule")
  end, "Parent Rust module")
  map("n", "<leader>rr", function()
    vim.cmd.RustLsp("runnables")
  end, "Rust runnables")
  map("n", "<leader>rt", function()
    vim.cmd.RustLsp("testables")
  end, "Rust testables")
  map("n", "<leader>rR", function()
    vim.cmd.RustAnalyzer("restart")
  end, "Restart rust-analyzer")

  vim.api.nvim_buf_create_user_command(bufnr, "RustBuildAndroid", function()
    M.build_android()
  end, {})
end

function M.setup()
  vim.api.nvim_create_augroup("UserRustLspAttach", { clear = true })

  vim.g.rustaceanvim = function()
    local lsp = require("lsp")
    return {
      tools = {
        enable_clippy = true,
        enable_nextest = vim.fn.executable("cargo-nextest") == 1,
        test_executor = "neotest",
        crate_test_executor = "neotest",
        reload_workspace_from_cargo_toml = true,
        code_actions = { ui_select_fallback = true },
        float_win_config = { border = "rounded", auto_focus = true },
      },
      server = {
        cmd = rust_analyzer_command(),
        auto_attach = auto_attach,
        capabilities = lsp.capabilities(),
        on_attach = rust_on_attach,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = false,
              autoreload = true,
              buildScripts = { enable = true },
              loadOutDirsFromCheck = true,
            },
            check = {
              allTargets = true,
              command = "clippy",
            },
            completion = {
              autoimport = { enable = true },
              fullFunctionSignatures = { enable = true },
            },
            imports = {
              granularity = { group = "module" },
              prefix = "self",
            },
            inlayHints = {
              bindingModeHints = { enable = true },
              closureCaptureHints = { enable = true },
              closureReturnTypeHints = { enable = "with_block" },
              discriminantHints = { enable = "fieldless" },
              expressionAdjustmentHints = { enable = "reborrow" },
              lifetimeElisionHints = { enable = "skip_trivial" },
              parameterHints = { enable = true },
              typeHints = { enable = true },
            },
            lens = {
              enable = true,
              debug = { enable = true },
              implementations = { enable = true },
              references = {
                adt = true,
                enumVariant = true,
                method = true,
                trait = true,
              },
              run = { enable = true },
            },
            procMacro = { enable = true },
          },
        },
      },
      dap = { autoload_configurations = true },
    }
  end
end

return M
