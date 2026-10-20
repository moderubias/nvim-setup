local M = {}

local function inside_snippet(luasnip)
  local node = luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
  if not node then
    return false
  end
  local ok, first, last = pcall(node.parent.snippet.mark.pos_begin_end, node.parent.snippet.mark)
  if not ok then
    return false
  end
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  return (row > first[1] or (row == first[1] and col >= first[2]))
    and (row < last[1] or (row == last[1] and col <= last[2]))
end

function M.active(filter)
  local luasnip = require("luasnip")
  local direction = filter and filter.direction or 1
  return (inside_snippet(luasnip) and luasnip.locally_jumpable(direction)) or (direction == 1 and luasnip.expandable())
end

function M.jump(direction)
  local luasnip = require("luasnip")
  if direction == 1 and luasnip.expandable() then
    return luasnip.expand()
  end
  if inside_snippet(luasnip) and luasnip.locally_jumpable(direction) then
    return luasnip.jump(direction)
  end
  return false
end

return M
