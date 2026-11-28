import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

// Палитра райса Cozy Room (omarchy-rices/room): токены из room.json текущей темы — стена, пол, дерево, свет лампы,
// бумага записок, цвета книг; места предметов на фоне дашборда (dash). Без room.json — из цветов темы.
// Одинаковый файл в kamradsmeshnyavy.{bar/modules, widgets, osd, notifications/components, lock/designs, image-picker,
// menu} — правку переносить во все.
QtObject {
  id: pal
  readonly property string themeDir: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme"
  property var t: ({})
  property FileView file: FileView {
    path: pal.themeDir + "/room.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { pal.t = JSON.parse(text()) } catch (e) { pal.t = {} } }
    onLoadFailed: pal.t = ({})
  }
  readonly property bool ok: t.rice === "room"
  function c(key, fallback) { return ok && t[key] ? t[key] : fallback }
  function mix(a, b, k) { return Qt.rgba(a.r + (b.r - a.r) * k, a.g + (b.g - a.g) * k, a.b + (b.b - a.b) * k, 1) }
  function alpha(col, a) { return Qt.rgba(col.r, col.g, col.b, a) }

  readonly property color wall: c("wall", Commons.Color.background)
  readonly property color wall2: c("wall2", Commons.Color.background)
  readonly property color floor: c("floor", mix(Commons.Color.background, Commons.Color.accent, 0.3))
  readonly property color night: c("night", "#1b2944")
  readonly property color lamp: c("lamp", Commons.Color.accent)
  readonly property color text: c("text", Commons.Color.foreground)
  readonly property color dim: c("dim", mix(Commons.Color.foreground, Commons.Color.background, 0.35))
  readonly property color ink: c("ink", "#21161d")
  readonly property color wood: c("wood", mix(Commons.Color.background, Commons.Color.accent, 0.4))
  readonly property color wood2: c("wood2", mix(Commons.Color.background, Commons.Color.accent, 0.2))
  readonly property color dark: c("dark", Commons.Color.background)
  readonly property color paper: c("paper", "#f4e3c1")
  readonly property color paperink: c("paperink", "#3b241c")
  readonly property color red: c("red", Commons.Color.urgent)
  readonly property color grn: c("grn", "#7aa860")
  readonly property color cyan: c("cyan", "#7fb2d9")
  readonly property color pink: c("pink", "#e48aa0")
  readonly property bool light: ok && t.mode === "light"
  // текст на дереве: у светлой Сакуры дерево тёмное — текст бумажный
  readonly property color onWood: light ? paper : text
  readonly property color onWoodDim: light ? alpha(paper, 0.7) : dim
  readonly property bool rain: ok && t.weather === "rain"
  readonly property var dash: ok && t.dash ? t.dash : null

  function has(f) { return Qt.fontFamilies().indexOf(f) !== -1 }
  readonly property string font: has("Pixelify Sans") ? "Pixelify Sans" : "sans-serif"
  readonly property string mono: has("Departure Mono") ? "Departure Mono" : "monospace"
  readonly property var bookColors: [red, grn, lamp, cyan, pink, text, wood]

  // спрайты есть только у тем room-*; у другой темы — пусто
  function sprite(name) { return ok ? "file://" + themeDir + "/room/" + name + ".png" : "" }
}
