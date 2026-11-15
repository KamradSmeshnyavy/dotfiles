# Темы vitreus-*

[🇬🇧 English](README.md)

Семь тем Omarchy из тем [Vitreus](https://github.com/natepayn3/Vitreus) (MIT, © natepayn3): `vitreus-retro`, `-uwu`,
`-cyber`, `-milk`, `-doodle`, `-paper`, `-proxy`. Своей палитры у Glass в Vitreus нет — цвета берутся с обоев, здесь это
тема `dynamic`.

У темы Vitreus одиннадцать цветов интерфейса (ink, faint, mint — акцент, mintlo / minthi, onmint, tint — фон, panel, deep,
off, alert); `build.py` раскладывает их по всем приложениям генератором тем `nothing` (`../nothing/build.py`). Синтаксиса
и статусов у Vitreus нет — они подобраны здесь в тон каждой теме и подогнаны по яркости до контраста 4.5 к фону
(комментарии — 3), чтобы код читался. Обои — мягкие «жидкие» пятна цветов темы (у Vitreus их нет): стеклу есть что
размывать.

```sh
python3 build.py            # все темы
python3 build.py retro uwu  # выбранные
```

Пресеты Customizer **Liquid Retro … Proxy** ставят стиль «Жидкое стекло» на эти темы со шрифтом заголовков темы
(`omarchy-font-profile vitreus-<тема>`). Основа темы (`"base"` в `~/.config/omarchy/style.json`) меняет и лаунчер `liquid` (`kamradsmeshnyavy.menu/LiquidView.qml`): у пластиковых основ — сплошная карточка с контуром чернилами и жёсткой тенью и шапка Vitreus (значок из четырёх квадратиков, SEARCH › режим, подсказки двумя рядами ячеек); у Retro ещё красный язычок, прорези-ручки, винт и выбор с красным оттенком; у Cyber — светящиеся уголки-скобки, линейка рисок и мигающий код.

По умолчанию темы **одноцветные**: синтаксис, 16 цветов терминала, статусы и btop — только оттенки mint (акцента) и чернил темы (ink, faint, off), без чужих зелёных и фиолетовых. Сам Vitreus терминал, btop и fastfetch не красит (у него свой терминал во вкладке Desk), поэтому они сделаны здесь в его цветах: fastfetch — «VITREUS // тема», полая стеклянная V полублоками от minthi к mintlo и полоса палитры (`apps/fastfetch.jsonc`, `apps/vitreus-logo.txt`). `python3 build.py --color` собирает прежний разноцветный вариант. Углы окон — по `corner_rounding` каждой темы (Retro, Cyber, Doodle — 3 px, Paper и Proxy — 6, Glass и UwU — 22, Milkbox — 24), через пресеты Liquid-*.
