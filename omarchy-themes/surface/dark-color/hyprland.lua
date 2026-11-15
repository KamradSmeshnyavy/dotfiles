-- Surface Dark: рамка, тень и groupbar окон как у surface-dots (omarchy-themes/surface/build.py).
hl.config({
	general = { col = { active_border = "rgba(87b158aa)", inactive_border = "rgba(595959aa)" } },
	decoration = { shadow = { range = 3, render_power = 4, color = "rgba(44220044)", color_inactive = "rgba(44220044)" } },
	group = {
		col = { border_active = "rgba(00000000)", border_inactive = "rgba(00000000)" },
		groupbar = { gradients = true, col = { active = "rgb(759b61)", inactive = "rgba(2D353Bff)" },
			text_color = "rgb(293136)", text_color_inactive = "rgba(e5e6c5ff)", gradient_rounding = 8, height = 16 },
	},
})
