# Usage

[← README](../README.md)

## Main commands

| Keys / command | Action |
| --- | --- |
| Ctrl+p / Ctrl+f | Find files / search the project |
| Ctrl+b | File tree |
| Space fb / bd / bo | List buffers / close buffer / close other unmodified buffers |
| gd / gr / K | Definition / references / documentation |
| Space rn / ca / cf | Rename / code action / format |
| Space ci | Inlay hints |
| Space xx / xd | Project diagnostics / current-line diagnostics |
| Space gg | Git |
| Space sr | Project search and replace |
| Space qs / qS | Restore session / select session |
| Space tp / `:ProjectTask` | Cargo tasks or package.json scripts from the project root |
| Space tr / tt | Run an Overseer task / show task list |
| Space tg | Terminal |
| Space uz | Focused writing mode |
| Space uh / `:checkhealth config` | Configuration dependencies |
| `:LspRefresh` | Attach newly installed language servers |

The top panel displays **file buffers**. Shift+L / Shift+H select the next /
previous buffer in panel order, wrapping at the ends. New buffers are appended.
Clicking selects the corresponding buffer. Closing the current buffer selects
its right neighbor, or its left neighbor at the right edge.
Navigation does not depend on the panel's last redraw.

`gt` / `gT` switch Neovim tabpages created with `:tabnew`.
Tabpages are separate window layouts; Shift+H / Shift+L keep the current tabpage
and change only its buffer.

`ProjectTask` lists actual npm scripts, including `dev`, `build`, and `check`
when present. The package manager is detected from `packageManager` or a lockfile.
Selecting a running task opens its existing terminal; stop it with Ctrl+c there.
The command does not save unsaved changes.

Resizing preserves the active tabpage. After `:q`, `:wq`, `:x`, or `ZZ`, the
closed window's unmodified file buffer is removed from the panel if no other
window displays it. A canceled quit preserves the buffer; `:q!` retains its
normal forced-quit behavior.
Mason installations are detected automatically. For servers installed outside
Mason, enter a buffer, regain focus, or run `:LspRefresh`.
Restart Neovim after changing Lua configuration. Reload the palette with
`:lua require("theme").reload()`.

Normal `d`/`dd`/`D`, `x`, `c`, and `s`, including visual deletions, preserve paste
registers and the system clipboard. Copy with `y`/`yy`.
Explicit named registers such as `"ad` keep their normal behavior.
Repeat with `.` and undo with `u` work as usual.

The panel shows ordinary file buffers and hides when fewer than two remain.
Closing updates both the panel and navigation, including while the panel is
hidden. Utility buffers do not make it reappear.

## Rust and Python

Rust uses rustaceanvim, rust-analyzer, Clippy, Cargo completion, and codelldb.
The Mason rust-analyzer takes priority over the rustup proxy.
An empty Cargo.toml produces one warning; after fixing it, run `:RustAnalyzer start`.
`ProjectTask` offers `cargo check`, `clippy`, `test`, `bench`, and `run`.

| Keys | Action |
| --- | --- |
| Space rr / rt / rd | Rust runnable / test / debug |
| Space re / rD / rc | Expand macro / docs.rs / Cargo.toml |
| Space rR | Restart rust-analyzer |
| Space pi / pv | Python environment info / select interpreter |
| Space pr | Save and run the Python file |
| Space pf / po / pF | Ruff format / organize imports / toggle formatting on save |
| F5 / F9 / F10 / F11 / Shift+F5 | Debug / breakpoint / step over / step into / stop |
| Space tT / tF / tA / tD | Nearest test / file / project / debug test |
| Space ts / to / tx | Test summary / output / stop |

Python uses Pyright for types and Ruff for linting and formatting.
Interpreter priority: project selection → project `.venv`/`venv`/`env` → active
Virtualenv/Conda → Python on PATH. Manual selection lasts for the current session.
Tests run from the project root and require pytest in the selected environment;
async tests also require pytest-asyncio.

Python is formatted on save, except for files exceeding 10,000 lines.
Set `vim.g.disable_autoformat = true` to disable it globally.
The debugger loads `.env` from the project root; ordinary runs and tests manage
their own environment.

Snippets: `amain`, `adef`, `atest`, `amock`, `afix`, `logger`, `experiment`.
The experiment template includes `--seed`, `--output`, a timer, and JSON metrics;
replace the placeholder metric with your own. Its seed controls only Python's
local random generator, not NumPy/PyTorch.
Tab expands a snippet at the cursor and moves between active fields;
Shift+Tab moves backward. Outside a snippet, Tab inserts normal indentation.
Old fields on another line or behind the cursor do not capture the key.
Ctrl+Space opens completion; Ctrl+y accepts an item.

## LaTeX and Markdown

VimTeX handles XeLaTeX/latexmk builds and PDF viewing through Zathura.
Texlab provides LSP support. Project settings and `% !TeX program` take precedence.
Build output goes to `build/`; use `% !TeX root` for individual chapter files.
Saving `.tex`/`.ltx` starts a build if a continuous compiler is not already running.

| Keys | Action |
| --- | --- |
| Space ll / lL / lk | Continuous build / build once / stop |
| Space la | Toggle build on save for the current buffer |
| Space lv / le / lo | PDF / errors / build log |
| Space lt / li / ls | Table of contents / project info / status |
| Space lm / lz | Source TeX or conceal / writing mode |
| Space wn / `:NoteTemplate` | Create a note from a template |
| Space wc / `:WritingStats` | Word and character counts, estimated speaking time |
| `:Glow` | Preview Markdown in the terminal |

`NoteTemplate research`, `proof`, `video`, and `stream` create an unsaved Markdown
buffer for a research note, proof, video script, or stream outline.
Save with `:w path.md`. Speaking time is estimated at 150 words per minute.

Markdown supports rendered tables and checklists, Marksman, and formatting.
Code blocks use a dark background sized to their contents.
Spell checking is off by default; Space us toggles it for the current window.
Set the language with `:setlocal spelllang=...` and install the corresponding
dictionary if needed.
LaTeX snippets: `xedoc`, `beg`, `eqn`, `align`, `dm`, `mm`, `frac`, `sum`, `int`,
`fig`, `tbl`, `theorem`, `proof`, `ref`, `cite`, `sec`, `ssec`, `pkg`, `cmd`, `expl`.
The `xedoc` template requires the fonts and TeX packages named in its body.

## HTML, Astro, and TypeScript

Astro LSP, TypeScript LSP, HTML/CSS, Emmet, and Tailwind attach by filetype.
ESLint runs through LSP. Prettier prefers the project's installed version.
For Astro, install `prettier` and `prettier-plugin-astro` in the project and
add the plugin to its Prettier configuration. A Mason copy of the plugin is
used as a fallback when available. MDX is formatted with Prettier.

See the [official Astro editor setup guide](https://docs.astro.build/en/editor-setup/).
Start a dev server with Space tp → `dev` when that script exists in package.json.

## Research

Molten: Space ni selects a kernel, nl evaluates a line, ne evaluates a visual
selection, nr reevaluates a cell, no shows output, nx interrupts, and nq shuts
down the kernel.
It requires a Python provider (`pynvim`), `jupyter_client`, Jupyter, and a
registered kernel for the target environment, for example through ipykernel.
Run `:checkhealth vim.provider`. Selecting a Pyright interpreter does not switch
the Jupyter kernel; select it separately with MoltenInit.

Space uv toggles CSV tables. Image viewing requires Kitty and ImageMagick
(`magick`). Java/JDTLS and native debugging are also available.
