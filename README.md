# nvim-setup · Stemdark

A personal Neovim configuration for development, writing, and research.
lazy.nvim, native LSP, Blink completion, and a custom monochrome theme
with a transparent background. Both leader keys are **Space**.

- **Development:** Rust, Python, Java, C/C++, Lua, Bash, TypeScript, and Astro.
- **Tools:** Telescope, Neo-tree, Git, formatting, DAP, Neotest, and project tasks.
- **Writing:** VimTeX, Markdown, snippets, note templates, and a focused writing mode.
- **Research:** Jupyter through Molten, CSV tables, databases, and images in Kitty.

[Usage and keybindings](docs/usage.md) ·
[Customization](docs/customization.md) ·
[Development and publishing](docs/development.md)

## Requirements

The primary platform is Linux. Tested locally with **Neovim 0.12.6**.
**Neovim 0.12+** is required by the pinned version of
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).
Java runtime discovery and PDF viewing are configured for Linux and need
adjustments on other operating systems.

For plugin installation, search, and syntax highlighting:

| Dependency | Purpose |
| --- | --- |
| `git`, `curl`, `tar` | Download plugins and parsers |
| `cc`, `make` | Build parsers and the native Telescope extension |
| `tree-sitter` CLI **0.26.1+** | Build parsers; install through a system package manager or Cargo, not npm |
| `rg` (ripgrep), `fd` | Search file contents and names |
| Node.js LTS and `npm` | Install language servers and formatters through Mason |
| Nerd Font | Display icons; select the font in your terminal settings |
| `wl-clipboard` / `xclip` | System clipboard on Wayland / X11 |

Install additional dependencies for the features you use:

| Feature | Dependencies |
| --- | --- |
| Rust | Rust toolchain, Cargo, Clippy, rustfmt; rust-analyzer and codelldb through Mason or separately |
| Python | Python 3; pytest in the project environment, plus pytest-asyncio for async tests |
| Java / Android | JDK 21+ for JDTLS under `/usr/lib/jvm`, the project's JDK, Maven/Gradle or a wrapper; Android SDK for APK builds |
| LaTeX | TeX Live with XeLaTeX, latexmk, latexindent; Zathura for PDF viewing |
| Markdown preview | `glow` |
| Jupyter | A Python provider with `pynvim`, `jupyter_client`, Jupyter, and a registered kernel |
| Images | Kitty and ImageMagick (`magick`) |
| Databases | The selected database's CLI and local connection settings |

## Installation

Back up your existing configuration first. If the directory exists:

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mv "$config_dir" "${config_dir}.backup-$(date +%Y%m%d-%H%M%S)"
```

Clone the repository and start Neovim:

```sh
git clone https://github.com/moderubias/nvim-setup.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

For SSH access, use `git@github.com:moderubias/nvim-setup.git` instead of the HTTPS URL.

On the first launch, lazy.nvim bootstraps itself and starts installing plugins.
Wait for installation and builds to finish, then run:

```vim
:Lazy restore
:TSInstallConfigured
:Mason
:checkhealth config
```

`Lazy restore` restores the revisions in `lazy-lock.json`. Parser installation
is asynchronous; let it finish and restart Neovim.
Use Mason to install tools for your languages. To install the entire configured
set, run `:MasonToolsInstall`; the list lives in
[`lua/plugins/lsp.lua`](lua/plugins/lsp.lua).
Automatic Mason tool installation when opening files is disabled.

Find files with `Ctrl+p`, search text with `Ctrl+f`, and open the file tree
with `Ctrl+b`. Press Space and pause to see available Which-key bindings.

### Try it alongside your current setup

Install under a separate application name:

```sh
git clone https://github.com/moderubias/nvim-setup.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim-stemdark"
NVIM_APPNAME=nvim-stemdark nvim
```

Use `NVIM_APPNAME=nvim-stemdark` for every subsequent launch of this copy.
Neovim gives it separate plugin, state, and cache directories.

## Structure

```text
init.lua                 Entry point
lua/
  config/                Startup, options, keybindings, autocmds, and health checks
  plugins/               lazy.nvim specifications grouped by purpose
  lsp/                   Shared LSP settings and server setup
  languages/             Python, Rust, Java, and language-specific extensions
  features/              Project tasks, snippets, and writing tools
  ui/                    Buffers, statusline, icons, and Discord
  theme/                 Stemdark palette, tokens, and highlights
colors/                  Colorscheme entry point
ftplugin/                Filetype settings
after/                   Filetype and syntax extensions
snippets/                Python and LaTeX LuaSnip snippets
scripts/                 Syntax, behavior, and UI checks
docs/                    Usage, customization, and maintenance guides
local.example.lua        Example personal configuration
lazy-lock.json           Pinned plugin revisions
```

`config` controls startup, `plugins` describes dependencies and their settings,
and custom behavior lives in modules organized by purpose.
Keep personal settings in the ignored `local.lua` file:

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
cp local.example.lua local.lua
```

See the [customization guide](docs/customization.md) for startup hooks, plugin
overrides, themes, and snippets.

## Updates

Pull configuration changes, restore plugin revisions, and update parsers:

```sh
git pull --ff-only
```

```vim
:Lazy restore
:TSUpdate
```

Commit or stash changes to tracked files before pulling. `local.lua` is not
tracked. To update plugins intentionally, run `:Lazy update`, check the
configuration, and commit the updated `lazy-lock.json`.
See the [lazy.nvim lockfile documentation](https://lazy.folke.io/usage/lockfile).

## Health checks and troubleshooting

```vim
:checkhealth config
:checkhealth lazy
:checkhealth vim.lsp
:ConformInfo
```

- **LSP does not attach:** check the server in `:Mason`, then run `:LspRefresh`.
  For Rust, use `:RustAnalyzer start`.
- **Missing highlighting:** run `:TSInstallConfigured`; check your C compiler
  and `tree-sitter` version. LaTeX uses VimTeX syntax highlighting.
- **Missing icons:** select a Nerd Font in your terminal.
- **Clipboard does not work:** install `wl-clipboard` or `xclip` and run
  `:checkhealth vim.provider`.
- **Jupyter does not start:** check the Python provider, `jupyter_client`, and
  the output of `jupyter kernelspec list`.
- **PDF does not open:** check Zathura and `:VimtexInfo`.

Check syntax without installing plugins, from the repository root:

```sh
nvim --headless -u NONE -i NONE -l scripts/check-syntax.lua
```

See the [development guide](docs/development.md) for the full checks and their coverage.
