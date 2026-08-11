// --- Added by Opencode for Wayland & Battery Optimization ---
user_pref("widget.wayland.opaque-region.enabled", true);
user_pref("gfx.webrender.compositor", true);
// user_pref("gfx.webrender.compositor.force-enabled", true);
user_pref("layout.frame_rate", 60);
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
