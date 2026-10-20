local M = {}

local function is_normal(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

function M.ordered()
  if vim.o.tabline ~= "" then
    vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true })
  end

  local buffers, seen = {}, {}
  local bufferline = package.loaded["bufferline"]
  if bufferline then
    for _, item in ipairs(bufferline.get_elements().elements) do
      if is_normal(item.id) then
        buffers[#buffers + 1] = item.id
        seen[item.id] = true
      end
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_normal(buf) and not seen[buf] then
      buffers[#buffers + 1] = buf
    end
  end
  return buffers
end

function M.cycle(direction)
  local buffers = M.ordered()
  if #buffers == 0 then
    return
  end
  local current = vim.api.nvim_get_current_buf()
  local index = direction > 0 and 0 or 1
  for i, buf in ipairs(buffers) do
    if buf == current then
      index = i
      break
    end
  end
  vim.api.nvim_set_current_buf(buffers[(index - 1 + direction) % #buffers + 1])
end

local function replacement_for(buf)
  local buffers = M.ordered()
  for index, candidate in ipairs(buffers) do
    if candidate == buf then
      local neighbour = buffers[index + 1] or buffers[index - 1]
      if neighbour then
        return neighbour
      end
      break
    end
  end
  for _, candidate in ipairs(buffers) do
    if candidate ~= buf then
      return candidate
    end
  end

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].bufhidden = "wipe"
  return scratch
end

function M.visible_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_normal(buf) then
      count = count + 1
    end
  end
  return count
end

function M.refresh()
  if M.refresh_pending then
    return
  end
  M.refresh_pending = true
  vim.schedule(function()
    M.refresh_pending = false
    if vim.o.tabline ~= "" then
      vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true })
    end
    if M.visible_count() <= 1 then
      vim.o.showtabline = 0
    else
      vim.o.showtabline = 2
    end
    vim.cmd("redrawtabline")
    vim.cmd("redraw!")
  end)
end

function M.close(buf, force)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  if vim.bo[buf].modified and not force then
    vim.notify("Save changes or use <leader>bD", vim.log.levels.WARN, { title = "Buffer kept" })
    return
  end

  local windows = vim.fn.win_findbuf(buf)
  local replacement = #windows > 0 and replacement_for(buf) or nil
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end

  local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = force == true, unload = false })
  if not ok then
    vim.notify(err, vim.log.levels.ERROR, { title = "Could not close buffer" })
    return
  end

  M.refresh()
end

function M.close_others()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and is_normal(buf) and not vim.bo[buf].modified then
      M.close(buf, false)
    end
  end
  M.refresh()
end

function M.is_visible(buf)
  return is_normal(buf)
end

return M
