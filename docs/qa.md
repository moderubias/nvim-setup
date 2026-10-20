# QA report

[← README](../README.md) · [Running the checks](development.md)

Tested on Linux with Neovim 0.12.6 and the revisions in `lazy-lock.json`.

## Fixed regressions

| Scenario | Cause | Result |
| --- | --- | --- |
| Fast navigation after opening a file | Navigation relied on Bufferline's last rendered state | Shift+H / Shift+L use the current buffer list in panel order |
| Closing the current buffer | The alternate buffer from navigation history was selected | Select the right neighbor, or the left neighbor at the right edge |
| Tab returns to an old snippet | LuaSnip allowed jumping to a field outside the current snippet region | Check the current buffer, row, and column against the snippet region |
| Old fields remain active after deletion | Session cleanup did not cover text changes in Insert mode | Check snippet state on cursor movement and text changes |
| Rust derive completion | The provider's configured module name did not match its new path | Load the provider, suggest Clone, and exclude an existing Debug derive |
| Incomplete external palette | Valid JSON with missing colors passed loading | Validate tokens and fall back to the built-in palette |

## Results

- **47 Lua files:** syntax, local module references, and lockfile structure.
- **12 configuration checks:** resize behavior, modified-buffer protection,
  projects and tasks, Python environments, palettes, completion modules, health,
  project terminals, language plugins, LSP, templates, and asynchronous errors.
- **27 UI checks:** registers and clipboard, undo/repeat, mouse input, buffer
  closing, navigation before redraw and across list boundaries, tabpages,
  Tab/Shift+Tab, deleted snippets, buffer switches, Rust completion, and Markdown.
- StyLua, Python syntax, local documentation links, and whitespace checks.

All listed checks pass. Regression coverage lives in `scripts/check.lua`,
`scripts/check-ui.py`, and `scripts/check-syntax.lua`.

External GUI applications, Discord, live Jupyter kernels, PDF/SyncTeX,
the Android SDK, and debugging individual projects are outside this automated run.
