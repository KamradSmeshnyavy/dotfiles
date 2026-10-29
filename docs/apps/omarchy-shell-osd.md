# OSD и уведомления omarchy-shell: у края экрана

Клон стокового `omarchy.osd` (`omarchy plugin clone omarchy.osd`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.osd`. Правки в `Osd.qml` помечены `// edge:`; сравнить со стоком —
`diff -u $OMARCHY_PATH/shell/plugins/osd/Osd.qml apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/Osd.qml`.

OSD со шкалой (громкость, яркость, микрофон — всё, что вызывает `omarchy osd -p …`) в стиле `edge` —
вертикальный слайдер, выезжающий из края экрана (`EdgeOsd.qml`, идея caelestia, написано с нуля). Окно
встаёт внутри зарезервированных зон, поэтому со скином бара `frame` растёт прямо из рамки, а вогнутые углы
сверху и снизу переходят в неё. Цвет — как у бара и рамки; у прозрачного бара — цвет попапов темы.
Сообщения без шкалы и медиа-OSD остаются стоковой карточкой. Клики OSD не перехватывает.

Настройки: Customizer → Окна → **OSD и уведомления** или `~/.config/omarchy/osd.json`:

| Ключ | По умолчанию | |
|---|---|---|
| `osdStyle` | `edge` | `edge` или `stock` (стоковая карточка снизу) |
| `osdSide` | `right` | `right` или `left` |

Вернуть стоковый OSD целиком: `omarchy plugin enable omarchy.osd`.

## Уведомления

Клон `omarchy.notifications` (`apps/omarchy-shell/plugins/kamradsmeshnyavy.notifications/`, правки помечены
`// drawer:` в `Service.qml` и `components/NotificationCard.qml`). В стиле `drawer` тосты лежат в одной
подложке цвета бара в правом верхнем углу: окно встаёт внутри бара и рамки (`ExclusionMode.Normal`),
вогнутый угол слева сверху уходит в бар, справа снизу — в правый край / рамку, высота плавно следует за
числом карточек, карточки внутри без рамки. Демон, DND, история и IPC — стоковые.

| Ключ (`~/.config/omarchy/notify-style.json`) | По умолчанию | |
|---|---|---|
| `notifyStyle` | `drawer` | `drawer` или `stock` |

Вернуть стоковые уведомления целиком: `omarchy plugin enable omarchy.notifications`.
При включённом «Не беспокоить» на экран проходят только критические `notify-send` без `-a` и `omarchy-action`.
