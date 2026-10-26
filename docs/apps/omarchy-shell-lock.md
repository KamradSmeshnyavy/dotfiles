# Экран блокировки omarchy-shell: дизайны

Свой аналог [omarchy-lock-explorer](https://github.com/SirJul1337/omarchy-lock-explorer), написанный
заново: чужой код не используется. Клон стокового `omarchy.lock` (`omarchy plugin clone omarchy.lock`):
`apps/omarchy-shell/plugins/kamradsmeshnyavy.lock/` → `~/.config/omarchy/plugins/kamradsmeshnyavy.lock`.

Выбор — в Customizer (Super+Shift+T): категории **Lock** и **Lock Tweaks**.

## Безопасность

- Пароль, PAM и отпечаток — стоковый `Service.qml` без изменений логики. Правки помечены `// design:`:
  `LockView` заменён на `LockHost` в двух местах, добавлены IPC `previewDesign` и закрытие превью по Esc.
- Дизайн видит только то же, что стоковый `LockView`: состояние и введённый текст, который он отдаёт
  сигналом `submitPassword`.
- `LockHost` показывает стоковый `LockView`, если дизайн не загрузился, не найден или за 0,5 с не
  назначил поле пароля (`field`). Экран без ввода пароля не остаётся.
- Клон наследует капабилити `authentication` от `omarchy.lock`: шелл держит его так же изолированно.
- Аварийный выход, если экран заблокирован и что-то сломалось: TTY (Ctrl+Alt+F3) →
  `omarchy plugin enable omarchy.lock` или `loginctl unlock-session`.

## Файлы

| Файл | Что это |
|---|---|
| `~/.config/omarchy/lock-design.json` | выбранный дизайн и настройки (следит `LockHost`, применяется сразу) |
| `kamradsmeshnyavy.lock/LockHost.qml` | загрузчик дизайна с фолбэком |
| `kamradsmeshnyavy.lock/designs/designs.json` | реестр: `id`, `file`, `name`, `description`, `tags` |
| `kamradsmeshnyavy.lock/designs/*.qml` | дизайны и общие части: `DesignBase`, `PasswordField`, `Wallpaper`, `Avatar` |
| `~/.config/omarchy/lock-designs/*.qml` | свои дизайны (id `my:<Файл>.qml`) |
| `~/.cache/omarchy-customizer/lock/*.jpg` | превью для Customizer (`T` — переснять в цветах текущей темы) |

## Дизайны

classic (сток), zen, dock, island, split, sheet, card, cinema, poster, editorial, analog, flip, ring,
calendar, terminal, neon, system, music, aurora, rain, constellation.

## Настройки (`lock-design.json`, Lock Tweaks)

| Ключ | Умолч. | |
|---|---|---|
| `design` | `classic` | id дизайна |
| `clock24` | `true` | 24-часовой формат |
| `showSeconds` | `false` | секунды |
| `showDate` | `true` | дата |
| `wallpaperBlur` | `1` | размытие обоев 0–1 |
| `wallpaperDim` | `0` | затемнение обоев 0–0.9 |
| `reduceMotion` | `false` | без анимаций (aurora, rain, секундная стрелка) |
| `ownerMessage` | `Привет, $USER` | приветствие |
| `avatar` | `~/.face` | картинка аватара; нет — первая буква имени |

## Свой дизайн

`~/.config/omarchy/lock-designs/Mine.qml`:

```qml
import QtQuick
import "../plugins/kamradsmeshnyavy.lock/designs"

DesignBase {
  id: root
  field: pw                       // обязательно: иначе покажется стоковый экран
  Wallpaper { anchors.fill: parent; host: root }
  Text { text: root.time; color: root.fg; font.family: root.font; font.pixelSize: 80 }
  PasswordField { id: pw; host: root; anchors.centerIn: parent }
}
```

В `DesignBase` есть `time`, `hours`, `minutes`, `dateText`, `now`, `greeting`, `userName`, цвета
`bg fg accent muted`, `font`, `withAlpha()`, `opt(key, def)` и флаг `preview`. Проверка без блокировки:
`omarchy-shell lock previewDesign my:Mine.qml` (Esc или клик — закрыть).

## Обновление апстрима

`diff -u $OMARCHY_PATH/shell/plugins/lock/Service.qml apps/omarchy-shell/plugins/kamradsmeshnyavy.lock/Service.qml` —
перенести блоки `// design:` на новую версию. После правок QML — `omarchy restart shell`.
