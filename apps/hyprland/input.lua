hl.config({
	input = {
		kb_layout = "custom, custom",
		kb_variant = "us_overlay, ru_overlay",
		-- kb_options = "grp:alt_space_toggle",
		repeat_rate = 40,
		repeat_delay = 250,
		numlock_by_default = true,
		sensitivity = 0.35,
		accel_profile = "flat",
		touchpad = {
			natural_scroll = true,
			clickfinger_behavior = true,
			scroll_factor = 0.4,
			disable_while_typing = false,
			drag_3fg = 1,
		},
	},
})

-- Жесты тачпада: четыре пальца (три заняты drag_3fg). В стороны — рабочие столы,
-- вверх — обзор столов, вниз — дашборд (оба — плагин kamradsmeshnyavy.widgets).
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = function() hl.exec_cmd("omarchy-shell widgets toggleOverview") end })
hl.gesture({ fingers = 4, direction = "down", action = function() hl.exec_cmd("omarchy-shell widgets toggleDashboard") end })

o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
