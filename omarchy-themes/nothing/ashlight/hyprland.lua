-- Nothing Ash Light: тонкая рамка — активная в сигнальном цвете, неактивная — линия.
local active_border_color = "rgb(d71921)"
local inactive_border_color = "rgb(d4d4d0)"

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
