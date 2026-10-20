local path = require("theme").palette_path()
local p = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
assert(type(p) == "table", "Palette must be a JSON object")
for _, name in ipairs({
  "base",
  "mantle",
  "surface",
  "surface2",
  "overlay",
  "overlay2",
  "text",
  "subtext",
  "muted",
  "faint",
  "periwinkle",
  "azure",
  "teal",
  "mint",
  "iris",
  "orchid",
  "pink",
  "blossom",
  "gold",
  "rose",
}) do
  assert(type(p[name]) == "string" and p[name]:match("^#%x%x%x%x%x%x$"), "Invalid palette color: " .. name)
end
p.name = type(p.name) == "string" and p.name or "stemdark"
p.dark = p.dark ~= false
local ansi = {}
for i, color in ipairs(p.ansi or {}) do
  assert(type(color) == "string" and color:match("^#%x%x%x%x%x%x$"), "Invalid ANSI palette color")
  ansi[i - 1] = color
end
p.ansi = ansi
return p
