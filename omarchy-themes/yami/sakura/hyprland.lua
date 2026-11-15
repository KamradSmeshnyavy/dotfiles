-- Sakura (yami): тонкая рамка — активная в сигнальном цвете, неактивная — линия.
local active_border_color = "rgb(d9577c)"
local inactive_border_color = "rgb(532532)"

hl.config({
	general = {
		col = {
			active_border = active_border_color,
			inactive_border = inactive_border_color,
		},
	},

	group = {
		col = {
			border_active = active_border_color,
			border_inactive = inactive_border_color,
		},
	},
})
