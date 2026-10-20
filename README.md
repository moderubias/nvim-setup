# nvim-setup · Stemdark

Личная конфигурация Neovim для разработки, текстов и исследований.
lazy.nvim, нативный LSP, Blink completion, собственная монохромная тема
с прозрачным фоном. Leader и local leader — **Пробел**.

- **Разработка:** Rust, Python, Java, C/C++, Lua, Bash, TypeScript и Astro.
- **Инструменты:** Telescope, Neo-tree, Git, форматирование, DAP, Neotest и задачи проекта.
- **Тексты:** VimTeX, Markdown, сниппеты, шаблоны заметок и режим письма.
- **Исследования:** Jupyter через Molten, CSV, базы данных и изображения в Kitty.

[Использование и клавиши](docs/usage.md) ·
[Кастомизация](docs/customization.md) ·
[Проверки и работа с Git](docs/development.md)

## Требования

Основная платформа — Linux. Проверено локально на **Neovim 0.12.6**.
Нужен **Neovim 0.12+**: закреплённая версия
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) использует новый API.
Java и просмотр PDF настроены под Linux; для другой ОС их потребуется адаптировать.

Для установки плагинов, поиска и подсветки:

| Зависимость | Назначение |
| --- | --- |
| `git`, `curl`, `tar` | Загрузка плагинов и парсеров |
| `cc`, `make` | Компиляция парсеров и расширения Telescope |
| `tree-sitter` CLI **0.26.1+** | Сборка парсеров; устанавливать системным менеджером или Cargo, не npm |
| `rg` (ripgrep), `fd` | Поиск по содержимому и файлам |
| Node.js LTS и `npm` | Установка серверов и форматтеров через Mason |
| Nerd Font | Иконки; шрифт нужно выбрать в настройках терминала |
| `wl-clipboard` / `xclip` | Системный буфер обмена в Wayland / X11 |

Остальные зависимости нужны по мере использования:

| Сценарий | Что установить |
| --- | --- |
| Rust | Rust toolchain, Cargo, Clippy, rustfmt; rust-analyzer и codelldb — через Mason или отдельно |
| Python | Python 3; pytest в окружении проекта для тестов, pytest-asyncio для асинхронных тестов |
| Java / Android | JDK 21+ для JDTLS в `/usr/lib/jvm`, JDK проекта, Maven/Gradle или wrapper; Android SDK для APK |
| LaTeX | TeX Live с XeLaTeX, latexmk, latexindent; Zathura для PDF |
| Markdown preview | `glow` |
| Jupyter | Python provider с `pynvim`, `jupyter_client`, Jupyter и зарегистрированный kernel |
| Изображения | Kitty и ImageMagick (`magick`) |
| Базы данных | CLI выбранной БД и локальные параметры подключения |

## Установка

Сначала сохраните прежнюю конфигурацию. Если каталог уже существует:

```sh
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mv "$config_dir" "${config_dir}.backup-$(date +%Y%m%d-%H%M%S)"
```

Клонируйте репозиторий и запустите Neovim:

```sh
git clone https://github.com/moderubias/nvim-setup.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

Для работы с репозиторием по SSH используйте
`git@github.com:moderubias/nvim-setup.git` вместо HTTPS URL.

При первом запуске lazy.nvim установится сам и начнёт загрузку плагинов.
Дождитесь завершения установки и сборки. Затем выполните:

```vim
:Lazy restore
:TSInstallConfigured
:Mason
:checkhealth config
```

`Lazy restore` восстанавливает ревизии из `lazy-lock.json`. Парсеры устанавливаются
асинхронно; дождитесь завершения и перезапустите Neovim.
В Mason установите инструменты для нужных языков. Для установки всего
настроенного набора используйте `:MasonToolsInstall` — список находится
в [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua). Автоматическая установка
Mason-инструментов при открытии файла отключена.

Поиск файлов — `Ctrl+p`, поиск текста — `Ctrl+f`, дерево — `Ctrl+b`.
Нажмите Пробел и подождите: Which-key покажет доступные сочетания.

### Попробовать отдельно

Можно установить конфигурацию под другим именем, сохранив основной Neovim:

```sh
git clone https://github.com/moderubias/nvim-setup.git \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim-stemdark"
NVIM_APPNAME=nvim-stemdark nvim
```

Все последующие запуски этой копии выполняйте с `NVIM_APPNAME=nvim-stemdark`.
Neovim выделит ей отдельные каталоги плагинов, состояния и кеша.

## Структура

```text
init.lua                 Точка входа
lua/
  config/                Загрузка, параметры, клавиши, автокоманды, health
  plugins/               Спецификации lazy.nvim по назначению
  lsp/                   Общие LSP-настройки и подключение серверов
  languages/             Python, Rust, Java и языковые расширения
  features/              Задачи проекта и инструменты письма
  ui/                    Буферы, statusline, иконки и Discord
  theme/                 Палитра, токены и highlights Stemdark
colors/                  Точка входа colorscheme
ftplugin/                Настройки типов файлов
after/                   Дополнения filetype и синтаксиса
snippets/                LuaSnip-сниппеты Python и LaTeX
scripts/                 Проверки синтаксиса, поведения и интерфейса
docs/                    Использование, кастомизация и обслуживание
local.example.lua        Пример персональных настроек
lazy-lock.json           Закреплённые ревизии плагинов
```

`config` управляет запуском, `plugins` описывает зависимости и их настройки,
а собственное поведение вынесено в модули по назначению.
Личные настройки находятся в игнорируемом `local.lua`:

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
cp local.example.lua local.lua
```

Подробнее о хуках загрузки, плагинах, теме и сниппетах —
в [руководстве по кастомизации](docs/customization.md).

## Обновление

Получите изменения Git, восстановите версии плагинов и обновите парсеры:

```sh
git pull --ff-only
```

```vim
:Lazy restore
:TSUpdate
```

Если есть собственные изменения в отслеживаемых файлах, сначала сохраните их
коммитом или через stash. `local.lua` не участвует в обновлениях.
Для намеренного обновления самих плагинов используйте `:Lazy update`,
проверьте конфигурацию и закоммитьте изменившийся `lazy-lock.json`.
Подробнее о нём — в [документации lazy.nvim](https://lazy.folke.io/usage/lockfile).

## Проверка и решение проблем

```vim
:checkhealth config
:checkhealth lazy
:checkhealth vim.lsp
:ConformInfo
```

- **LSP не подключается:** проверьте сервер в `:Mason`, затем выполните
  `:LspRefresh`. Для Rust — `:RustAnalyzer start`.
- **Нет подсветки:** выполните `:TSInstallConfigured`; проверьте C-компилятор
  и версию `tree-sitter`. LaTeX использует синтаксис VimTeX.
- **Нет иконок:** выберите Nerd Font в терминале.
- **Не работает clipboard:** установите `wl-clipboard` или `xclip`
  и проверьте `:checkhealth vim.provider`.
- **Jupyter не запускается:** проверьте Python provider, `jupyter_client`
  и список kernels через `jupyter kernelspec list`.
- **Не открывается PDF:** проверьте Zathura и журнал `:VimtexInfo`.

Для проверки синтаксиса без установки плагинов из корня репозитория:

```sh
nvim --headless -u NONE -i NONE -l scripts/check-syntax.lua
```

Полные проверки и границы их покрытия описаны
в [руководстве для разработки](docs/development.md).
