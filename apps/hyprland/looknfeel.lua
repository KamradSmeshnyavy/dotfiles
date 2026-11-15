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

-- Добавочные рамки окон — плагин borders-plus-plus (hyprwm/hyprland-plugins, собирает `just hypr-plugins`).
-- Тема просит их глобальной таблицей `omarchy_theme_borders` в своём hyprland.lua (он грузится раньше, см. rumda);
-- у остальных тем добавочных рамок нет. Нет собранного плагина — ничего не делаем. Пока плагин не загружен
-- (первый проход конфига), его ключей ещё нет — pcall глушит ошибку, Hyprland перечитает конфиг после загрузки.
do
	local so = os.getenv("HOME") .. "/.local/lib/hypr-plugins/borders-plus-plus.so"
	local f = io.open(so, "r")
	if f then
		f:close()
		hl.plugin.load(so)
		local spec = omarchy_theme_borders or { add_borders = 0 }
		omarchy_theme_borders = nil
		pcall(hl.config, { plugin = { borders_plus_plus = spec } })
	end
end

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
