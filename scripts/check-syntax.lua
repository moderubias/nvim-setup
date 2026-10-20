local paths = { "init.lua", "local.example.lua" }
for _, directory in ipairs({ "lua", "colors", "ftplugin", "after", "snippets", "scripts" }) do
  vim.list_extend(paths, vim.fn.glob(directory .. "/**/*.lua", false, true))
end

for _, path in ipairs(paths) do
  assert(loadfile(path))
  local source = table.concat(vim.fn.readfile(path), "\n")
  for name in source:gmatch([=[['"]([%w_]+%.[%w_.]+)['"]]=]) do
    local root = name:match("^(%w+)%.")
    if vim.tbl_contains({ "config", "features", "languages", "theme", "ui" }, root) then
      local module = "lua/" .. name:gsub("%.", "/")
      assert(
        vim.uv.fs_stat(module .. ".lua") or vim.uv.fs_stat(module .. "/init.lua"),
        path .. ": missing module " .. name
      )
    end
  end
end

local lock = vim.json.decode(table.concat(vim.fn.readfile("lazy-lock.json"), "\n"))
for name, entry in pairs(lock) do
  assert(type(entry.branch) == "string", "Missing branch: " .. name)
  assert(
    type(entry.commit) == "string" and entry.commit:match("^%x+$") and #entry.commit == 40,
    "Invalid commit: " .. name
  )
end

print(string.format("PASS: %d Lua files; valid plugin lockfile", #paths))
