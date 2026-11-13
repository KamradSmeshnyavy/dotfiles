pragma Singleton
import QtQuick
import qs.Commons as Commons

// Скин лаунчера glyph (из glyph-rice, GPL-3.0): вместо их Theme — палитра из текущей темы Omarchy. Семь серых от фона к тексту,
// как greys у glyph-rice (bg, s1 бар, s2 плитки, s3 линии и погасшие точки, mute, grey метки, fg), и один красный акцент.
QtObject {
  readonly property color bg: Commons.Color.background
  readonly property color fg: Commons.Color.foreground
  readonly property bool light: luma(bg) > 0.5
  function luma(c) { return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b }
  function mix(a, b, k) { return Qt.rgba(a.r + (b.r - a.r) * k, a.g + (b.g - a.g) * k, a.b + (b.b - a.b) * k, 1) }
  readonly property color s1: mix(bg, fg, 0.06)
  readonly property color s2: mix(bg, fg, 0.11)
  readonly property color s3: mix(bg, fg, 0.2)
  readonly property color mute: mix(bg, fg, 0.36)
  readonly property color grey: mix(bg, fg, 0.58)
  readonly property color ink: light ? s1 : bg
  readonly property color accent: Commons.Color.urgent
  function fade(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

  readonly property string dot: "Doto"
  readonly property string mono: "Space Mono"
  // glide: ease-out-quart без перелёта
  readonly property var glide: [0.25, 1, 0.5, 1, 1, 1]
  readonly property int t: 350
  function url(p) { return p ? "file://" + String(p).split("/").map(encodeURIComponent).join("/") : "" }
}
