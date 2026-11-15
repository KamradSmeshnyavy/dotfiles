-- Rumda Light: рамка и тень окон как у Rumda (omarchy-themes/rumda/build.py).
local border = "rgb(f2bc88)"

-- двойная рамка: читает apps/hyprland/looknfeel.lua (плагин borders-plus-plus)
omarchy_theme_borders = {
	add_borders = 2, natural_rounding = true, border_size_1 = 11, border_size_2 = -1,
	col = { border_1 = "rgb(f5dcc6)", border_2 = "rgb(f5dcc6)" },
}

hl.config({
	general = { col = { active_border = border, inactive_border = border } },
	group = { col = { border_active = border, border_inactive = border } },
	decoration = {
		shadow = { range = 7, render_power = 4, offset = "5 4", color = "0xaa784d37", color_inactive = "0xaa784d37", scale = 1.0 },
	},
})
