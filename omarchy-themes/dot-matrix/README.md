# DOT-MATRIX для Omarchy

Монохромная матричная тема в эстетике Nothing OS, портированная из [poligle/Nihil-Shell](https://github.com/poligle/Nihil-Shell) (MIT, Copyright © 2026 Pol Iglesias).

## Принципы оформления

1. **Иерархия из оттенков серого** на OLED-чёрном (`#000000`). Красный (`#d71921`) никогда не служит украшением — он только прерывает (ошибки, удаления, критические уведомления, запись микрофона).
2. **Точечный шрифт — для витрины**: `Doto` рисует часы и крупные цифры, `Space Grotesk` — текст интерфейса, `Space Mono` — верхний регистр подписей (все три под SIL OFL 1.1, лежат в плагине `kamradsmeshnyavy.customizer/fonts`; без них DOT-MATRIX-скины берут шрифт Omarchy).
3. **Обои как светодиодная матрица**: исходные фотографии DOT-MATRIX и логотип Arch отрендерены скриптом `dotify.py` на нативной сетке пикселей.

## Палитра

| Токен | Hex | Назначение |
|---|---|---|
| `void` | `#000000` | Рамка, бар, выдвижные панели, фон терминала |
| `surface` | `#0e0e0e` | Карточки внутри панелей |
| `raised` | `#1a1a1a` | Наведение, дорожки слайдеров |
| `line` | `#2a2a2a` | Линии в 1 px, неактивные рамки окон |
| `off` | `#333333` | Погашенные светодиоды |
| `muted` | `#7a7a7a` | Метаданные, неактивные иконки, активная рамка окна |
| `dim` | `#a3a3a3` | Вторичный текст |
| `ink` | `#f2f2f2` | Основной акцент и горящие светодиоды |
| `signal` | `#d71921` | Только прерывания и ошибки |

## Стиль DOT-MATRIX на любой теме

Сам dot-matrix стиль (бар, лаунчер, дашборд, панель настроек, OSD, уведомления, локскрин, Glyph) не привязан
к этой теме: цвета берутся из палитры `dotmatrix/Palette.qml` каждого плагина. По умолчанию это цвета текущей
omarchy-темы (`background`, `foreground`, `muted`, `accent` вместо красного сигнала, `urgent` для опасных
действий). Оригинальный чёрно-белый вид Nothing на любой теме — Customizer → Рабочий стол → Виджеты →
**Палитра DOT-MATRIX = mono** (или `{"palette":"mono"}` в `~/.config/omarchy/dotmatrix.json`).

## Активация одним кликом (Пресет в Customizer)

1. Откройте оверлей **Customizer** (`Super+Shift+T`).
2. В первой группе **«Пресеты»** выберите **`DOT-MATRIX`** — применятся тема `dotmatrix`, матричные обои, анимации/прозрачность/блюр/геометрия Hyprland, скин и раскладка бара `dotmatrix`, матричный дашборд, лаунчер, OSD, карточки уведомлений, локсрин, звуковой пакет `dotmatrix` и контурная подсветка **Glyph**.
3. Что именно применять из пресетов — переключатели **«Что применять из пресетов»** внизу той же группы:
   например, выключите «Применять тему» и «Применять обои», чтобы получить DOT-MATRIX-стиль поверх своей темы.
4. Вернуться к прежней конфигурации — пункт **«Восстановить прежнюю настройку»**; геометрию окон из пресета
   сбрасывает **«Сбросить геометрию окон»**.

## Генератор матричных обоев (Dotify)

Любое изображение можно превратить в LED-матрицу через группу **«Матрица (Dotify)»** в Customizer или напрямую из CLI:

```sh
python3 ~/dotfiles/apps/omarchy-shell/plugins/kamradsmeshnyavy.customizer/scripts/dotify.py \
  input.jpg ~/.config/omarchy/backgrounds/dotmatrix/custom.png --width 2880 --height 1800
```

## Загрузочный экран Plymouth (опционально, требует `sudo`)

В соседнем каталоге `omarchy-themes/dot-matrix-boot/plymouth/` (вне темы, чтобы не копироваться при каждой смене темы) находится матричная загрузочная анимация Arch Linux (36 кадров зажигания светодиодов от центра + 60 кадров пробега диагонального луча Glyph):

```sh
sudo cp -r ~/dotfiles/omarchy-themes/dot-matrix-boot/plymouth /usr/share/plymouth/themes/dot-matrix
sudo plymouth-set-default-theme -R dotmatrix
```

Вернуть стоковый экран загрузки Omarchy:

```sh
sudo plymouth-set-default-theme -R omarchy
```

## Экран входа SDDM (опционально, требует `sudo`)

В `omarchy-themes/dot-matrix-boot/sddm/` находится Qt6-тема SDDM в эстетике DOT-MATRIX (`cp -rL` разворачивает относительные ссылки на шрифты `fonts/` и обои `background.png`):

```sh
sudo cp -rL ~/dotfiles/omarchy-themes/dot-matrix-boot/sddm /usr/share/sddm/themes/dot-matrix
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=dotmatrix\n' | sudo tee /etc/sddm.conf.d/theme.conf
```

Предпросмотр без перезагрузки:

```sh
sddm-greeter-qt6 --test-mode --theme ~/dotfiles/omarchy-themes/dot-matrix-boot/sddm
```
