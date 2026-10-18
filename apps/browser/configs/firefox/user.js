// Замер 2026-10-14 (RAPL): layout.frame_rate=60 игнорируется при аппаратном vsync,
// compositor.force-enabled даёт −0.2 Вт (шум), webrender.all уже по умолчанию,
// backgroundUsesEcoQoS работает только в Windows, Pocket удалён из Firefox — всё убрано.

// -- for 60 fps
//user_pref("widget.wayland.vsync.enabled", false); // кадры по своему таймеру, а не по сигналам композитора
//user_pref("layout.frame_rate", 60);
// --
// --- Wayland
user_pref("widget.wayland.opaque-region.enabled", true);
user_pref("gfx.webrender.compositor", true);
// ------------------------------------------------------------
// --- Own settings
user_pref("browser.newtab.preload", false);
user_pref("ui.prefersReducedMotion", 1);
user_pref("accessibility.force_disabled", 1);
user_pref("dom.ipc.processCount", 4);
user_pref("browser.sessionstore.interval", 300000);
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

user_pref("general.smoothScroll", false);
// -- Блокировка автовоспроизведения видео
user_pref("media.autoplay.default", 5);

// ============================================================
// Из Betterfox (github.com/yokoffing/Betterfox), выборочно, 2026-10-18.
// Не взяты: browser.cache.disk.enable=false (после рестарта всё качается
// заново), sessionstore.interval=60000 (у нас 300000), contentblocking
// "strict" (uBlock Origin уже режет больше), Smoothfox.

// --- Локальные ML/AI-функции (инференс на CPU/GPU)
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ml.enable", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.ml.linkPreview.enabled", false);

// --- Эксперименты Mozilla и остатки телеметрии
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("nimbus.rollouts.enabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);

// --- Без упреждающих соединений и лишних запросов
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("security.OCSP.enabled", 0); // CRLite проверяет отзыв локально

// --- Загрузка страниц и видео: реже перерисовка, видео буферится пачкой
user_pref("content.notify.interval", 100000);
user_pref("media.cache_readahead_limit", 3600);
user_pref("media.cache_resume_threshold", 1800);

// --- Fastfox: кэши и сетевые лимиты (скорость, не батарея)
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("image.mem.decode_bytes_at_a_time", 32768);
user_pref("network.buffer.cache.size", 65535);
user_pref("network.buffer.cache.count", 48);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.request.max-start-delay", 5);
user_pref("network.dnsCacheExpiration", 3600);

// --- Новая вкладка, адресная строка, рекомендации
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);

// --- Приватность и удобство
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);
user_pref("network.IDN_show_punycode", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("permissions.default.desktop-notification", 2); // сайты не могут спросить про уведомления
user_pref("permissions.default.geo", 2);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // userChrome.css
user_pref("browser.compactmode.show", true);
user_pref("browser.aboutConfig.showWarning", false);
