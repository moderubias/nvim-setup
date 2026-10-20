local M = {}

local state = {
  items = nil,
  loading = false,
}

local function add_item(items, word, label, detail)
  if items[word] then
    return
  end
  items[word] = {
    label = label,
    word = word,
    detail = detail,
    filterText = word,
    insertText = word,
    kind = 3,
    documentation = { kind = "plaintext", value = detail },
  }
end

function M.ensure_loaded()
  if state.items ~= nil or state.loading then
    return state.items ~= nil
  end

  state.loading = true
  vim.system({
    "sh",
    "-c",
    [[
      extract_commands() {
        module=$1
        file=$2
        path=$(kpsewhich "$file" 2>/dev/null) || return 0
        printf '__MODULE__ %s\n' "$module"
        rg -o '\\[A-Za-z_@][A-Za-z0-9_@]*(:[A-Za-z_]*)?' "$path" || true
      }

      extract_commands expl3 expl3-code.tex
      extract_commands latex2e latex.ltx
      extract_commands plain plain.tex
      extract_commands xparse xparse.sty

      path=$(kpsewhich expl3-code.tex 2>/dev/null) || exit 0
      printf '__MODULE__ l3keys\n'
      rg 'c__keys_props_root_str \.' "$path" | rg -o '\.[A-Za-z_][A-Za-z0-9_]*(:[A-Za-z_]*)?' || true
    ]],
  }, { text = true }, function(result)
    state.loading = false
    local items = {}
    local module = nil

    for line in (result.stdout or ""):gmatch("[^\r\n]+") do
      local marker = line:match("^__MODULE__ (.+)$")
      if marker then
        module = marker
      elseif module == "l3keys" then
        add_item(items, line, line, "l3keys property")
      else
        local name = line:match("^\\(.+)$")
        if name and not (module == "expl3" and name:find("^__")) then
          local detail = module == "expl3" and "LaTeX3 / expl3 kernel"
            or module == "latex2e" and "LaTeX2e kernel"
            or module == "plain" and "Plain TeX"
            or "xparse"
          add_item(items, name, "\\" .. name, detail)
        end
      end
    end

    local sorted = {}
    for _, item in pairs(items) do
      table.insert(sorted, item)
    end
    table.sort(sorted, function(left, right)
      return left.word < right.word
    end)
    state.items = sorted
  end)

  return false
end

function M.is_loaded()
  return state.items ~= nil
end

function M.items_for(prefix)
  M.ensure_loaded()
  if state.items == nil then
    return {}
  end

  if prefix == "" or prefix == "\\" then
    return {}
  end

  if prefix:sub(1, 1) == "\\" then
    prefix = prefix:sub(2)
  end

  local matches = {}
  local low, high = 1, #state.items
  while low < high do
    local middle = math.floor((low + high) / 2)
    if state.items[middle].word < prefix then
      low = middle + 1
    else
      high = middle
    end
  end

  for index = low, #state.items do
    local item = state.items[index]
    if vim.startswith(item.word, prefix) then
      table.insert(matches, item)
      if #matches >= 200 then
        break
      end
    end
  end
  return matches
end

local Source = {}
Source.__index = Source

function M.new(opts)
  return setmetatable({
    opts = opts or {},
  }, Source)
end

function Source:enabled()
  local ft = vim.bo.filetype

  return ft == "tex" or ft == "plaintex" or ft == "bib" or ft == "cls" or ft == "sty" or ft == "dtx" or ft == "ins"
end

function Source:get_trigger_characters()
  return { "\\", "." }
end

function Source:get_completions(_, callback)
  M.ensure_loaded()

  if state.items == nil then
    callback({
      items = {},
      is_incomplete_backward = false,
      is_incomplete_forward = true,
    })
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2]
  local line = vim.api.nvim_get_current_line()
  local before = line:sub(1, col)

  local prefix = before:match("\\([A-Za-z_@][A-Za-z0-9_@:]*$)") or before:match("(%.?[A-Za-z_@][A-Za-z0-9_@:]*$)") or ""

  local items = M.items_for(prefix)

  callback({
    items = vim.deepcopy(items),
    is_incomplete_backward = false,
    is_incomplete_forward = false,
  })
end

return M
