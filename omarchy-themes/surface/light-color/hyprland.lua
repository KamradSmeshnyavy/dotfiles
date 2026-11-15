-- Surface Light: рамка, тень и groupbar окон как у surface-dots (omarchy-themes/surface/build.py).
hl.config({
	general = { col = { active_border = "rgba(608552cc)", inactive_border = "rgba(a39e93aa)" } },
	decoration = { shadow = { range = 3, render_power = 4, color = "rgba(44220044)", color_inactive = "rgba(44220044)" } },
	group = {
		col = { border_active = "rgba(00000000)", border_inactive = "rgba(00000000)" },
		groupbar = { gradients = true, col = { active = "rgb(759b61)", inactive = "rgba(d8d2c8ff)" },
			text_color = "rgb(293136)", text_color_inactive = "rgba(252e33ff)", gradient_rounding = 8, height = 16 },
	},
})
