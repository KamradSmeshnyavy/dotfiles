-- Bruteon: рамка цветом контура и жёсткая тень без размытия (omarchy-themes/bruteon/build.py).
local border = "rgb(f3e6dc)"
hl.config({
	general = { col = { active_border = border, inactive_border = border } },
	group = { col = { border_active = border, border_inactive = border } },
	decoration = { shadow = { range = 1, render_power = 4, sharp = true, offset = "6 6", color = "rgba(f3e6dcff)", color_inactive = "rgba(f3e6dcff)" } },
})
-- заголовки окон, как на его скриншотах (плагин hyprbars, грузит apps/hyprland/looknfeel.lua; собрать — just hypr-plugins):
-- полоса цветом карточки внутри общей рамки, жирное имя слева, справа — розовая плитка ✕ (двойной клик — развернуть)
omarchy_theme_bars = {
	config = {
		bar_height = 28, bar_color = "rgb(2a2320)", ["col.text"] = "rgb(f3e6dc)",
		bar_text_font = "JetBrainsMono Nerd Font", bar_text_size = 11, bar_text_weight = "bold", bar_text_align = "left",
		bar_padding = 10, bar_button_padding = 6, bar_part_of_window = true, bar_precedence_over_border = true,
		on_double_click = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
	},
	buttons = {
		{ bg_color = "rgb(ffcbd5)", fg_color = "rgb(161110)", size = 16, icon = "✕", action = "hyprctl dispatch 'hl.dsp.window.close()'" },
		{ bg_color = "rgb(c5e1a5)", fg_color = "rgb(161110)", size = 16, icon = "", action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']] },
	},
}
