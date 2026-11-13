-- Doodle (Vitreus): тонкая рамка — активная в сигнальном цвете, неактивная — линия.
local active_border_color = "rgb(e0457b)"
local inactive_border_color = "rgb(ebe3d2)"

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
