-- Запасная тема yatline, если у темы нет colors.toml для генерации
return {
	setup = function()
		return require("yatline-catppuccin"):setup("mocha")
	end,
}
