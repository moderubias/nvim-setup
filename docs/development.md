# Разработка и публикация

[← README](../README.md)

## Проверки

Команды выполняются из корня репозитория.
[Результаты последнего QA и исправленные сценарии](qa.md).

Проверка Lua и `lazy-lock.json` без загрузки конфигурации и плагинов:

```sh
nvim --headless -u NONE -i NONE -l scripts/check-syntax.lua
```

Проверка поведения с установленными плагинами и Python 3:

```sh
nvim --headless -i NONE '+lua dofile("scripts/check.lua")'
```

Проверяются синтаксис, вкладки, закрытие буферов, корни проектов, задачи,
выбор Python, загрузка языковых плагинов, LSP и шаблоны заметок.
Проверка открывает временные языковые буферы; доступные LSP могут запускаться.

Проверка клавиатуры и интерфейса требует Python-пакет `pynvim`:

```sh
python3 scripts/check-ui.py
```

Скрипт подключает виртуальный UI через Neovim RPC, подменяет clipboard тестовым
провайдером и проверяет регистры, копирование, удаление, вставку, undo/repeat,
закрытие буферов мышью и командами, переходы до перерисовки, вкладки Neovim,
Tab/Shift+Tab внутри и вне сниппетов, Rust completion и оформление Markdown.
Ошибки асинхронных уведомлений также приводят к провалу проверки.

PDF/SyncTeX, Kitty, Discord, Jupyter, реальные проекты и отладочные сессии
нужно проверять отдельно. GitHub Actions выполняет только проверку синтаксиса
Lua/Python, локальных ссылок на модули, структуры lockfile и пробельных ошибок: для неё не нужны плагины,
Mason, графическая сессия или персональные файлы.

## Стиль

Lua форматируется StyLua по `.stylua.toml`; общие отступы и окончания строк
описаны в `.editorconfig` и `.gitattributes`.

```sh
stylua --check init.lua local.example.lua lua colors ftplugin after snippets scripts
git diff --check
```

Для форматирования выполните ту же команду StyLua без `--check`.
Собственные языковые функции держите в `lua/languages/`, интерфейс —
в `lua/ui/`, поведение проекта — в `lua/features/`. В plugin spec оставляйте
условия загрузки, зависимости и параметры самого плагина.

## Что хранится в Git

- Конфигурация, сниппеты, документация, примеры и проверки.
- `lazy-lock.json`: ревизии плагинов нужны для воспроизводимой установки.
- `.github/workflows/check.yml`: проверки при push и pull request.

В `.gitignore` исключены `local.lua`, `.env`, данные Serena и IDE,
кеши, сессии, словари, временные файлы и резервные копии. Они могут оставаться
на компьютере, но не должны попадать в коммит. Neovim обычно хранит плагины,
Mason, undo, ShaDa и кеши за пределами конфигурации — в `stdpath("data")`,
`stdpath("state")` и `stdpath("cache")`.

Посмотреть реальные пути:

```vim
:lua for _, key in ipairs({"config", "data", "state", "cache"}) do print(key, vim.fn.stdpath(key)) end
```

Игнорирование не удаляет файлы из старых коммитов. Устаревшие модули
`lua/user/`, Packer и резервные `*.save` / `*.bak` не нужны в новой структуре;
их удаление должно войти в следующий коммит вместе с новыми модулями.

## Публикация

Целевой репозиторий: [moderubias/nvim-setup](https://github.com/moderubias/nvim-setup).
Настроенный remote должен совпадать с ним:

```sh
git remote -v
git status --short
git diff --check
```

После проверки изменений:

```sh
git add -A
git diff --cached --stat
git diff --cached --check
git commit -m "Organize Neovim configuration and document setup"
git push -u origin main
```

`git add -A` включает удаления прежних файлов и соблюдает `.gitignore`.
Проверьте подготовленный коммит перед публикацией.
