-- General look and feel overrides
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 2,
		layout = "dwindle",
	},
	decoration = {
		rounding = 10,
		-- active_opacity = 0.90,
		active_opacity = 1.00,
		inactive_opacity = 0.90,
		fullscreen_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.1,
		blur = {
			enabled = true,
			size = 6,
			passes = 3,
			new_optimizations = true,
			xray = true,
			ignore_opacity = true,
			special = true,
			popups = true,
		},
		shadow = {
			enabled = true,
			range = 3,
			render_power = 1,
		},
	},
	dwindle = {
		preserve_split = true,
		special_scale_factor = 0.8,
	},
})

-- Screen shader, transparency, blur and animation presets picked in the Customizer
-- (plugin kamradsmeshnyavy.customizer). The hook re-applies them while the config loads,
-- so `hyprctl reload` never flashes back to the defaults.
do
	local hook = os.getenv("HOME") .. "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/hypr/customizer.lua"
	local f = io.open(hook, "r")
	if f then
		f:close()
		dofile(hook)
	end
end
