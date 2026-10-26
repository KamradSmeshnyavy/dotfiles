-- Yazi file picker (xdg-desktop-portal-termfilechooser)
o.window("^yazi-picker$", { float = true, size = "800 600", center = true })

-- Yazi folder opener (from Chromium "Show in folder", etc)
o.window("^yazi-folder$", { float = true, size = "800 600", center = true })

-- Блюр под полупрозрачным баром (скины kamradsmeshnyavy.bar). Пиксели с альфой
-- ниже 0.2 — зазоры floating/islands и прозрачные скины — не размываются.
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = 0.2 })
-- Customizer — «стекло»: размывается только окно (альфа ~0.74), затемнение экрана
-- вокруг (scrim, альфа ниже 0.6) не размывается.
hl.layer_rule({ match = { namespace = "omarchy-customizer" }, blur = true, ignore_alpha = 0.6 })

-- Быстрый браузер-панель (WaveTerm style)
o.window("^chrome-google.com__-Default$", { float = true })


