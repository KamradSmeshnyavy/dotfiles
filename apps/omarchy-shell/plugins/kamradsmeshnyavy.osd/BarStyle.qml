import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

// Стиль панелей рядом с баром (дашборд, меню выключения, OSD, уведомления).
// Один и тот же файл лежит в omarchy-desktop-widgets, omarchy-edge-osd и
// omarchy-drawer-notifications — правки переносить во все три.
//
// Читает ~/.config/omarchy/bar-skin.json (kamradsmeshnyavy.bar) и colors.toml темы.
//   follow  true  — цвет, прозрачность, рамка и скругление как у бара. Сплошной бар — его цвет;
//                   полупрозрачный — тот же цвет не прозрачнее 0.6; почти прозрачный (стекло,
//                   islands) — стекло: фон темы с альфой 0.72 под размытием Hyprland и рамка бара
//                   (0.92, если размытие выключено, — иначе сквозь панель читается текст окон).
//           false — свои background / alpha / radius / border.
//   attach  auto     — прилипать (вогнутые углы к бару / краю) только к сплошному бару у края:
//                      frame, hug, full; иначе — плавающая карточка с отступом и тенью.
//           attached / floating — принудительно.
QtObject {
  id: style

  property bool follow: true
  property string attach: "auto"
  property string background: "background"
  property real alpha: 0.94
  property int radius: 18
  property bool border: false

  property var skin: ({})
  property var palette: ({})
  readonly property string home: Quickshell.env("HOME")

  readonly property string shape: String(skin.shape || "full")

  function num(v, def) { var n = Number(v); return isFinite(n) ? n : def }
  function resolve(spec, fallback) {
    var s = String(spec === undefined || spec === null ? "" : spec).trim()
    if (s === "" || s === "bar") return fallback
    if (s.charAt(0) === "#") return Qt.color(s)
    if (s === "background") return Commons.Color.background
    if (s === "foreground") return Commons.Color.foreground
    if (s === "accent") return Commons.Color.accent
    if (s === "muted") return Commons.Color.muted
    if (s === "urgent") return Commons.Color.urgent
    if (palette[s]) return Qt.color(palette[s])
    return fallback
  }
  function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, Math.max(0, Math.min(1, a))) }

  // Подложка бара как её рисует SkinFrame.
  readonly property color barFill: {
    var c = resolve(skin.background, Commons.Color.bar.background)
    var a = num(skin.backgroundAlpha, -1)
    return a < 0 ? c : withAlpha(c, a)
  }
  readonly property bool barGlass: barFill.a < 0.15 || shape === "islands" || skin.transparent === true
  readonly property bool barSolid: !barGlass && barFill.a >= 0.6

  readonly property bool attached: attach === "attached"
    || (attach === "auto" && barSolid && ["frame", "hug", "full"].indexOf(shape) !== -1)

  // ── Итог для отрисовки ────────────────────────────────────────────────
  readonly property color color: !follow ? withAlpha(resolve(background, Commons.Color.popups.background), alpha)
    : barGlass ? withAlpha(Commons.Color.popups.background, blurOn ? 0.72 : 0.92)
    : withAlpha(barFill, Math.max(0.6, barFill.a))
  readonly property bool glass: follow && barGlass
  readonly property int borderWidth: follow ? Math.max(0, Math.round(num(skin.borderWidth, 0))) : (border ? 1 : 0)
  readonly property color borderColor: follow
    ? withAlpha(resolve(skin.border, Commons.Color.accent), num(skin.borderAlpha, 1))
    : withAlpha(Commons.Color.accent, 0.4)
  readonly property int cornerRadius: follow ? Math.max(10, Math.round(num(skin.radius, 12)) + 6) : radius
  // Радиус вогнутых углов у бара: у frame / hug — как у бара.
  readonly property int flare: shape === "frame" || shape === "hug" ? Math.max(8, Math.round(num(skin.radius, 0))) : 14

  // Включено ли размытие в Hyprland (Customizer → Blur может его выключить). refresh() — при открытии панели.
  property bool blurOn: true
  function refresh() { blurProbe.running = true }
  property Process blurProbe: Process {
    command: ["hyprctl", "getoption", "decoration:blur:enabled", "-j"]
    stdout: StdioCollector {
      onStreamFinished: { try { var o = JSON.parse(text); style.blurOn = o.bool !== undefined ? o.bool === true : o.int !== 0 } catch (e) {} }
    }
  }
  Component.onCompleted: refresh()

  property FileView skinFile: FileView {
    path: style.home + "/.config/omarchy/bar-skin.json"
    watchChanges: true
    printErrors: false
    onLoaded: { try { style.skin = JSON.parse(text() || "{}") || {} } catch (e) { style.skin = {} } }
    onLoadFailed: style.skin = {}
    onFileChanged: reload()
  }
  property FileView paletteFile: FileView {
    path: style.home + "/.local/state/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onLoaded: {
      var out = {}
      var lines = String(text() || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        var m = lines[i].match(/^\s*([A-Za-z0-9_]+)\s*=\s*["'](#[0-9A-Fa-f]{6})["']/)
        if (m) out[m[1]] = m[2]
      }
      style.palette = out
    }
    onFileChanged: reload()
  }
}
