# Nix/Lix для чайников: полный гайд под твой `dotfiles`

Этот документ — практический гайд для твоего текущего перехода на `nix-darwin + home-manager + brew`.

---

## 1) Что ты уже сделал

Ты уже перешёл на правильную архитектуру:

- `nix-darwin/flake.nix` — точка входа
- `nix-darwin/hosts/darwin/default.nix` — системные настройки macOS
- `nix-darwin/home/default.nix` — пользовательские пакеты
- `nix-darwin/home/dotfiles-links.nix` — линковка dotfiles в `$HOME`

И главное: конфиг уже использует **Lix**.

Короткий вывод: миграция завершена технически, когда `switch` проходит успешно и shell запускается без ошибок.

---

## 2) Что такое Nix простыми словами

Nix — это пакетный менеджер и система конфигурации, где:

1. ты **описываешь** систему в файлах (`.nix`),
2. Nix **собирает** это в отдельные поколения,
3. можно **откатываться** назад, если что-то сломалось.

Ключевая идея: конфигурация декларативная. Не "накликал", а "описал".

---

## 3) Что такое Flakes (ещё проще)

`flake.nix` — это "манифест" проекта:

- какие входы (например `nixpkgs`, `nix-darwin`, `home-manager`)
- какие выходы (например `darwinConfigurations.<hostname>`)

Команда `switch` берёт именно этот выход и применяет его к системе.

---

## 4) Как у тебя теперь распределены роли

### Nixpkgs

Для CLI, dev-инструментов, того что хорошо живёт декларативно.

### Homebrew

Для GUI-приложений и тех пакетов, где тебе удобнее brew.

### Home Manager

Для файлов в домашней директории:

- `~/.config/...`
- `.zshrc`
- VSCode settings/snippets

---

## 5) Основные команды (ежедневные)

Из директории `~/dotfiles/nix-darwin`:

- Проверка синтаксиса и оценки:
  - `nix flake check`
- Обновить входы (`flake.lock`):
  - `nix flake update`
- Применить конфиг:
  - `sudo -H /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`
- Поколения системы:
  - `darwin-rebuild --list-generations`
- Откат:
  - `darwin-rebuild switch --rollback`

### Вариант без предупреждений

Используй команду с очищенным `NIX_PATH` и флагом deprecated-feature:

- `sudo -H env NIX_PATH= /nix/var/nix/profiles/default/bin/nix --extra-deprecated-features or-as-identifier run nix-darwin -- switch --flake /Users/kamradsmeshnyavy/dotfiles/nix-darwin#MacBook-Pro-Denis`

Или скрипт:

- `./switch-no-warnings.sh`

---

## 5.1) Ответы на главные вопросы (очень кратко)

### Что даёт Nix по сравнению с обычными dotfiles?

- Повторяемость: одна и та же конфигурация на любой машине.
- Откаты: можно вернуться к прошлому поколению.
- Явное управление пакетами: понятно, что и откуда установлено.
- Меньше ручной рутины после переустановки системы.

### Как пользоваться Nix каждый день?

1. Изменяешь `.nix` файл.
2. Проверяешь: `nix flake check`.
3. Применяешь: `switch`.
4. Если что-то не так — `rollback`.

### Нужно ли теперь ставить всё только через Nix?

Нет. У тебя гибридная схема, это нормально:

- CLI/dev-инструменты — чаще через Nix (`environment.systemPackages`, `home.packages`).
- GUI/macOS-apps — удобно через Homebrew (`homebrew.casks`).

Итог: можно и нужно использовать и Nix, и Brew вместе.

---

## 6) Что менять и где

- Системные пакеты: `hosts/darwin/default.nix` → `environment.systemPackages`
- Brew пакеты: `hosts/darwin/default.nix` → `homebrew.brews`
- Brew GUI: `hosts/darwin/default.nix` → `homebrew.casks`
- Пакеты пользователя: `home/default.nix` → `home.packages`
- Линки на конфиги: `home/dotfiles-links.nix`

---

## 7) Разбор твоих ошибок

### Ошибка 1: `Build user group has mismatching GID`

Причина: у уже установленного Nix группа `nixbld` имеет GID `350`, а nix-darwin ждал `30000`.

Исправление уже внесено в конфиг:

- `hosts/darwin/default.nix`:
  - `ids.gids.nixbld = 350;`

После этого `switch` должен проходить дальше.

### Ошибка 2: падение на `unity-test` при сборке `cava`

Это проблема в цепочке зависимостей текущего канала nixpkgs/Lix, не в твоём синтаксисе.

Временный фикс уже сделан:

- `cava` убран из `home.packages`.

Позже можно:

1. вернуть `cava` после обновления `nixpkgs`, или
2. поставить `cava` через brew.

### Предупреждения `using or as an identifier is deprecated`

Это предупреждения из nix/lib на стороне инструментов. Они шумные, но не критичные.
На миграцию не влияют.

Если хочешь скрыть их в команде запуска, добавь флаг:

- `--extra-deprecated-features or-as-identifier`

---

## 8) Что осталось сделать для завершения миграции

1. Выполнить `switch` успешно хотя бы один раз.
2. Проверить, что симлинки Home Manager встали:
   - `~/.config/nvim`
   - `~/.config/ghostty`
   - `~/.zshrc`
3. Проверить, что brew-пакеты и casks применились.
4. Опционально: вернуть/заменить `cava`.
5. Закоммитить изменения в репо.

---

## 9) Мини-чеклист после `switch`

- `which nvim` работает
- `which zellij` работает
- открывается `ghostty`
- VSCode использует твои `settings.json`/`keybindings.json`
- `~/.config/*` указывает на файлы из `~/dotfiles`

---

## 10) Типичный рабочий цикл

1. Правишь `.nix` файл.
2. Запускаешь `nix flake check`.
3. Запускаешь `switch`.
4. Тестируешь.
5. Коммитишь.

---

## 11) Частые вопросы

### Нужно ли удалять brew?

Нет. У тебя гибридная схема: Nix + Brew. Это нормальный и практичный вариант на macOS.

### Обязательно ли использовать Lix?

Нет, но можно. У тебя уже включён Lix и это ок.

### Что если после правки всё сломалось?

Используй rollback:

- `darwin-rebuild switch --rollback`

---

## 12) Быстрый recovery-план

Если после `switch` что-то странно:

1. `nix flake check`
2. `sudo ... nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis --show-trace`
3. При необходимости `darwin-rebuild switch --rollback`

---

Если хочешь, следующим шагом можно сделать второй документ: "Nix словарь терминов на 1 страницу" и "готовые рецепты" (добавить пакет, добавить cask, добавить новый dotfile-линк).

Готово: смотри быстрый справочник [doc-cheatsheet.md](doc-cheatsheet.md).

Супер-короткая версия на каждый день: [doc-10-commands.md](doc-10-commands.md).
