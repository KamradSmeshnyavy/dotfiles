import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

// Палитра райса Quest (omarchy-rices/quest): токены окна-диалога из quest.json текущей темы — градиент w1 → w2,
// рамка frame / frame2, текст, золото курсора hi, полоски hp / mp, урон red, контур ink, шрифты и спрайты темы.
// Без quest.json (тема другого райса) — то же из цветов темы, чтобы модули не ломались.
// Одинаковый файл в kamradsmeshnyavy.{bar/modules, widgets/quest, osd, notifications, lock/designs, menu} — правку переносить во все.
QtObject {
  id: pal
  readonly property string themeDir: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme"
  property var t: ({})
  property FileView file: FileView {
    path: pal.themeDir + "/quest.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { pal.t = JSON.parse(text()) } catch (e) { pal.t = {} } }
    onLoadFailed: pal.t = ({})
  }
  readonly property bool ok: t.rice === "quest"
  function c(key, fallback) { return ok && t[key] ? t[key] : fallback }
  function mix(a, b, k) { return Qt.rgba(a.r + (b.r - a.r) * k, a.g + (b.g - a.g) * k, a.b + (b.b - a.b) * k, 1) }
  function alpha(col, a) { return Qt.rgba(col.r, col.g, col.b, a) }

  readonly property color w1: c("w1", mix(Commons.Color.background, Commons.Color.accent, 0.35))
  readonly property color w2: c("w2", Commons.Color.background)
  readonly property color frame: c("frame", Commons.Color.foreground)
  readonly property color frame2: c("frame2", mix(Commons.Color.foreground, Commons.Color.background, 0.45))
  readonly property color text: c("text", Commons.Color.foreground)
  readonly property color dim: c("dim", mix(Commons.Color.foreground, Commons.Color.background, 0.35))
  readonly property color hi: c("hi", Commons.Color.accent)
  readonly property color hp: c("hp", "#5ee06a")
  readonly property color mp: c("mp", "#5cb4ff")
  readonly property color red: c("red", Commons.Color.urgent)
  readonly property color ink: c("ink", "#0a0c20")
  readonly property bool light: ok && t.mode === "light"
  readonly property int radius: ok && t.radius !== undefined ? Number(t.radius) : 6

  function has(f) { return Qt.fontFamilies().indexOf(f) !== -1 }
  // заголовки — Press Start 2P (у подземелья — готический Jacquard 12 Hell), текст — Pixelify Sans, цифры — Departure Mono
  readonly property string title: has(c("font", "Press Start 2P")) ? c("font", "Press Start 2P") : "monospace"
  readonly property bool gothic: title === "Jacquard 12 Hell"
  readonly property string body: has("Pixelify Sans") ? "Pixelify Sans" : "sans-serif"
  readonly property string mono: has("Departure Mono") ? "Departure Mono" : "monospace"
  // Press Start 2P чёткий на кратных 8 px; Jacquard — на кратных 12, но мелким (меньше 16 px) не читается:
  // мелкие подписи у готики — Pixelify Sans. font(n) / size(n) — шрифт и кегль заголовка размера n.
  function titleSize(n) { return gothic ? Math.round(n * 1.5) : n }
  function font(n) { return gothic && n < 16 ? body : title }
  function size(n) { return gothic ? (n < 16 ? Math.round(n * 1.75) : Math.round(n * 1.5)) : n }

  function sprite(name) { return "file://" + themeDir + "/quest/" + name + ".png" }
}
