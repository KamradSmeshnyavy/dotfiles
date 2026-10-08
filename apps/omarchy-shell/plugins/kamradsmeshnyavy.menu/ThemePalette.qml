import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// The full colour set of the active Omarchy theme. Color.qml only keeps
// foreground, background, accent, urgent and muted, but the ported launcher
// skins were drawn with a whole palette (neon pink next to cyan, gold next to
// red), so they need the named hues too. Each hue falls back to its terminal
// colourN slot and then to the accent, so a sparse theme still paints.
//
// Not watched: a theme switch replaces the directory under the file. The menu
// calls reload() on every open instead, which is the only moment it matters.
Item {
  id: root

  readonly property string path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"

  property var values: ({})

  readonly property color foreground: Color.foreground
  readonly property color background: Color.background
  readonly property color accent: Color.accent
  readonly property bool light: root.pickString("mode", "") === "light"
    || root.luma(root.background) > 0.55

  readonly property color muted: root.pick(["muted", "color8", "dark_foreground"], Util.alpha(root.foreground, 0.55))
  readonly property color selection: root.pick(["selection", "selection_background"], Util.alpha(root.accent, 0.35))
  readonly property color surface: root.pick(["lighter_background", "color0"], root.mix(root.background, root.foreground, 0.08))
  readonly property color deep: root.pick(["darker_background", "dark_background"], root.mix(root.background, "#000000", 0.35))
  readonly property color dim: root.pick(["dark_foreground", "muted", "color8"], Util.alpha(root.foreground, 0.55))
  readonly property color bright: root.pick(["bright_foreground", "color15"], root.foreground)

  readonly property color red: root.pick(["red", "color1"], Color.urgent)
  readonly property color green: root.pick(["green", "color2"], root.accent)
  readonly property color yellow: root.pick(["yellow", "color3"], root.accent)
  readonly property color blue: root.pick(["blue", "color4"], root.accent)
  readonly property color magenta: root.pick(["magenta", "color5"], root.accent)
  readonly property color cyan: root.pick(["cyan", "color6"], root.accent)
  readonly property color orange: root.pick(["orange", "bright_red", "color9"], root.yellow)
  readonly property color brown: root.pick(["brown", "color11"], root.mix(root.orange, root.background, 0.45))

  // The hues in a stable order, for skins that cycle colours per item.
  readonly property var hues: [root.accent, root.magenta, root.cyan, root.yellow, root.green, root.red, root.blue, root.orange]

  function pickString(key, fallback) {
    var value = root.values[key]
    return value === undefined ? fallback : value
  }

  function pick(keys, fallback) {
    for (var i = 0; i < keys.length; i++) {
      var value = root.values[keys[i]]
      if (value) return value
    }
    return fallback
  }

  function luma(c) {
    return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
  }

  // Straight blend of two colours; t = 0 is a, t = 1 is b.
  function mix(a, b, t) {
    var ca = Qt.color(a)
    var cb = Qt.color(b)
    return Qt.rgba(ca.r + (cb.r - ca.r) * t,
                   ca.g + (cb.g - ca.g) * t,
                   ca.b + (cb.b - ca.b) * t,
                   ca.a + (cb.a - ca.a) * t)
  }

  // Readable text for a fill: themes ship both light and dark accents.
  function ink(fill) {
    return root.luma(Qt.color(fill)) > 0.55 ? root.mix(root.background, "#000000", 0.4) : root.mix(root.foreground, "#ffffff", 0.3)
  }

  // "r,g,b" for Canvas rgba() strings, which can't take a QML color.
  function rgb(c) {
    var q = Qt.color(c)
    return Math.round(q.r * 255) + "," + Math.round(q.g * 255) + "," + Math.round(q.b * 255)
  }

  function rgba(c, a) {
    return "rgba(" + root.rgb(c) + "," + Number(a).toFixed(3) + ")"
  }

  function parse(raw) {
    var out = ({})
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var hex = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']?(#[0-9A-Fa-f]{6})/)
      if (hex) { out[hex[1]] = hex[2]; continue }
      var word = lines[i].match(/^\s*([A-Za-z0-9_-]+)\s*=\s*["']([A-Za-z]+)["']/)
      if (word) out[word[1]] = word[2]
    }
    root.values = out
  }

  function reload() {
    file.reload()
  }

  FileView {
    id: file
    path: root.path
    printErrors: false
    onLoaded: root.parse(text())
    onLoadFailed: root.values = ({})
  }
}
