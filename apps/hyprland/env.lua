-- Принудительный запуск Ghostty через нативный Wayland
hl.env("GHOSTTY_WAYLAND", "1")

-- Оптимизация драйверов под встроенную графику Intel Arc (Lunar Lake)
hl.env("MESA_LOADER_DRIVER_NAME", "iris")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "intel")
