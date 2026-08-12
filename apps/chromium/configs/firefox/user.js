// --- Added by Opencode for Wayland & Battery Optimization ---
user_pref("widget.wayland.opaque-region.enabled", true);
user_pref("gfx.webrender.compositor", true);
// user_pref("gfx.webrender.compositor.force-enabled", true);
user_pref("layout.frame_rate", 60);
// ------------------------------------------------------------
// --- Own settings
user_pref("browser.newtab.preload", false)
user_pref("gfx.webrender.all", true)
user_pref("ui.prefersReducedMotion", 1)
user_pref("accessibility.force_disabled", 1)
user_pref("extensions.pocket.enabled", false)
user_pref("dom.ipc.processCount", 4)
user_pref("dom.ipc.processPriorityManager.backgroundUsesEcoQoS", true)
//dom.ipc.processPriorityManager.backgroundUsesEcoQoS ➔ true
// ------------------------------------------------------------

// --- Hardware Video Acceleration (VA-API) ---
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.av1.enabled", true);

// --- OLED Power Savings (Force Dark Mode) ---
user_pref("layout.css.prefers-color-scheme.content-override", 0);

// --- Disable UI Animations ---
user_pref("toolkit.cosmeticAnimations.enabled", false);

// --- Disable Telemetry & Background Ping ---
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");

// --- Disable Prefetching (Network/CPU savings) ---
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);

// --- Tab Unloading (Memory/CPU savings) ---
user_pref("browser.tabs.unloadOnLowMemory", true);
