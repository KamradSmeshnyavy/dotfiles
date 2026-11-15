-- Rumda Light: рамка и тень окон как у Rumda (omarchy-themes/rumda/build.py).
local border = "rgb(f2bc88)"

hl.config({
	general = { col = { active_border = border, inactive_border = border } },
	group = { col = { border_active = border, border_inactive = border } },
	decoration = {
		shadow = { range = 7, render_power = 4, offset = "5 4", color = "0xaa784d37", color_inactive = "0xaa784d37", scale = 1.0 },
	},
})
