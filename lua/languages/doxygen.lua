local M = {}

function M.setup()
  if vim.b.doxygen_syntax_loaded then
    return
  end
  vim.b.doxygen_syntax_loaded = true

  local p = require("theme.palette")
  local hl = vim.api.nvim_set_hl

  hl(0, "DoxygenTag", { fg = p.accent, bold = true })
  hl(0, "DoxygenParam", { fg = p.steel })
  hl(0, "DoxygenBrief", { fg = p.sand })

  vim.cmd([[
    syntax match DoxygenTag "@\(brief\|param\|tparam\|return\|note\|warning\|sa\|see\|file\|class\|struct\|enum\|fn\)\>" containedin=Comment
    syntax match DoxygenTag "\\\(brief\|param\|tparam\|return\|note\|warning\|sa\|see\|file\|class\|struct\|enum\|fn\)\>" containedin=Comment

    syntax match DoxygenParam "@param\s\+\zs\S\+"  containedin=Comment
    syntax match DoxygenParam "\\param\s\+\zs\S\+" containedin=Comment
    syntax match DoxygenParam "@tparam\s\+\zs\S\+" containedin=Comment
    syntax match DoxygenParam "\\tparam\s\+\zs\S\+" containedin=Comment

    syntax region DoxygenBrief start="@brief\>" end="$" keepend contains=DoxygenTag
    syntax region DoxygenBrief start="\\brief\>" end="$" keepend contains=DoxygenTag
  ]])
end

local function is_comment_line(bufnr, lnum)
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
  if not line then
    return false
  end
  local first = line:find("%S")
  if not first then
    return false
  end
  local syn = vim.fn.synIDattr(vim.fn.synID(lnum + 1, first, 1), "name")
  return syn:lower():find("comment") ~= nil
end

local function strip_comment(line)
  local cleaned = line
  cleaned = cleaned:gsub("^%s*//+%s?", "")
  cleaned = cleaned:gsub("^%s*/%*+%s?", "")
  cleaned = cleaned:gsub("^%s*%*+%s?", "")
  cleaned = cleaned:gsub("%*/%s*$", "")
  return cleaned
end

local function parse_doxygen(lines)
  local out = {}
  for _, line in ipairs(lines) do
    local text = strip_comment(line)
    if not text:match("^%s*$") then
      local brief = text:match("^[@\\]brief%s+(.+)")
      if brief then
        table.insert(out, brief)
      else
        local param, desc = text:match("^[@\\]param%s+(%S+)%s*(.*)")
        if param then
          table.insert(out, "- **" .. param .. "**: " .. (desc ~= "" and desc or ""))
        else
          local tparam, tdesc = text:match("^[@\\]tparam%s+(%S+)%s*(.*)")
          if tparam then
            table.insert(out, "- **" .. tparam .. "**: " .. (tdesc ~= "" and tdesc or ""))
          else
            local ret = text:match("^[@\\]return%s+(.+)")
            if ret then
              table.insert(out, "**Returns:** " .. ret)
            else
              local note = text:match("^[@\\]note%s+(.+)")
              if note then
                table.insert(out, "**Note:** " .. note)
              else
                local warn = text:match("^[@\\]warning%s+(.+)")
                if warn then
                  table.insert(out, "**Warning:** " .. warn)
                else
                  local sa_ref = text:match("^[@\\]sa%s+(.+)")
                  if sa_ref then
                    table.insert(out, "**See:** " .. sa_ref)
                  else
                    local see_ref = text:match("^[@\\]see%s+(.+)")
                    if see_ref then
                      table.insert(out, "**See:** " .. see_ref)
                    else
                      table.insert(out, text)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  return out
end

function M.hover()
  local ft = vim.bo.filetype
  if not (ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "cuda") then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor[1] - 1

  if not is_comment_line(bufnr, lnum) then
    return false
  end

  local start = lnum
  while start > 0 and is_comment_line(bufnr, start - 1) do
    start = start - 1
  end

  local total = vim.api.nvim_buf_line_count(bufnr)
  local finish = lnum
  while finish + 1 < total and is_comment_line(bufnr, finish + 1) do
    finish = finish + 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, start, finish + 1, false)
  local doc = parse_doxygen(lines)
  if #doc == 0 then
    return false
  end

  vim.lsp.util.open_floating_preview(doc, "markdown", { border = "rounded" })
  return true
end

return M
