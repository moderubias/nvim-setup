local path = vim.fn.stdpath("config") .. "/local.lua"
if not vim.uv.fs_stat(path) then
  return {}
end

local custom = dofile(path)
assert(type(custom) == "table", "local.lua must return a table")
return custom
