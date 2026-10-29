-- Yazi file picker (xdg-desktop-portal-termfilechooser)
o.window("^yazi-picker$", { float = true, size = "800 600", center = true })

-- Yazi folder opener (from Chromium "Show in folder", etc)
o.window("^yazi-folder$", { float = true, size = "800 600", center = true })

-- Блюр под полупрозрачным баром (скины kamradsmeshnyavy.bar). Пиксели с альфой
-- ниже 0.2 — зазоры floating/islands и прозрачные скины — не размываются.
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = 0.2 })
-- Стекло у панелей рядом с баром (дашборд, меню выключения, уведомления, OSD — BarStyle.qml
-- делает их полупрозрачными, когда бар прозрачный). Пустые части окон (альфа < 0.2) не размываются.
for _, ns in ipairs({ "omarchy-dashboard", "omarchy-power", "omarchy-notifications", "omarchy-osd" }) do
	hl.layer_rule({ match = { namespace = ns }, blur = true, ignore_alpha = 0.2 })
end
-- Блюр под оверлеем Customizer задаёт сам плагин (hypr/customizer.lua).

-- Быстрый браузер-панель (WaveTerm style)
o.window("^chrome-google.com__-Default$", { float = true })


