# Development and publishing

[← README](../README.md)

## Checks

Run commands from the repository root.
See the [QA results and regression scenarios](qa.md).

Check Lua and `lazy-lock.json` without loading the configuration or plugins:

```sh
nvim --headless -u NONE -i NONE -l scripts/check-syntax.lua
```

Run behavior checks with the plugins installed and Python 3 available:

```sh
nvim --headless -i NONE '+lua dofile("scripts/check.lua")'
```

These cover syntax, tabpages, buffer closing, project roots and tasks, Python
interpreter selection, language plugins, LSP, and note templates.
The checks open temporary language buffers, so available LSP servers may start.

Keyboard and UI checks require the Python `pynvim` package:

```sh
python3 scripts/check-ui.py
```

The script attaches a virtual UI through Neovim RPC and uses a test clipboard
provider. It checks registers, copy/delete/paste, undo/repeat, mouse and command
buffer closing, navigation before redraw, tabpages, Tab/Shift+Tab inside and
outside snippets, Rust completion, and Markdown rendering.
Asynchronous error notifications also fail the check.

PDF/SyncTeX, Kitty, Discord, Jupyter, real projects, and debugging sessions need
separate testing. GitHub Actions checks Lua/Python syntax, local module
references, the lockfile structure, and whitespace. It does not require plugins,
Mason, a graphical session, or personal configuration files.

## Style

Format Lua with StyLua using `.stylua.toml`. General indentation and line ending
rules are defined in `.editorconfig` and `.gitattributes`.

```sh
stylua --check init.lua local.example.lua lua colors ftplugin after snippets scripts
git diff --check
```

Remove `--check` from the StyLua command to apply formatting.
Keep language behavior in `lua/languages/`, UI code in `lua/ui/`, and project
features in `lua/features/`. Plugin specifications should describe loading
conditions, dependencies, and plugin settings.

## Tracked files

- Configuration, snippets, documentation, examples, and checks.
- `lazy-lock.json`, which pins plugin revisions for reproducible installation.
- `.github/workflows/check.yml`, which runs checks on pushes and pull requests.

`.gitignore` excludes `local.lua`, `.env`, Serena and IDE state, caches,
sessions, dictionaries, temporary files, and backups. These may remain on your
machine without entering commits. Neovim normally stores plugins, Mason, undo,
ShaDa, and caches outside the configuration directory, under `stdpath("data")`,
`stdpath("state")`, and `stdpath("cache")`.

Inspect the actual paths:

```vim
:lua for _, key in ipairs({"config", "data", "state", "cache"}) do print(key, vim.fn.stdpath(key)) end
```

Ignoring files does not remove them from earlier commits. Legacy `lua/user/`
modules, Packer output, and `*.save` / `*.bak` backups have been removed from the
current tree; older versions remain in Git history.

## Publishing

The target repository is [moderubias/nvim-setup](https://github.com/moderubias/nvim-setup).
Verify the remote and review your changes:

```sh
git remote -v
git status --short
git diff --check
```

After running the checks:

```sh
git add -A
git diff --cached --stat
git diff --cached --check
git commit -m "Update Neovim configuration"
git push -u origin main
```

`git add -A` includes file deletions and respects `.gitignore`.
Review the staged changes before publishing.
