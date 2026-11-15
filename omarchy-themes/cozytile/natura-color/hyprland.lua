-- Cozytile Natura: окна без рамки и с мягкой тенью, как у Cozytile (omarchy-themes/cozytile/build.py).
local border = "rgb(0F1212)"
hl.config({
	general = { col = { active_border = border, inactive_border = border } },
	group = { col = { border_active = border, border_inactive = border } },
	decoration = { shadow = { range = 15, render_power = 3, offset = "-4 6", color = "rgba(00000080)", color_inactive = "rgba(00000060)" } },
})
