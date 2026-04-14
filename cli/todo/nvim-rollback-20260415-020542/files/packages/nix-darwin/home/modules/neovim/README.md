# Neovim через Nix (гайд для начинающих)

Этот документ объясняет, как пользоваться твоей декларативной Neovim-конфигурацией на `nix-darwin + home-manager`.

Сейчас есть **2 backend-режима**:

- `compat` — точное поведение старого `LazyVim` (файлы из `~/dotfiles/home/nvim`)
- `nixvim` — переписанная декларативная конфигурация через `nixvim`

---

## 1) Что у тебя уже настроено

Твоя конфигурация Neovim разбита на модули:

- `default.nix` — выбор backend-режима и общие опции модуля
- `options.nix` — опции Vim (`number`, `tabstop`, `clipboard`, тема)
- `keymaps.nix` — клавиши
- `plugins.nix` — плагины и их Lua-настройка
- `lsp.nix` — LSP-серверы и языковые пакеты
- `lua/` — большие Lua-конфиги (например для `snacks` и `render-markdown`)

Все эти файлы подключаются из:

- `packages/nix-darwin/home/default.nix` (`./modules/neovim`)

---

## 2) Какой режим тебе нужен

Для поведения «в точности как раньше» используй:

- `dotfiles.neovim.backend = "compat";`

Для полностью никсового переписанного варианта:

- `dotfiles.neovim.backend = "nixvim";`

Смена backend делается в [packages/nix-darwin/home/default.nix](packages/nix-darwin/home/default.nix).

---

## 3) Главная идея (очень важно)

В режиме `compat` ты продолжаешь править привычные файлы в `home/nvim`,
а Home Manager декларативно линкует их в `~/.config/nvim`.

Ты меняешь `.nix`-файлы в репозитории и затем применяешь конфиг через `darwin-rebuild`.

Пайплайн всегда один:

1. Изменил `.nix`
2. Применил `darwin-rebuild switch --flake ...`
3. Открыл новый shell (`exec zsh`)
4. Запустил `nvim`

---

## 4) Как запускать Neovim правильно

Обычный запуск:

- `nvim`

Если нужно проверить, что запускается именно Nix-версия:

- `which nvim`
- должно указывать на `/etc/profiles/per-user/$USER/bin/nvim`

Гарантированный запуск Nix-версии напрямую:

- `/etc/profiles/per-user/$USER/bin/nvim`

---

## 5) Ежедневный workflow

После любых изменений в `packages/nix-darwin/**`:

- `sudo darwin-rebuild switch --flake /Users/kamradsmeshnyavy/dotfiles/packages/nix-darwin#MacBook-Pro-Denis`

После применения:

- `exec zsh`
- `nvim`

---

## 6) Как добавить плагин

### Если backend = `compat` (рекомендуется для 1:1)

Добавляй плагин **как раньше** — в Lua-файлы внутри `home/nvim/lua/plugins/*.lua`.

### Если backend = `nixvim` (добавление плагина)

Плагины добавляются в `plugins.nix` в двух местах:

1. Сам пакет плагина — в `programs.nixvim.extraPlugins`
2. Настройка плагина — в `programs.nixvim.extraConfigLua` (через `require("...").setup(...)`)

### Шаги

1. Найди имя плагина в `pkgs.vimPlugins`.
2. Добавь его в список `extraPlugins`.
3. Добавь конфиг в `extraConfigLua` (если нужен).
4. Примени `darwin-rebuild switch --flake ...`.
5. Проверь в `nvim` командой `:checkhealth`.

### Пример (схема)

- В `extraPlugins` добавляешь `some-plugin`
- Ниже в Lua:
  - `pcall(function() require("some-plugin").setup({...}) end)`

`pcall` лучше оставлять: если плагин не загрузился, Neovim не падает полностью.

---

## 7) Как добавить/изменить keymap

### Если backend = `compat`

Меняй keymap в `home/nvim/lua/config/keymaps.lua`.

### Если backend = `nixvim` (keymaps)

Файл: `keymaps.nix`

Каждый keymap — это объект в `programs.nixvim.keymaps`:

- `mode` — режим (`"n"`, `"v"`, `"i"`, или список)
- `key` — клавиша
- `action` — команда или mapping
- `options` — `noremap`, `silent`, и т.д.

Если нужен более сложный keymap с Lua-функцией — добавляй в `programs.nixvim.extraConfigLua` через `vim.keymap.set(...)`.

---

## 8) Как менять базовые опции Neovim

Файл: `options.nix`

Там секция:

- `programs.nixvim.opts = { ... }`

Примеры опций:

- `number = true;`
- `relativenumber = true;`
- `tabstop = 2;`
- `shiftwidth = 2;`
- `expandtab = true;`

Цветовая схема у тебя тоже там:

- `colorschemes.catppuccin.enable = true;`

---

## 9) Как добавить LSP для нового языка

Файл: `lsp.nix`

Нужно сделать 2 вещи:

1. Включить сервер в `plugins.lsp.servers`
2. Добавить бинарь в `extraPackages` (если нужен отдельно)

Почему так: `nixvim` настраивает интеграцию LSP, а `extraPackages` гарантирует, что нужный language server есть в окружении.

---

## 10) Где хранить большой Lua-конфиг

Если Lua-блок стал длинным, выноси его в `lua/*.lua` рядом с модулем:

- `packages/nix-darwin/home/modules/neovim/lua/snacks.lua`
- `packages/nix-darwin/home/modules/neovim/lua/render-markdown.lua`

И подключай через `builtins.readFile` в `plugins.nix`.

Это делает `.nix`-файлы чище.

---

## 11) Что делать, если снова «голый nvim»

Проверь по порядку:

1. Применён ли конфиг?
   - снова запусти `sudo darwin-rebuild switch --flake ...`
2. Точно ли нужный бинарник?
   - `which nvim`
3. Новый shell открыт?
   - `exec zsh`
4. Не переопределён ли `nvim` в shell-алиасах/`PATH`?
5. Запусти напрямую:
   - `/etc/profiles/per-user/$USER/bin/nvim`

Если напрямую работает, а просто `nvim` нет — проблема в shell (`PATH`/alias), не в Nix.

---

## 12) Безопасные изменения (рекомендуется)

Перед большими правками:

- сделай `git add -A && git commit -m "before nvim changes"`

Если что-то сломалось:

- `darwin-rebuild --list-generations`
- `sudo darwin-rebuild switch --rollback`

---

## 13) Мини-чеклист при добавлении фичи

1. Понять: это опция / keymap / plugin / LSP?
2. Изменить нужный файл (`options.nix`, `keymaps.nix`, `plugins.nix`, `lsp.nix`)
3. Применить `darwin-rebuild switch --flake ...`
4. Открыть новый shell
5. Проверить в `nvim`
6. Закоммитить изменения

---

## 14) Полезное правило

Если сомневаешься, куда писать настройку:

- UI/поведение Vim → `options.nix`
- Клавиши → `keymaps.nix`
- Плагины → `plugins.nix`
- Языки/LSP → `lsp.nix`
- Сложная Lua-логика → `lua/*.lua`

---

Если хочешь, могу следующим шагом сделать «шаблоны» в репозитории:

- готовый шаблон добавления нового плагина
- шаблон добавления нового LSP
- шаблон добавления группы keymaps

Чтобы ты просто копировал блок и менял 2–3 строки.
