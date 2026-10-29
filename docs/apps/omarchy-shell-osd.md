# OSD omarchy-shell: громкость и яркость у края экрана

Клон стокового `omarchy.osd` (`omarchy plugin clone omarchy.osd`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.osd`. Правки в `Osd.qml` помечены `// edge:`; сравнить со стоком —
`diff -u $OMARCHY_PATH/shell/plugins/osd/Osd.qml apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/Osd.qml`.

OSD со шкалой (громкость, яркость, микрофон — всё, что вызывает `omarchy osd -p …`) в стиле `edge` —
вертикальный слайдер, выезжающий из края экрана (`EdgeOsd.qml`, идея caelestia, написано с нуля). Окно
встаёт внутри зарезервированных зон, поэтому со скином бара `frame` растёт прямо из рамки, а вогнутые углы
сверху и снизу переходят в неё. Цвет — как у бара и рамки; у прозрачного бара — цвет попапов темы.
Сообщения без шкалы и медиа-OSD остаются стоковой карточкой. Клики OSD не перехватывает.

Настройки: Customizer → Окна → **OSD** или `~/.config/omarchy/osd.json`:

| Ключ | По умолчанию | |
|---|---|---|
| `osdStyle` | `edge` | `edge` или `stock` (стоковая карточка снизу) |
| `osdSide` | `right` | `right` или `left` |

Вернуть стоковый OSD целиком: `omarchy plugin enable omarchy.osd`.
