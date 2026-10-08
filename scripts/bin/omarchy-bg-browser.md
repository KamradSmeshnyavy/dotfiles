# doc
# 1. Меню.
Пункт «Background» в меню omarchy-shell (apps/omarchy-shell/extensions/omarchy-menu.jsonc:61) вызывает не стандартный omarchy-theme-bg-switcher, а scripts/bin/omarchy-bg-browser. Стандартный переключатель ищет картинки только на один уровень вглубь (maxdepth 1), поэтому подпапки ему не видны.
# 2. Браузер omarchy-bg-browser.
Он не зависит от темы. Корень он берёт как ~/.config/omarchy/backgrounds/<текущая тема> и проходит по подпапкам текстовым меню (abstract, anime, nord…). В папке без подпапок открывается обычная сетка превью. На верхнем уровне в пункте «Images» к ним добавляются ещё и backgrounds/ самой темы. Если папки ~/.config/omarchy/backgrounds/<тема> нет, открывается стандартная сетка.
