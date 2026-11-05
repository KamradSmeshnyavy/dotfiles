[English](FAQ) · **Русский**

# FAQ и проблемы

**Поправил QML плагина — ничего не изменилось.** Клонированные и сторонние плагины не перезагружаются на лету:
`omarchy restart shell`.

**Плагин не появился после `git clone` в `~/.config/omarchy/plugins`.** `omarchy-shell shell rescanPlugins`, затем
`omarchy plugin enable <id>`. `omarchy plugin add <url>` делает всё это сам.

**Как вернуть сток?** `omarchy plugin enable omarchy.<bar|lock|menu|osd|notifications|background|image-picker>`;
`omarchy plugin remove kamradsmeshnyavy.<имя>` удаляет мой. Пресеты → «Восстановить прежнюю настройку» отменяет стиль
или пресет.

**`hyprctl keyword …` / `hyprctl dispatch …` не работает.** Конфиг Hyprland на Lua: `hyprctl eval 'hl.…'`.

**После обновления Omarchy клавиша делает два действия.** Omarchy 4.5 занял часть клавиш (Super+Shift+T, Super+M,
`` Super+` ``…). Биндить через `o.rebind`, а не `o.bind`.

**Пикер тем / обоев тормозит.** Customizer → Пикеры → закэшировать миниатюры и очистить неиспользуемые
([Обои и пикеры](Wallpapers-and-Pickers-ru)).

**Заперся после экспериментов с дизайном блокировки.** Ctrl+Alt+F3 → войти → `omarchy plugin enable omarchy.lock` или
`loginctl unlock-session`. Дизайн без поля пароля в любом случае не заменяет стоковый экран.

**DOT-MATRIX выглядит обычным текстом.** Нужны шрифты: `install.sh` Customizer их подключает, `omarchy-font-profile`
собирает DotMatrix; проверить — `fc-list | grep -i dot`.

**Смена шрифтов оставляет изменения в git моих dotfiles.** Больше нет: шрифты терминалов — в игнорируемом `fonts.conf`,
ключи VS Code идут через clean-фильтр (его настраивает `just link`).

**Где лежат настройки?** В основном `~/.config/omarchy/*.json` (`bar-skin.json`, `lock-design.json`, `widgets.json`,
`osd.json`, `notify-style.json`, `customizer.json`, `style.json`, `fonts.json`) и `~/.config/omarchy/customizer/`.

Что-то ещё? [Issue](https://github.com/KamradSmeshnyavy/dotfiles/issues) в dotfiles или в репо плагина.
