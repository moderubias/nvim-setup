local M = {}

function M.setup()
  local ok, cord = pcall(require, "cord")
  if not ok then
    return
  end

  cord.setup({
    enabled = true,
    log_level = vim.log.levels.OFF,
    editor = {
      client = "neovim",
      tooltip = "Neovim",
    },
    display = {
      theme = "atom",
      flavor = "dark",
      view = "full",
      swap_fields = false,
      swap_icons = false,
    },
    timestamp = {
      enabled = true,
      reset_on_idle = false,
      reset_on_change = false,
    },
    idle = {
      enabled = true,
      timeout = 300000,
      show_status = true,
      ignore_focus = true,
      unidle_on_focus = true,
      smart_idle = true,
      details = "Idling",
      tooltip = "💤",
    },
    text = {
      workspace = function(opts)
        return "In " .. opts.workspace
      end,
      viewing = function(opts)
        return "Viewing " .. (opts.filename ~= "" and opts.filename or "buffer")
      end,
      editing = function(opts)
        return "Editing " .. (opts.filename ~= "" and opts.filename or "buffer")
      end,
      file_browser = function(opts)
        return "Exploring " .. (opts.name or "tree")
      end,
      plugin_manager = function(opts)
        return "Managing plugins in " .. opts.name
      end,
      lsp = function(opts)
        return "Configuring LSP in " .. opts.name
      end,
      docs = function(opts)
        return "Reading " .. opts.name
      end,
      vcs = function(opts)
        return "Committing changes in " .. opts.name
      end,
    },
    buttons = {
      {
        label = function(opts)
          return opts.repo_url and "View Repository" or "GitHub Profile"
        end,
        url = function(opts)
          return opts.repo_url or "https://github.com/moderubias"
        end,
      },
    },
    advanced = {
      discord = {
        reconnect = {
          enabled = true,
          interval = 5000,
          initial = true,
        },
      },
    },
  })
end

return M
