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

Вид — `BarStyle.qml`, как у дашборда: `osdFollowBar` (`true`), `osdAttach` (`auto` / `attached` /
`floating`), свои `osdBackground` / `osdAlpha` / `osdRadius`. Ещё: `osdAlign` (`center` / `top` / `bottom`
вдоль края), `osdSize` (`compact` / `normal` / `large`), `osdShowValue`, `osdTimeout` (мс, `-1` — как в стоке).

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
| `notifyFollowBar`, `notifyAttach` | `true`, `auto` | как у дашборда: прилипать к сплошному бару, иначе плавающая карточка |
| `notifyCorner` | `top-right` | `top-right` / `top-left` / `top-center` (по центру — затёки с обеих сторон) |
| `notifyWidth`, `notifyMax` | `380`, `0` | ширина тоста; сколько видно сразу (`0` — все, новые сверху) |
| `notifyCards` | `flat` | `flat` — без рамки внутри подложки, `bordered` — стоковые |
| `notifyBackground`, `notifyAlpha`, `notifyRadius` | | свой вид, когда не следуем бару |

## Звуки

`omarchy-sound <событие>` (`omarchy-themes/scripts/omarchy-sound` → `~/.local/bin`) играет звук через
`pw-play`. Имена событий — из freedesktop sound theme spec; файл ищется в `apps/sounds/` текущей темы,
потом в `omarchy-themes/app-defaults/sounds/`, потом в `/usr/share/sounds/freedesktop/stereo`.
Тема со своими звуками кладёт, например, `apps/sounds/message-new-instant.oga`.

| Событие | Откуда |
|---|---|
| `message-new-instant` / `dialog-warning` | показ тоста / критического тоста (клон уведомлений; при DND молчит) |
| `audio-volume-change` | OSD громкости (не чаще раза в 80 мс) |
| `service-login` | хук `post-boot.d/sound-login` |
| `battery-low` (→ `dialog-warning`) | хук `battery-low.d/sound-battery-low` |

Customizer → Окна → **OSD и уведомления**: «Звуки: включены» и «Звуки: громкость»
(`~/.config/omarchy/sounds.json`: `sounds`, `soundVolume`).

Вернуть стоковые уведомления целиком: `omarchy plugin enable omarchy.notifications`.
При включённом «Не беспокоить» на экран проходят только критические `notify-send` без `-a` и `omarchy-action`.
