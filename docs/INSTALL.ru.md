# Установка

[🇬🇧 English](INSTALL.md)

Два пути: взять только **плагины Omarchy** (без dotfiles) или поставить **всю систему**.

## Только плагины

Каждый плагин — отдельный репозиторий и ставится на чистый Omarchy 4:

```bash
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
omarchy restart shell
```

Список — в [README](../README.ru.md#-плагины-omarchy); в README каждого плагина — настройки и как его удалить. Всё
сразу — `install.sh --all` из Customizer.

## Вся система

### Клонировать репозиторий

```bash
git clone --recursive git@github.com:KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Забыли `--recursive` — `git submodule update --init --recursive` (Dotbot, шейдеры и курсоры Ghostty и плагины —
сабмодули).

### Bootstrap

```bash
./install/bootstrap.sh
```

Предлагает три варианта:

1. **Поставить пакеты** для своей ОС:
   - **macOS** — Homebrew (`install/packages/brew.txt`, `brew-cask.txt`);
   - **Arch / Omarchy** — `pacman` и `yay` (`install/packages/pacman.txt`, `yay.txt`).
2. **Применить dotfiles** — Dotbot (`install/install.py` / `install.conf.yaml`) раскладывает симлинки конфигов
   (в основном в `~/.config/`).
3. **Оба шага** подряд.

> [!WARNING]
> Перед применением dotfiles убедитесь, что нет конфликтующих конфигов, или разрешите Dotbot их перезаписать.

### Только ссылки, хуки и фильтры

Если пакеты уже стоят:

```bash
just link            # Dotbot + git hooks (gitleaks) + git-фильтры + AI-скиллы + шрифты терминалов по профилю
just check-links     # ручные симлинки, которых нет в install/install.conf.yaml
just app-themes      # направить слоты тем приложений на текущую тему
```

Предпросмотр: `python3 install/install.py --dry-run`; флаги идут в Dotbot как есть (`--only link`, …). `just` без
аргументов — список всех рецептов.

### После установки

- `bat cache --build` выполняется сам.
- Шрифты: `omarchy-font-profile list` / `omarchy-font-profile <профиль>`; шрифты DotMatrix — `just dotmatrix-fonts`.
- Тема: `just theme <имя>` (без имени — список).

## Другие способы

### macOS (nix-darwin)

```bash
just switch   # применить новую конфигурацию
just build    # собрать без применения
just update   # обновить flake.lock и применить
```

### GNU Stow

```bash
./install/setup.sh
```

Опирается на `.stowrc` для ссылок на базовые каталоги.

## Конфиги

У каждого конфига своя страница: [apps](./apps/), [cli](./cli/), [shells](./shells/), [tui](./tui/) — индекс в
[docs/README.ru.md](README.ru.md). Гайды — в [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki).
