# 1. Перекрасить дерево. Выходную папку указывать ОБЯЗАТЕЛЬНО (см. ниже)
~/dotfiles/omarchy-themes/scripts/omarchy-lutgen-wallpapers-tree \
  -t pastel-hacker24 \
  ~/Wallpapers-lutgen/Walls-dharmx \
  ~/Wallpapers-lutgen/walls-dharmx-pastel-hacker24

# 2. Подключить результат к теме
mkdir -p ~/.config/omarchy/backgrounds/pastel-hacker24
ln -s ~/Wallpapers-lutgen/walls-dharmx-pastel-hacker24 \
      ~/.config/omarchy/backgrounds/pastel-hacker24/walls-dharmx

# 3. (по желанию) заранее сделать превью, чтобы меню не тормозило
#    (запускать, когда активна pastel-hacker24, или указать --root явно)
omarchy-bg-browser --root ~/.config/omarchy/backgrounds/pastel-hacker24 --cache
