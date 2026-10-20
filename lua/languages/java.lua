local M = {}

local function ensure_java_home()
  if not vim.env.JAVA_HOME or vim.env.JAVA_HOME == "" then
    local candidates = {
      "/usr/lib/jvm/default",
      "/usr/lib/jvm/java-17-openjdk",
      "/usr/lib/jvm/java-27-openjdk",
    }
    for _, path in ipairs(candidates) do
      if vim.uv.fs_stat(path) then
        vim.env.JAVA_HOME = path
        break
      end
    end
  end
end

function M.get_root_dir(bufnr)
  bufnr = bufnr or 0
  local start = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)) or vim.uv.cwd()
  local repo = vim.fs.root(start, { ".git" })
  local options = { path = start, upward = true, stop = repo and vim.fs.dirname(repo), limit = 1 }

  local build = vim.fs.find({ "settings.gradle", "settings.gradle.kts", "gradlew", "mvnw", ".mvn" }, options)[1]
    or vim.fs.find({ "build.gradle", "build.gradle.kts", "pom.xml" }, options)[1]
  return build and vim.fs.dirname(build) or repo or start
end

local function get_bundles()
  local bundles = {}
  local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

  for _, jar in
    ipairs(
      vim.fn.glob(
        mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
        true,
        true
      )
    )
  do
    table.insert(bundles, jar)
  end

  local test_jars = vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar", true, true)
  if type(test_jars) == "table" then
    for _, jar in ipairs(test_jars) do
      local name = vim.fs.basename(jar)

      if
        not name:match("com%.microsoft%.java%.test%.runner%-")
        and name ~= "jacocoagent.jar"
        and not vim.uv.fs_stat(mason_packages .. "/jdtls/plugins/" .. name)
      then
        table.insert(bundles, jar)
      end
    end
  end

  return bundles
end

local function get_runtimes()
  local runtimes = {}
  local seen = {}
  local default = vim.uv.fs_realpath(vim.env.JAVA_HOME or "/usr/lib/jvm/default")
  for _, release in ipairs(vim.fn.glob("/usr/lib/jvm/*/release", true, true)) do
    local path = vim.uv.fs_realpath(vim.fs.dirname(release))
    local contents = table.concat(vim.fn.readfile(release), "\n")
    local version = tonumber(contents:match('JAVA_VERSION="(%d+)'))
    if path and not seen[path] and version and version >= 9 and vim.fn.executable(path .. "/bin/javac") == 1 then
      seen[path] = true
      table.insert(runtimes, { name = "JavaSE-" .. version, path = path, default = path == default })
    end
  end
  table.sort(runtimes, function(a, b)
    return tonumber(a.name:match("%d+")) < tonumber(b.name:match("%d+"))
  end)
  return runtimes
end

local function run_in_terminal(cmd, title)
  local ok_term, _ = pcall(require, "toggleterm")
  if ok_term then
    local Term = require("toggleterm.terminal").Terminal
    local term = Term:new({
      cmd = cmd,
      direction = "float",
      close_on_exit = false,
      display_name = title or "Build",
      float_opts = { border = "rounded" },
    })
    term:toggle()
  else
    vim.cmd("botright 15split | terminal " .. cmd)
  end
end

function M.build_apk(task)
  task = task or "assembleDebug"
  local root = M.get_root_dir(0)
  local gradlew = root .. "/gradlew"
  local cmd
  if vim.uv.fs_stat(gradlew) then
    cmd = string.format("cd %s && ./gradlew %s", vim.fn.shellescape(root), vim.fn.shellescape(task))
  else
    cmd = string.format("cd %s && gradle %s", vim.fn.shellescape(root), vim.fn.shellescape(task))
  end
  run_in_terminal(cmd, "Gradle: " .. task)
end

function M.build_full_apk()
  local root = M.get_root_dir(0)
  local rust_dirs = {
    root,
    root .. "/rust",
    root .. "/native",
    root .. "/core",
    root .. "/crates",
  }
  local rust_root = nil
  for _, dir in ipairs(rust_dirs) do
    if vim.uv.fs_stat(dir .. "/Cargo.toml") then
      rust_root = dir
      break
    end
  end

  local gradlew = root .. "/gradlew"
  local gradle_cmd = vim.uv.fs_stat(gradlew) and "./gradlew assembleDebug" or "gradle assembleDebug"

  local full_cmd
  if rust_root then
    if vim.fn.executable("cargo-ndk") == 1 then
      full_cmd = string.format(
        "cd %s && cargo ndk -o %s/app/src/main/jniLibs build --release && cd %s && %s",
        vim.fn.shellescape(rust_root),
        vim.fn.shellescape(root),
        vim.fn.shellescape(root),
        gradle_cmd
      )
    else
      full_cmd = string.format(
        "cd %s && cargo build --release && cd %s && %s",
        vim.fn.shellescape(rust_root),
        vim.fn.shellescape(root),
        gradle_cmd
      )
    end
  else
    full_cmd = string.format("cd %s && %s", vim.fn.shellescape(root), gradle_cmd)
  end

  run_in_terminal(full_cmd, "Full Build: Rust Native + APK")
end

function M.install_apk()
  local root = M.get_root_dir(0)
  local gradlew = root .. "/gradlew"
  local cmd = vim.uv.fs_stat(gradlew) and string.format("cd %s && ./gradlew installDebug", vim.fn.shellescape(root))
    or string.format("cd %s && gradle installDebug", vim.fn.shellescape(root))
  run_in_terminal(cmd, "Gradle: installDebug")
end

function M.run_gradle_task()
  vim.ui.input({ prompt = "Gradle task: ", default = "assembleDebug" }, function(input)
    if input and input ~= "" then
      M.build_apk(input)
    end
  end)
end

local function java_on_attach(client, bufnr)
  local lsp = require("lsp")
  lsp.on_attach(client, bufnr)

  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    return
  end

  pcall(jdtls.setup_dap, { hotcodereplace = "auto" })
  local ok_jdtls_dap, jdtls_dap = pcall(require, "jdtls.dap")
  if ok_jdtls_dap then
    pcall(jdtls_dap.setup_dap_main_class_configs)
  end

  local ok_dap, dap = pcall(require, "dap")
  if ok_dap then
    dap.configurations.java = dap.configurations.java or {}
    local has_remote = false
    for _, cfg in ipairs(dap.configurations.java) do
      if cfg.name and cfg.name:find("Android") then
        has_remote = true
        break
      end
    end
    if not has_remote then
      table.insert(dap.configurations.java, {
        type = "java",
        request = "attach",
        name = "Attach to Android (port 8700 / 5005)",
        hostName = "127.0.0.1",
        port = function()
          return tonumber(vim.fn.input("Debug port [8700/5005]: ", "8700")) or 8700
        end,
      })
    end
  end

  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
  map("n", "<leader>jv", jdtls.extract_variable, "Extract variable")
  map("v", "<leader>jv", function()
    jdtls.extract_variable(true)
  end, "Extract variable")
  map("n", "<leader>jc", jdtls.extract_constant, "Extract constant")
  map("v", "<leader>jc", function()
    jdtls.extract_constant(true)
  end, "Extract constant")
  map("v", "<leader>jm", function()
    jdtls.extract_method(true)
  end, "Extract method")
  map("n", "<leader>jt", jdtls.test_nearest_method, "Test nearest method")
  map("n", "<leader>jT", jdtls.test_class, "Test class")
  map("n", "<leader>ju", jdtls.update_project_config, "Update project config")
  map("n", "<leader>ja", function()
    M.build_apk("assembleDebug")
  end, "Assemble Debug APK")
  map("n", "<leader>jA", M.build_full_apk, "Full Build (Rust + APK)")
  map("n", "<leader>jr", M.install_apk, "Install/Run APK")
  map("n", "<leader>jb", M.run_gradle_task, "Run Gradle task")

  vim.api.nvim_buf_create_user_command(bufnr, "JavaBuildApk", function(opts)
    M.build_apk(opts.args ~= "" and opts.args or "assembleDebug")
  end, { nargs = "?" })

  vim.api.nvim_buf_create_user_command(bufnr, "JavaBuildFullApk", function()
    M.build_full_apk()
  end, {})

  vim.api.nvim_buf_create_user_command(bufnr, "JavaInstallApk", function()
    M.install_apk()
  end, {})

  vim.api.nvim_buf_create_user_command(bufnr, "JavaGradle", function(opts)
    M.build_apk(opts.args)
  end, { nargs = 1 })

  vim.api.nvim_buf_create_user_command(bufnr, "JavaOrganizeImports", function()
    jdtls.organize_imports()
  end, {})

  vim.api.nvim_buf_create_user_command(bufnr, "JavaUpdateConfig", function()
    jdtls.update_project_config()
  end, {})
end

function M.setup()
  local ok_jdtls, jdtls = pcall(require, "jdtls")
  if not ok_jdtls then
    return
  end

  ensure_java_home()

  local root_dir = M.get_root_dir(0)
  local project_name = vim.fs.basename(root_dir) or "default"
  local project_hash = vim.fn.sha256(root_dir):sub(1, 8)
  local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspaces/" .. project_name .. "-" .. project_hash
  vim.fn.mkdir(workspace_dir, "p")

  local function get_server_java()
    for _, runtime in ipairs(get_runtimes()) do
      if tonumber(runtime.name:match("%d+")) >= 21 then
        return runtime.path .. "/bin/java"
      end
    end
    return nil
  end

  local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
  local cmd = {
    vim.uv.fs_stat(jdtls_bin) and jdtls_bin or "jdtls",
  }

  local server_java = get_server_java()
  if not server_java then
    vim.notify(
      "JDTLS needs JDK 21 or newer in /usr/lib/jvm. Project builds may still use JDK 17.",
      vim.log.levels.ERROR
    )
    return
  end
  table.insert(cmd, "--java-executable")
  table.insert(cmd, server_java)

  table.insert(cmd, "-data")
  table.insert(cmd, workspace_dir)

  local lombok_jar = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
  if vim.uv.fs_stat(lombok_jar) then
    table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
  end

  local capabilities = require("lsp").capabilities()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local config = {
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    on_attach = java_on_attach,
    init_options = {
      bundles = get_bundles(),
      extendedClientCapabilities = extendedClientCapabilities,
    },
    settings = {
      java = {
        autobuild = { enabled = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        saveActions = { organizeImports = false },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "org.mockito.Answers.*",
          },
          filteredTypes = {
            "com.sun.*",
            "io.micrometer.shaded.*",
            "java.awt.*",
            "jdk.*",
            "sun.*",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = get_runtimes(),
        },
        inlayHints = {
          parameterNames = {
            enabled = "all",
          },
        },
        import = {
          gradle = {
            enabled = true,
            wrapper = { enabled = true },
          },
          maven = {
            enabled = true,
          },
        },
      },
    },
  }

  jdtls.start_or_attach(config)
end

return M
