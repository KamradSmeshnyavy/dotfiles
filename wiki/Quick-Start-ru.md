[English](Quick-Start) · **Русский**

# Быстрый старт

## Путь A — только плагины (лучше всего, чтобы попробовать)

На чистом Omarchy 4 (Quattro):

```sh
# центр управления
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
omarchy restart shell
```

Бинд в `~/.config/hypr/bindings.lua`, затем перезагрузить Hyprland:

```lua
o.bind("SUPER + SHIFT + T", "Omarchy Customizer", "omarchy-shell shell toggle kamradsmeshnyavy.customizer")
```

Добавьте что нравится — Customizer сам найдёт каждый плагин и получит для него новую группу:

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-bar-skins --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-lock-designs --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-launcher-skins --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-edge-osd --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications --enable
omarchy restart shell
```

Или всё сразу установщиком Customizer (сначала прочитайте его):

```sh
curl -fsSLo /tmp/customizer-install.sh https://raw.githubusercontent.com/KamradSmeshnyavy/omarchy-customizer/main/install.sh
less /tmp/customizer-install.sh
bash /tmp/customizer-install.sh --all
```

**Попробовать вид DOT-MATRIX:** Super+Shift+T → Пресеты → DOT-MATRIX → ⏎. Передумали — Пресеты → «Восстановить
прежнюю настройку».

**Откат:** каждый плагин заменяет стоковый — `omarchy plugin enable omarchy.bar` (lock, menu, osd, …) возвращает
стоковый; `omarchy plugin remove <id>` удаляет мой.

Обновления: `omarchy plugin update` (fast-forward pull, показывает diff).

## Путь B — вся система

```sh
git clone --recursive https://github.com/KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install/bootstrap.sh      # пакеты, симлинки или всё
```

Пакеты уже стоят — `just link` (симлинки Dotbot, git hooks, git-фильтры, AI-скиллы, шрифты терминалов). Потом
`just app-themes` и выбрать тему: `just theme` покажет список.

> [!WARNING]
> Путь B кладёт мои конфиги поверх ваших (Hyprland, терминалы, оболочки, редакторы). Сначала
> `python3 install/install.py --dry-run`.

Дальше: [Customizer](Customizer-ru).
