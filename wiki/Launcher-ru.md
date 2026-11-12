[English](Launcher) · **Русский**

# Лаунчер

Полноэкранные скины для меню и лаунчера Omarchy. Все меню, поиск и действия работают как раньше — скин решает только,
как рисуется список, и перекрашивается из темы при каждом открытии. Репозиторий:
[omarchy-launcher-skins](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-launcher-skins --enable
omarchy restart shell
echo '{"skin": "constellation"}' > ~/.config/omarchy/extensions/menu-skin.json
```

| Скин | |
|---|---|
| `constellation` | приложения — звёзды на карте неба |
| `terminal` | CRT-приглашение оболочки в цветах темы |
| `tarot` | веер карт (`tarot-hack` раздаёт их из `xxd`) |
| `orrery` | приложения на орбитах вокруг солнца |
| `aquarium` | приложения — рыбы |
| `lanterns` | фонарики под луной |
| `metro` | схема метро |
| `drum` | вращающийся барабан |
| `bookshelf` | приложения — книги на полках |
| `matrix` | падающий код |
| `list` | стоковая карточка |

Выбор — Customizer → Пикеры → Лаунчер. Файл отслеживается — скин меняется даже при открытом меню. Открывать как обычно:
Super+Space (меню), Super+Alt+Space (приложения).

Клавиши: ↑↓ / Ctrl+J/K по списку или кольцу, ←→ / PgUp/PgDn — страницы, Alt+1…9 — быстрый запуск, Enter / Backspace /
Esc.

**Команды:** `>` включает режим команд — `>theme`, `>wall`, `>skin`, `>dash`, `>dnd`, `>shader`, `>custom`, `>lock`,
`>power`; быстрые режимы: `=` калькулятор и единицы, `:` эмодзи / каомодзи / символы, `@` окна, `!` веб-поиск с
bang, `;` история буфера обмена ([справочник](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-launcher-commands.ru.md)).

Вернуть стоковое меню: `omarchy plugin enable omarchy.menu`.
