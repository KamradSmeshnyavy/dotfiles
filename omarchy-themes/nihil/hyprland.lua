-- Рамки окон NIHIL: тонкие матовые линии без градиентов (muted / line).
local active_border_color = "rgb(7a7a7a)"
local inactive_border_color = "rgb(2a2a2a)"

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
