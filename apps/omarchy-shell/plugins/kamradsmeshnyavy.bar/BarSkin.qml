import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons

// Внешний вид бара из ~/.config/omarchy/bar-skin.json. Файл пишет Customizer
// (customizer.sh bar-skins / bar-tweaks); FileView следит за ним, поэтому скин
// применяется на лету, без `omarchy restart shell`. Нет файла — стоковый вид.
//
// Цвет в скине — роль или "#rrggbb":
//   bar          стоковый цвет бара из shell.toml [bar]
//   background foreground accent muted urgent   роли Commons.Color
//   любой ключ colors.toml текущей темы (red, cyan, lighter_background, …)
// Роли перекрашиваются вместе с темой.
QtObject {
  id: root

  property bool vertical: false
  property string position: "top"

  readonly property string home: Quickshell.env("HOME")
  readonly property string path: home + "/.config/omarchy/bar-skin.json"

  readonly property var defaults: ({
    shape: "full",          // full floating pill islands notch underline hug
    height: 0,              // 0 = Style.bar.size*
    gap: 0,                 // отступ от края экрана (floating/pill/islands/notch)
    margin: 0,              // отступ слева/справа
    width: 1.0,             // доля ширины экрана (pill/notch/floating)
    radius: 0,
    padding: -1,            // отступ модулей от краёв подложки; -1 = сток
    islandGap: 0,           // islands: доп. отступ острова вокруг секции
    background: "bar",
    backgroundAlpha: -1,    // -1 = альфа из shell.toml [bar]
    gradient: "",           // второй цвет горизонтального градиента
    border: "accent",
    borderWidth: 0,
    borderAlpha: 1.0,
    text: "bar",
    active: "bar",
    shadow: false,
    glow: false,            // свечение цветом рамки вместо тени
    autoHide: false,        // прятать за край, показывать по наведению
    moduleStyle: "plain",   // plain pills hover — подложка у каждого модуля
    moduleBackground: "foreground",
    moduleAlpha: 0.08,
    spacing: 0,             // зазор между модулями
    // compact: бар сжимается, когда на workspace одно окно / полноэкранное / всегда.
    compact: "off",         // off single fullscreen always
    compactHeight: 22,      // 0 = высота не меняется
    compactModules: "essentials", // all essentials center minimal — что остаётся видно
    compactShape: "full",   // same full floating pill notch underline hug
    compactAlpha: -1,       // альфа фона в compact; -1 = как обычно
    compactReserve: "keep", // keep — место под баром прежнее (окна не дёргаются); shrink — ужимается
    compactExpandOnHover: true,
    font: ""
  })

  property var raw: ({})
  property var palette: ({})

  function value(key) {
    var v = raw[key]
    return v === undefined || v === null ? defaults[key] : v
  }
  function num(key) {
    var n = Number(value(key))
    return isFinite(n) ? n : Number(defaults[key])
  }

  readonly property string requestedShape: String(value("shape"))
  // Вертикальный бар умеет только полосу и floating.
  function normalizeShape(s) {
    s = String(s)
    if (["full", "floating", "pill", "islands", "notch", "underline", "hug"].indexOf(s) === -1) s = "full"
    if (vertical && s === "hug") s = "full"
    if (vertical && s !== "full") s = "floating"
    return s
  }
  readonly property string shape: normalizeShape(requestedShape)

  // Геометрия для произвольной формы: compact может подменить форму у одного окна.
  function gapFor(s) { return s === "full" || s === "underline" || s === "notch" || s === "hug" ? 0 : Math.max(0, Math.round(num("gap"))) }
  function marginFor(s) { return s === "full" || s === "underline" || s === "hug" ? 0 : Math.max(0, Math.round(num("margin"))) }
  function widthFor(s) { return s === "pill" || s === "notch" || s === "floating" ? Math.max(0.2, Math.min(1, num("width"))) : 1 }
  function hugRadiusFor(s) { return s === "hug" ? Math.max(8, Math.round(num("radius"))) : 0 }

  readonly property bool detached: shape === "floating" || shape === "pill" || shape === "islands"
  readonly property int gap: gapFor(shape)
  readonly property int margin: marginFor(shape)
  readonly property real widthFraction: widthFor(shape)
  readonly property int height: Math.max(0, Math.round(num("height")))
  readonly property int padding: Math.round(num("padding"))
  readonly property int islandGap: Math.max(0, Math.round(num("islandGap")))
  readonly property int borderWidth: Math.max(0, Math.round(num("borderWidth")))
  readonly property bool shadow: value("shadow") === true
  readonly property bool glow: value("glow") === true
  readonly property bool autoHide: value("autoHide") === true
  readonly property string moduleStyle: ["pills", "hover"].indexOf(String(value("moduleStyle"))) !== -1 ? String(value("moduleStyle")) : "plain"
  readonly property int spacing: Math.max(0, Math.round(num("spacing")))

  readonly property string compactMode: ["single", "fullscreen", "always"].indexOf(String(value("compact"))) !== -1 ? String(value("compact")) : "off"
  readonly property int compactHeight: Math.max(0, Math.round(num("compactHeight")))
  readonly property string compactModules: ["all", "essentials", "center", "minimal"].indexOf(String(value("compactModules"))) !== -1 ? String(value("compactModules")) : "essentials"
  readonly property string compactShape: String(value("compactShape")) === "same" ? "same" : normalizeShape(value("compactShape"))
  readonly property real compactAlpha: num("compactAlpha")
  readonly property bool compactShrink: String(value("compactReserve")) === "shrink"
  readonly property bool compactExpandOnHover: value("compactExpandOnHover") !== false

  // Виджеты, которые compact «essentials» оставляет.
  readonly property var compactEssentials: ["kamradsmeshnyavy.menu", "omarchy.menu", "omarchy.workspaces", "omarchy.clock",
    "omarchy.network", "omarchy.audio", "omarchy.power", "omarchy.battery"]
  function compactHides(name, region) {
    if (compactModules === "all") return false
    if (compactModules === "center") return region !== "center"
    if (compactModules === "minimal") return name !== "omarchy.workspaces" && name !== "omarchy.clock"
    return compactEssentials.indexOf(name) === -1
  }
  // hug: вогнутые углы под баром, радиус из radius (минимум 8, иначе их не видно).
  readonly property int hugRadius: hugRadiusFor(shape)
  readonly property string font: String(value("font") || "")

  function radiusFor(h, s) {
    if (s === undefined) s = shape
    if (s === "pill") return h / 2
    if (s === "hug" || s === "full") return 0
    return Math.max(0, Math.min(num("radius"), h / 2))
  }

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

  function withAlpha(c, a) {
    return Qt.rgba(c.r, c.g, c.b, Math.max(0, Math.min(1, a)))
  }

  readonly property color textColor: resolve(value("text"), Commons.Color.bar.text)
  readonly property color activeColor: resolve(value("active"), Commons.Color.bar.active)
  readonly property color backgroundColor: {
    var c = resolve(value("background"), Commons.Color.bar.background)
    var a = num("backgroundAlpha")
    return a < 0 ? c : withAlpha(c, a)
  }
  readonly property bool hasGradient: String(value("gradient") || "") !== ""
  readonly property color gradientColor: {
    var c = resolve(value("gradient"), backgroundColor)
    return withAlpha(c, backgroundColor.a)
  }
  readonly property color borderColor: withAlpha(resolve(value("border"), Commons.Color.accent), num("borderAlpha"))
  readonly property color moduleColor: withAlpha(resolve(value("moduleBackground"), Commons.Color.foreground), num("moduleAlpha"))

  function parseSkin(text) {
    try {
      var parsed = JSON.parse(String(text || "{}"))
      raw = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {}
    } catch (e) {
      console.warn("bar-skin.json: " + e)
    }
  }

  function parsePalette(text) {
    var out = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var m = lines[i].match(/^\s*([A-Za-z0-9_]+)\s*=\s*["'](#[0-9A-Fa-f]{6})["']/)
      if (m) out[m[1]] = m[2]
    }
    palette = out
  }

  property FileView skinFile: FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    onLoaded: root.parseSkin(text())
    onLoadFailed: root.raw = {}
    // text() в сигнале изменения ещё старый — перечитываем через reload().
    onFileChanged: reload()
  }

  property FileView paletteFile: FileView {
    id: paletteFile
    path: root.home + "/.local/state/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onLoaded: root.parsePalette(text())
    onFileChanged: reload()
  }

  // Смена темы приходит в Color по IPC раньше, чем перезаписанный colors.toml
  // успевает дёрнуть watch, — перечитываем палитру и по этому сигналу.
  property Connections themeWatch: Connections {
    target: Commons.Color
    function onBackgroundChanged() { paletteFile.reload() }
    function onAccentChanged() { paletteFile.reload() }
  }
}
