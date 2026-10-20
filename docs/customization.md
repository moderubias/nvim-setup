# Customization

[← README](../README.md)

## Personal settings

Copy `local.example.lua` to `local.lua` at the configuration root.
`local.lua` is ignored by Git and must return a table with optional fields:

```lua
return {
  init = function()
    vim.g.mapleader = ","
    vim.g.discord_presence = false
    vim.g.disable_autoformat = true
  end,
  plugins = {
    { "folke/zen-mode.nvim", opts = { window = { width = 100 } } },
  },
  setup = function()
    vim.opt.relativenumber = true
    vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
  end,
}
```

Startup order:

1. Read `local.lua` and apply the base `config.options`.
2. Run `init()` for globals, leader keys, the Python provider, and early settings.
3. Load the main keybindings and lazy.nvim; append `plugins` after the shared specifications.
4. Set up the theme, autocmds, and custom features.
5. Run `setup()` for final options and global keybinding overrides.

Restart Neovim to apply changes. Lazy plugins may still be unloaded when
`setup()` runs; configure them through `plugins` and `opts`.
Filetype keybindings may be defined later. Override them in
`after/ftplugin/<filetype>.lua` or your own `FileType` callback.

## Plugins and languages

Shared specifications live in `lua/plugins/`. Each file returns a list of
lazy.nvim specifications. New files in that directory are imported automatically.

Use `local.lua` to extend a plugin's `opts` or disable it:

```lua
plugins = {
  { "vyfor/cord.nvim", enabled = false },
  {
    "nvim-telescope/telescope.nvim",
    opts = { defaults = { layout_strategy = "vertical" } },
  },
}
```

If a plugin uses `config = function()` without accepting `opts`, edit that
function or replace it in your specification. Modules in `lua/languages/`,
`lua/ui/`, and other directories are loaded through `require`; adding a file
to those directories does not run it automatically.

| Setting | Location |
| --- | --- |
| General options | `lua/config/options.lua` |
| Keybindings | `lua/config/keymaps.lua`, plugin `keys`, and language modules |
| Autocmds | `lua/config/autocmds.lua` |
| LSP servers | `lua/lsp/init.lua` |
| Mason tools | `lua/plugins/lsp.lua` |
| Tree-sitter parsers | `lua/plugins/editing.lua` |
| Completion | `lua/plugins/completion.lua`, `completion_rust.lua` |
| Formatters and formatting on save | `lua/plugins/formatting.lua` |
| Python / Rust / Java | `lua/languages/` and the corresponding plugin specifications |
| Project tasks and roots | `lua/features/workspace.lua` |
| Note templates | `lua/features/writing.lua` |
| Statusline / buffers | `lua/ui/` |

## Theme

Stemdark works with its built-in palette without external files.
If `../theme/active/palette.json` exists relative to the configuration directory,
it is loaded instead. Missing files, invalid JSON, and incomplete or invalid
color tokens fall back to the built-in palette. The full set of default tokens
is in `tokens()` in `lua/theme/init.lua`.

Set a different path in `init()`:

```lua
vim.g.stemdark_palette = "~/my-theme/palette.json"
```

The JSON must contain the full set of color tokens. `ansi` is an array starting
with terminal color 0; `dark` defaults to `true`.
After editing the palette, run:

```vim
:lua require("theme").reload()
```

The palette's modification time is also checked when Neovim regains focus.
Edit `lua/theme/highlights.lua` to change highlight groups and transparency.
`Space ut` reapplies Stemdark. If the personal `theme/themux.sh` switcher exists
next to the configuration directory, this action also invokes it.
The switcher is optional.

## Snippets, formatting, and environments

LuaSnip loads `snippets/<filetype>.lua`. Add or edit snippets in these files.
Tab expands a snippet and moves between its fields; Shift+Tab moves backward.
Examples are in `snippets/python.lua` and `snippets/tex.lua`.

Python is formatted on save. Set `vim.g.disable_autoformat = true` in `init()`
to disable this globally, or `vim.b.disable_autoformat = true` for one buffer.
Other languages are formatted manually with `Space cf`.
Conform controls the formatter list.

Python searches the project environment (`.venv`, `venv`, `env`) before the
active Virtualenv/Conda environment and Python on PATH. `Space pv` selects an
interpreter for the current session. Molten's Python provider and Jupyter kernel
are configured separately. Set `vim.g.python3_host_prog` in `init()` to pin the
provider's interpreter.

Discord presence is enabled by default and can show file and project names.
Set `vim.g.discord_presence = false` in `init()` to disable Cord.
Keep database connections and personal paths in `local.lua` or environment
variables; `.env` is also ignored by Git.
