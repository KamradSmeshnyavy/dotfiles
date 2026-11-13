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
(`omarchy-font-profile vitreus-<тема>`).
