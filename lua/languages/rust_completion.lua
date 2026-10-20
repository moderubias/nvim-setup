local Source = {}
Source.__index = Source

local BUILTIN_DERIVES = {
  "Debug",
  "Clone",
  "Copy",
  "Default",
  "PartialEq",
  "Eq",
  "PartialOrd",
  "Ord",
  "Hash",
}

local function derive_context(bufnr)
  if vim.bo[bufnr].filetype ~= "rust" then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2]

  local start_row = math.max(0, row - 12)

  local lines = vim.api.nvim_buf_get_text(bufnr, start_row, 0, row - 1, col, {})

  local text = table.concat(lines, "\n")

  local start = text:match(".*()#%s*%[%s*derive%s*%(")
  if not start then
    return nil
  end

  local tail = text:sub(start)

  if tail:find("%)%s*%]") then
    return nil
  end

  return tail
end

local function imported_names(bufnr)
  local names = {}
  local seen = {}

  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match("^%s*use%s+") then
      for name in line:gmatch("([A-Z][A-Za-z0-9_]*)") do
        if not seen[name] then
          seen[name] = true
          names[#names + 1] = name
        end
      end
    end
  end

  return names
end

local function current_derives(context)
  local existing = {}

  for name in context:gmatch("([A-Z][A-Za-z0-9_]*)") do
    existing[name] = true
  end

  return existing
end

function Source.new()
  return setmetatable({}, Source)
end

function Source:enabled()
  return vim.bo.filetype == "rust"
end

function Source:get_trigger_characters()
  return { "(", "," }
end

function Source:get_completions(ctx, callback)
  local bufnr = ctx.bufnr or vim.api.nvim_get_current_buf()
  local context = derive_context(bufnr)

  if not context then
    callback({
      items = {},
      is_incomplete_forward = false,
      is_incomplete_backward = false,
    })
    return
  end

  local existing = current_derives(context)
  local items = {}
  local added = {}

  local function add(label, detail)
    if existing[label] or added[label] then
      return
    end

    added[label] = true

    items[#items + 1] = {
      label = label,
      insertText = label,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
      kind = vim.lsp.protocol.CompletionItemKind.Class,
      detail = detail,
      sortText = "000_" .. label,
    }
  end

  for _, derive in ipairs(BUILTIN_DERIVES) do
    add(derive, "built-in Rust derive")
  end

  for _, name in ipairs(imported_names(bufnr)) do
    add(name, "imported candidate")
  end

  callback({
    items = items,
    is_incomplete_forward = false,
    is_incomplete_backward = false,
  })
end

return Source
