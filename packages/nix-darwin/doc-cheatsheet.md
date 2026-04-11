# Nix словарь + готовые рецепты (1 страница)

Короткий справочник под твой проект `nix-darwin`.

Если нужна версия «только команды»: [doc-10-commands.md](doc-10-commands.md).

---

## 1) Мини-словарь терминов

- **Nix** — пакетный менеджер и язык конфигурации.
- **Lix** — совместимая реализация Nix (у тебя сейчас используется она).
- **nixpkgs** — основной каталог пакетов Nix.
- **flake.nix** — точка входа конфигурации (входы/выходы).
- **flake.lock** — зафиксированные версии входов (воспроизводимость).
- **nix-darwin** — управление macOS декларативно.
- **home-manager** — управление файлами пользователя (`~/.config`, `.zshrc` и т.д.).
- **generation (поколение)** — сохранённая версия конфигурации, на которую можно откатиться.
- **switch** — собрать и применить текущую конфигурацию.
- **rollback** — откатиться к предыдущему поколению.
- **cask** — GUI-приложение в Homebrew.
- **brew formula** — CLI/утилита в Homebrew.

---

## 2) Где в твоём репо что менять

- Система macOS + brew + системные пакеты:
  - `nix-darwin/hosts/darwin/default.nix`
- Пользовательские пакеты:
  - `nix-darwin/home/default.nix`
- Линки dotfiles:
  - `nix-darwin/home/dotfiles-links.nix`
- Точка входа flake:
  - `nix-darwin/flake.nix`

---

## 3) Готовые рецепты

### Рецепт 0: сменить тему Catppuccin декларативно

Файл: `home/default.nix`

```nix
dotfiles.theme = {
  enable = true;
  flavor = "mocha"; # latte | frappe | macchiato | mocha
  accent = "pink";  # rosewater | flamingo | pink | ...
};
```

Дальше обычный `switch`.

### Рецепт A: добавить пакет Nix в систему

Файл: `hosts/darwin/default.nix`

Найди:

`environment.systemPackages = with pkgs; [ ... ];`

Добавь пакет, например `htop`:

`environment.systemPackages = with pkgs; [ ... htop ];`

Применить:

1. `nix flake check`
2. `sudo -H /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`

---

### Рецепт B: добавить пакет Nix только для пользователя

Файл: `home/default.nix`

Найди:

`home.packages = with pkgs; [ ... ];`

Добавь, например `fd`:

`home.packages = with pkgs; [ ... fd ];`

Дальше обычный `switch`.

---

### Рецепт C: добавить Homebrew CLI (formula)

Файл: `hosts/darwin/default.nix`

Найди:

`homebrew.brews = [ ... ];`

Добавь, например `gh`:

`homebrew.brews = [ ... "gh" ];`

Дальше обычный `switch`.

---

### Рецепт D: добавить Homebrew GUI (cask)

Файл: `hosts/darwin/default.nix`

Найди:

`homebrew.casks = [ ... ];`

Добавь, например `raycast`:

`homebrew.casks = [ ... "raycast" ];`

Дальше обычный `switch`.

---

### Рецепт E: добавить новый dotfile-линк

Файл: `home/dotfiles-links.nix`

Шаблон:

`".config/<app>".source = link "${dotfilesRoot}/<app>";`

Пример для `btop`:

`".config/btop".source = link "${dotfilesRoot}/btop";`

Если это файл:

`".config/starship.toml".source = link "${dotfilesRoot}/starship.toml";`

Если конфликт с существующим файлом:

```nix
"Library/Application Support/Code/User/settings.json" = {
  source = link "${dotfilesRoot}/vscode/settings.json";
  force = true;
};
```

---

### Рецепт F: обновить входы (nixpkgs/home-manager/nix-darwin)

1. `nix flake update`
2. `nix flake check`
3. `switch`

Если что-то сломалось — rollback.

---

### Рецепт G: откатиться

- Посмотреть поколения:
  - `darwin-rebuild --list-generations`
- Откат:
  - `darwin-rebuild switch --rollback`

---

## 4) Быстрое правило выбора: Nix или Brew?

- **Nix**: CLI/dev-tools, то что важно фиксировать и воспроизводить.
- **Brew cask**: GUI-приложения macOS.
- **Brew formula**: если в nixpkgs пакет ломается или нужен срочно.

---

## 5) Мини-чеклист после каждого изменения

1. `nix flake check`
2. `switch`
3. Проверка `command -v <tool>`
4. Коммит в git
