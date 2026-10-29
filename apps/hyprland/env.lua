-- Принудительный запуск Ghostty через нативный Wayland
hl.env("GHOSTTY_WAYLAND", "1")

-- Оптимизация драйверов под встроенную графику Intel Arc (Lunar Lake)
hl.env("MESA_LOADER_DRIVER_NAME", "iris")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "intel")

-- Курсор следует теме: omarchy-app-themes пишет «ИМЯ РАЗМЕР» в state; здесь — запасной вариант
local cursor, cursor_size = "BreezeX-RosePine-Linux", "24"
do
	local f = io.open(os.getenv("HOME") .. "/.local/state/omarchy/app-themes/cursor", "r")
	if f then
		local name, size = (f:read("*l") or ""):match("^(%S+)%s+(%d+)")
		f:close()
		if name then
			cursor, cursor_size = name, size
		end
	end
end
hl.env("XCURSOR_THEME", cursor)
hl.env("XCURSOR_SIZE", cursor_size)

-- Qt берёт палитру темы через qt6ct (omarchy-app-themes пишет qt6ct.conf); без пакета — стоковый gtk3
do
	local f = io.open("/usr/lib/qt6/plugins/platformthemes/libqt6ct.so", "r")
	if f then
		f:close()
		hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
	end
end
