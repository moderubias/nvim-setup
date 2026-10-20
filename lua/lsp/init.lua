local M = { servers = {} }

local function has(value)
  return value ~= nil and value ~= ""
end

local function path_join(...)
  return table.concat({ ... }, "/")
end

local function executable(path)
  return has(path) and vim.uv.fs_stat(path) ~= nil
end

local function add_mason_to_path()
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
  if vim.uv.fs_stat(mason_bin) and not vim.env.PATH:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
  end
end

local server_commands = {
  astro = "astro-ls",
  bashls = "bash-language-server",
  clangd = "clangd",
  cssls = "vscode-css-language-server",
  docker_compose_language_service = "docker-compose-langserver",
  dockerls = "docker-langserver",
  emmet_language_server = "emmet-language-server",
  eslint = "vscode-eslint-language-server",
  glsl_analyzer = "glsl_analyzer",
  html = "vscode-html-language-server",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  marksman = "marksman",
  pyright = "pyright-langserver",
  ruff = "ruff",
  tailwindcss = "tailwindcss-language-server",
  taplo = "taplo",
  texlab = "texlab",
  ts_ls = "typescript-language-server",
  yamlls = "yaml-language-server",
}

local function server_available(server)
  local command = server_commands[server]
  return not command or vim.fn.executable(command) == 1
end

local function get_typescript_tsdk(root_dir)
  if has(root_dir) then
    local local_ts = path_join(root_dir, "node_modules", "typescript", "lib")
    if executable(path_join(local_ts, "typescript.js")) or executable(path_join(local_ts, "tsserverlibrary.js")) then
      return local_ts
    end
  end

  local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
  local mason_candidates = {
    path_join(mason_packages, "astro-language-server", "node_modules", "typescript", "lib"),
    path_join(mason_packages, "typescript-language-server", "node_modules", "typescript", "lib"),
  }
  for _, candidate in ipairs(mason_candidates) do
    if executable(path_join(candidate, "typescript.js")) or executable(path_join(candidate, "tsserverlibrary.js")) then
      return candidate
    end
  end

  for _, path in ipairs({
    vim.fn.expand("~/.local/lib/node_modules/typescript/lib"),
    "/usr/local/lib/node_modules/typescript/lib",
    "/usr/lib/node_modules/typescript/lib",
  }) do
    if executable(path_join(path, "typescript.js")) or executable(path_join(path, "tsserverlibrary.js")) then
      return path
    end
  end

  return ""
end

local function schemastore_json()
  local ok, schemastore = pcall(require, "schemastore")
  if ok then
    return schemastore.json.schemas()
  end
end

local function schemastore_yaml()
  local ok, schemastore = pcall(require, "schemastore")
  if ok then
    return schemastore.yaml.schemas()
  end
end

function M.on_attach(client, bufnr)
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false

    return
  end
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "LSP definition")
  map("n", "gD", vim.lsp.buf.declaration, "LSP declaration")
  map("n", "gi", vim.lsp.buf.implementation, "LSP implementation")
  map("n", "gr", vim.lsp.buf.references, "LSP references")
  map("n", "<leader>rn", vim.lsp.buf.rename, "LSP rename")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP code action")
  map("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
  map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols")
  map("n", "<leader>cf", function()
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ bufnr = bufnr, async = true, lsp_format = "fallback" })
    else
      vim.lsp.buf.format({ bufnr = bufnr, async = true })
    end
  end, "Format buffer")

  if vim.lsp.inlay_hint and client:supports_method("textDocument/inlayHint") then
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
    map("n", "<leader>ci", function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    end, "Toggle inlay hints")
  end
end

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

  capabilities.general = capabilities.general or {}
  capabilities.general.positionEncodings = { "utf-16" }

  return capabilities
end

function M.refresh()
  for server in pairs(M.servers) do
    if server_available(server) and not vim.lsp.is_enabled(server) then
      vim.lsp.enable(server)
    end
  end
end

function M.setup()
  if M.initialized then
    M.refresh()
    return
  end
  M.initialized = true
  add_mason_to_path()

  vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●" },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.HINT] = " ",
        [vim.diagnostic.severity.INFO] = " ",
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "always" },
  })

  local capabilities = M.capabilities()

  local servers = {
    astro = {
      cmd = { "astro-ls", "--stdio" },
      filetypes = { "astro" },
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(bufnr, {
          "astro.config.mjs",
          "astro.config.ts",
          "astro.config.js",
          "astro.config.cjs",
          "package.json",
          "tsconfig.json",
          "jsconfig.json",
          ".git",
        }) or (fname ~= "" and vim.fs.dirname(fname)) or vim.uv.cwd()
        on_dir(root)
      end,
      init_options = {
        typescript = {
          tsdk = get_typescript_tsdk(),
        },
      },
      before_init = function(_, config)
        local tsdk = get_typescript_tsdk(config.root_dir)
        config.init_options = config.init_options or {}
        config.init_options.typescript = config.init_options.typescript or {}
        if has(tsdk) then
          config.init_options.typescript.tsdk = tsdk
        end
      end,
    },
    bashls = {},
    clangd = {
      cmd = { "clangd", "--offset-encoding=utf-16", "--background-index", "--clang-tidy" },
    },
    cssls = {},
    docker_compose_language_service = {},
    dockerls = {},
    emmet_language_server = {
      filetypes = {
        "astro",
        "css",
        "eruby",
        "html",
        "htmldjango",
        "javascriptreact",
        "less",
        "pug",
        "sass",
        "scss",
        "svelte",
        "typescriptreact",
        "vue",
      },
    },
    eslint = {
      settings = {
        workingDirectories = { mode = "auto" },
      },
    },
    gdscript = {},
    glsl_analyzer = {},
    html = {},
    jsonls = {
      settings = {
        json = {
          schemas = schemastore_json(),
          validate = { enable = true },
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          diagnostics = { globals = { "vim" } },
          runtime = { version = "LuaJIT" },
          telemetry = { enable = false },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    },
    marksman = {},
    pyright = {
      root_dir = function(bufnr, on_dir)
        on_dir(require("languages.python").root(bufnr))
      end,
      settings = {
        pyright = { disableOrganizeImports = true },
        python = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            diagnosticMode = "openFiles",
            typeCheckingMode = "standard",
            useLibraryCodeForTypes = true,
            diagnosticSeverityOverrides = { reportUnusedCoroutine = "error" },
          },
        },
      },
      before_init = function(_, config)
        config.settings = config.settings or {}
        config.settings.python = config.settings.python or {}
        config.settings.python.pythonPath = require("languages.python").executable(config.root_dir)
      end,
    },
    ruff = {
      root_dir = function(bufnr, on_dir)
        on_dir(require("languages.python").root(bufnr))
      end,
      init_options = {
        settings = {
          configurationPreference = "filesystemFirst",
          lint = { extendSelect = { "I", "B", "ASYNC", "RUF006" } },
        },
      },
    },
    tailwindcss = {
      filetypes = {
        "astro",
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "scss",
        "svelte",
        "typescript",
        "typescriptreact",
        "vue",
      },
      settings = {
        tailwindCSS = {
          classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
          includeLanguages = {
            astro = "html",
            eelixir = "html-eex",
            eruby = "erb",
            heex = "phoenix-heex",
            templ = "html",
          },
          validate = true,
        },
      },
    },
    taplo = {},
    texlab = {
      filetypes = { "tex", "plaintex", "bib", "cls", "sty", "dtx", "ins" },
      settings = {
        texlab = {
          auxDirectory = "build",
          pdfDirectory = "build",
          logDirectory = "build",
          build = {
            executable = "latexmk",
            args = {
              "-xelatex",
              "-interaction=nonstopmode",
              "-synctex=1",
              "-file-line-error",
              "-outdir=build",
              "%f",
            },
            onSave = false,
            forwardSearchAfter = false,
          },
          forwardSearch = {
            executable = "zathura",
            args = { "--synctex-forward", "%l:1:%f", "%p" },
          },
          diagnosticsDelay = 500,
          latexFormatter = "latexindent",
          latexindent = { modifyLineBreaks = false },
          completion = { matcher = "fuzzy" },
          experimental = {
            expl3Syntax = true,
          },
        },
      },
    },
    ts_ls = {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = schemastore_yaml(),
        },
      },
    },
  }

  vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = M.on_attach,
  })

  for server, config in pairs(servers) do
    local merged = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      on_attach = M.on_attach,
    }, config)

    vim.lsp.config(server, merged)
    M.servers[server] = true
  end
  M.refresh()
  require("mason-registry"):on("package:install:success", vim.schedule_wrap(M.refresh))
  vim.api.nvim_create_user_command("LspRefresh", M.refresh, { desc = "Enable newly installed language servers" })
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("UserLspAvailability", { clear = true }),
    callback = M.refresh,
  })
  vim.api.nvim_create_autocmd("User", {
    group = "UserLspAvailability",
    pattern = "MasonToolsUpdateCompleted",
    callback = M.refresh,
  })
end

return M
