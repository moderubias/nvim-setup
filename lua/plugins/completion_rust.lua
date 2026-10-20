local function in_rust_attribute()
  if vim.bo.filetype ~= "rust" then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]

  local start_row = math.max(0, row - 8)
  local lines = vim.api.nvim_buf_get_text(0, start_row, 0, row - 1, col, {})
  local text = table.concat(lines, "\n")

  local last_open
  local offset = 1

  while true do
    local s, e = text:find("#%s*%[", offset)
    if not s then
      break
    end

    last_open = s
    offset = e + 1
  end

  if not last_open then
    return false
  end

  local last_close
  offset = 1

  while true do
    local s, e = text:find("%]", offset)
    if not s then
      break
    end

    last_close = s
    offset = e + 1
  end

  return not last_close or last_open > last_close
end

local function resolve_bool_option(value, ctx, default)
  if type(value) == "function" then
    return value(ctx)
  end

  if value == nil then
    return default
  end

  return value
end

local function suppress_in_rust_attributes(provider)
  local previous = provider.should_show_items

  provider.should_show_items = function(ctx)
    if in_rust_attribute() then
      return false
    end

    return resolve_bool_option(previous, ctx, true)
  end
end

return {
  {
    "saghen/blink.cmp",

    version = "1.*",

    optional = true,

    opts = function(_, opts)
      opts.keymap = opts.keymap or {}

      opts.keymap["<C-Space>"] = {
        "show",
        "show_documentation",
        "hide_documentation",
      }

      opts.keymap["<C-k>"] = {
        "show_signature",
        "hide_signature",
        "fallback",
      }

      opts.completion = opts.completion or {}
      opts.completion.trigger = opts.completion.trigger or {}

      local old_x_blocked = opts.completion.trigger.show_on_x_blocked_trigger_characters

      opts.completion.trigger.show_on_trigger_character = true
      opts.completion.trigger.show_on_accept_on_trigger_character = true
      opts.completion.trigger.show_on_insert_on_trigger_character = true

      opts.completion.trigger.show_on_x_blocked_trigger_characters = function(ctx)
        local blocked

        if type(old_x_blocked) == "function" then
          blocked = old_x_blocked(ctx)
        elseif type(old_x_blocked) == "table" then
          blocked = vim.deepcopy(old_x_blocked)
        else
          blocked = { "'", '"', "(" }
        end

        if vim.bo.filetype ~= "rust" then
          return blocked
        end

        return vim.tbl_filter(function(char)
          return char ~= "("
        end, blocked)
      end

      opts.completion.documentation = vim.tbl_deep_extend("force", opts.completion.documentation or {}, {
        auto_show = true,
        auto_show_delay_ms = 180,
      })

      opts.completion.ghost_text = vim.tbl_deep_extend("force", opts.completion.ghost_text or {}, {
        enabled = true,
      })

      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}

      opts.sources.per_filetype.rust = {
        inherit_defaults = true,
        "rust_derive",
      }

      local providers = opts.sources.providers

      providers.lsp = providers.lsp or {}
      providers.snippets = providers.snippets or {}
      providers.buffer = providers.buffer or {}
      providers.path = providers.path or {}
      providers.rust_derive = {
        name = "Rust Derive",
        module = "languages.rust_completion",
        score_offset = 20,
        min_keyword_length = 0,
      }

      providers.lsp.score_offset = math.max(providers.lsp.score_offset or 0, 6)

      providers.lsp.min_keyword_length = 0

      suppress_in_rust_attributes(providers.snippets)
      suppress_in_rust_attributes(providers.buffer)
      suppress_in_rust_attributes(providers.path)

      providers.snippets.score_offset = math.min(providers.snippets.score_offset or 0, -2)

      opts.signature = vim.tbl_deep_extend("force", opts.signature or {}, {
        enabled = true,
      })
    end,
  },
}
