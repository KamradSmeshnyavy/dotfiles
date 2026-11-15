-- Bruteon: рамка цветом контура и жёсткая тень без размытия (omarchy-themes/bruteon/build.py).
local border = "rgb(161110)"
hl.config({
	general = { col = { active_border = border, inactive_border = border } },
	group = { col = { border_active = border, border_inactive = border } },
	decoration = { shadow = { range = 1, render_power = 4, sharp = true, offset = "6 6", color = "rgba(161110ff)", color_inactive = "rgba(161110ff)" } },
})
