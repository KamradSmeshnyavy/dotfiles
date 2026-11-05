[English](Make-Your-Own) · **Русский**

# Своё

Всё — данные или небольшой QML-файл, форкать плагин не нужно.

## Скин бара

Customizer → Бар → Bar Tweaks, пока не понравится → Bar Skin → «💾 Сохранить текущий скин…» → он ляжет в
`~/.config/omarchy/bar-skins/<имя>.json` со ★. Или написать JSON вручную (схема: [docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-bar.ru.md)).

## Дизайн блокировки

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

Проверить без блокировки: `omarchy-shell lock previewDesign my:Mine.qml`.

## Скин лаунчера

QML-файл, наследующий `SkinBase.qml` и зарегистрированный в `SkinConfig.qml`; `ThemePalette.qml` даёт ему всю тему. См.
[Writing a skin](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins#writing-a-skin).

## Стиль

Customizer → Пресеты → Стиль → «Сохранить текущий вид как стиль» → `~/.config/omarchy/customizer/styles/<id>.json`.
Стиль — пресет без темы / обоев плюс `fonts` (профиль шрифтов) и блок `look` для панелей.

## Пресет

Customizer → Пресеты → сохранить → `~/.config/omarchy/customizer/presets/<имя>.json` (тема + стиль + обои + остальное).
Пресет может ссылаться на стиль: `"style": "<id>"`.

## Анимации и шейдеры

- `~/.config/omarchy/customizer/animations/*.lua` — Lua Hyprland (`hl.curve`, `hl.animation`); файл с именем встроенного
  пресета заменяет его.
- `~/.config/omarchy/customizer/shaders/*.frag` — шейдеры экрана; шейдеру с `time` автоматически ставится
  `damage_tracking = 0`.

## Тема

См. [Темы и приложения](Themes-and-App-Theming-ru#своя-тема).
