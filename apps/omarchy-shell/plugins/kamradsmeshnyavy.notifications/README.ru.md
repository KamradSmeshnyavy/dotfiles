# Omarchy Drawer Notifications

[🇬🇧 English](README.md)

Уведомления [Omarchy](https://omarchy.org) (клон стокового `omarchy.notifications`), где тосты лежат в одной
панели. Со сплошным баром у края — например, скином `frame` из
[omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) — панель прилипает к бару и краю
экрана вогнутыми углами; с прозрачным или плавающим баром — плавающая карточка с отступом и тенью. Высота
следует за числом тостов. Демон, «Не беспокоить», история и IPC — стоковые.

## Установка

```sh
git clone https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications ~/.config/omarchy/plugins/kamradsmeshnyavy.notifications
omarchy-shell shell rescanPlugins
omarchy plugin enable kamradsmeshnyavy.notifications   # обратно к стоку: omarchy plugin enable omarchy.notifications
```

## Настройки

`~/.config/omarchy/notify-style.json`, применяются на лету; [Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) —
Окна → Уведомления. Ключи — в [README.md](README.md#settings): стиль, угол (справа / слева / по центру), ширина,
сколько тостов видно сразу, вид карточек, «следовать стилю бара», режим прилипания, свой фон / альфа / скругление.

Правки стоковых файлов помечены `// drawer:`.

## Лицензия

MIT (вместе со стоковым плагином Omarchy, из которого сделан клон).
