# Кастомизация

[← README](../README.md)

## Личные настройки

Скопируйте `local.example.lua` в `local.lua` в корне конфигурации.
`local.lua` исключён из Git и должен возвращать таблицу с необязательными полями:

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

Порядок загрузки:

1. Чтение `local.lua` и базовые `config.options`.
2. `init()` — глобальные переменные, leader, Python provider, ранние параметры.
3. Основные клавиши и lazy.nvim; `plugins` добавляется после общих спецификаций.
4. Тема, автокоманды и функции конфигурации.
5. `setup()` — окончательные параметры и переопределения глобальных клавиш.

Изменения применяются после перезапуска Neovim. `setup()` не означает загрузку
всех ленивых плагинов: их параметры задавайте через `plugins` и `opts`.
Клавиши конкретного filetype могут устанавливаться позже; меняйте их через
`after/ftplugin/<filetype>.lua` или собственный `FileType` callback.

## Плагины и языки

Общие спецификации находятся в `lua/plugins/`. Каждый файл возвращает список
спецификаций lazy.nvim. Новый такой файл подключится автоматически.

В `local.lua` можно дополнить `opts` существующего плагина или отключить его:

```lua
plugins = {
  { "vyfor/cord.nvim", enabled = false },
  {
    "nvim-telescope/telescope.nvim",
    opts = { defaults = { layout_strategy = "vertical" } },
  },
}
```

Если плагин настроен через `config = function()` без передачи `opts`,
меняйте его общую функцию `config` или переопределите её своей спецификацией.
Имена модулей из `lua/languages/`, `lua/ui/` и других каталогов подключаются
через `require`; сами по себе новые файлы в этих каталогах не запускаются.

| Что изменить | Где |
| --- | --- |
| Общие параметры | `lua/config/options.lua` |
| Клавиши | `lua/config/keymaps.lua`, `keys` в plugin spec, языковые модули |
| Автокоманды | `lua/config/autocmds.lua` |
| LSP-серверы | `lua/lsp/init.lua` |
| Список Mason-инструментов | `lua/plugins/lsp.lua` |
| Tree-sitter парсеры | `lua/plugins/editing.lua` |
| Completion | `lua/plugins/completion.lua`, `completion_rust.lua` |
| Форматтеры и форматирование при сохранении | `lua/plugins/formatting.lua` |
| Python / Rust / Java | `lua/languages/` и соответствующие plugin specs |
| Задачи и корни проектов | `lua/features/workspace.lua` |
| Шаблоны заметок | `lua/features/writing.lua` |
| Statusline / буферы | `lua/ui/` |

## Тема

Stemdark использует встроенную палитру без внешних файлов.
Если существует `../theme/active/palette.json` относительно каталога конфигурации,
она читается вместо встроенной. При отсутствии файла, ошибке чтения/JSON
или неполном наборе корректных цветов используется запасная палитра. Полный набор токенов встроенной палитры находится
в `lua/theme/init.lua`, в функции `tokens()`.

Другой путь можно задать в `init()`:

```lua
vim.g.stemdark_palette = "~/my-theme/palette.json"
```

JSON должен содержать полный набор цветовых токенов. `ansi` — массив цветов,
начиная с терминального цвета 0; `dark` по умолчанию равен `true`.
После изменения палитры выполните:

```vim
:lua require("theme").reload()
```

Изменения времени модификации файла также проверяются при возвращении фокуса.
Группы подсветки и прозрачность настраиваются в `lua/theme/highlights.lua`.
`Space ut` повторно применяет Stemdark. Если рядом с конфигурацией установлен
личный переключатель `theme/themux.sh`, команда также вызывает его;
для работы редактора переключатель не требуется.

## Сниппеты, форматирование и окружения

LuaSnip загружает `snippets/<filetype>.lua`. Добавьте или измените сниппеты
в этих файлах. Tab раскрывает сниппет и переключает поля, Shift+Tab идёт назад.
Готовые примеры находятся в `snippets/python.lua` и `snippets/tex.lua`.

Python форматируется при сохранении. Для отключения глобально установите
`vim.g.disable_autoformat = true` в `init()`; для одного буфера —
`vim.b.disable_autoformat = true`. Остальные языки форматируются вручную
через `Space cf`. Состав форматтеров задаёт Conform.

Python сначала ищет окружение проекта (`.venv`, `venv`, `env`), затем активное
Virtualenv/Conda и Python в PATH. `Space pv` выбирает интерпретатор для текущей
сессии. Для Molten Python provider и Jupyter kernel настраиваются отдельно.
Путь к provider можно зафиксировать через `vim.g.python3_host_prog` в `init()`.

Discord presence по умолчанию включён и может показывать имя файла и проекта.
`vim.g.discord_presence = false` в `init()` отключает загрузку Cord.
Параметры подключения к базам данных и другие личные пути храните в `local.lua`
или окружении; `.env` также исключён из Git.
