pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons

// DOT-MATRIX (dot-matrix) palette and fonts. The same file ships in every plugin that
// draws the DOT-MATRIX style (widgets, osd, notifications, bar, menu, lock): change all
// copies together.
//
// ~/.config/omarchy/dotmatrix.json {"palette": "theme" | "mono"}
//   theme (default) — roles from the current omarchy theme, follow theme switches;
//   mono            — the original Nothing look (black, white, red) on any theme.
// Every role can be overridden in the same file (Customizer → Widgets → DOT-MATRIX palette):
//   "dotmatrixBg": "accent" | "blue" | "#1e1e2e" | "default" …  — a shell role, a colors.toml key or hex;
//   missing or "default" keeps the automatic colour below.
// Fonts fall back to the omarchy font when Doto / Space Mono / Space Grotesk are missing.
QtObject {
  id: root

  property string mode: "theme"
  readonly property bool mono: mode === "mono"
  property var overrides: ({})
  property var themeColors: ({})       // colors.toml of the current theme: key -> #hex

  function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
  function over(base, c, a) { return Qt.tint(base, alpha(c, a)) }

  // An override spec: hex, a shell role, or a colors.toml key; anything else keeps auto.
  function pick(key, auto) {
    var s = String(overrides[key] || "").trim()
    if (s === "" || s === "default") return auto
    if (/^#[0-9a-fA-F]{6}$/.test(s)) return Qt.color(s)
    if (s === "bar") return Commons.Color.bar.background
    if (s === "background") return Commons.Color.background
    if (s === "foreground") return Commons.Color.foreground
    if (s === "accent") return Commons.Color.accent
    if (s === "muted") return Commons.Color.muted
    if (s === "urgent") return Commons.Color.urgent
    if (themeColors[s]) return Qt.color(themeColors[s])
    return auto
  }

  readonly property color bg: pick("dotmatrixBg", mono ? "#000000" : Commons.Color.background)
  readonly property color fg: pick("dotmatrixFg", mono ? "#f2f2f2" : Commons.Color.foreground)
  readonly property color dim: pick("dotmatrixDim", mono ? "#8e8e8e" : alpha(fg, 0.62))
  readonly property color muted: pick("dotmatrixMuted", mono ? "#5a5a5a" : Commons.Color.muted)
  // Hairlines and unlit dots.
  readonly property color line: pick("dotmatrixLine", mono ? "#2a2a2a" : alpha(fg, 0.16))
  readonly property color lineSoft: mono && !overrides.dotmatrixLine ? "#1e1e1e" : alpha(line, line.a * 0.62)
  readonly property color unlit: mono ? "#222222" : alpha(fg, 0.12)
  // Raised surfaces: inputs, hovered and selected rows.
  readonly property color surface: pick("dotmatrixSurface", mono ? "#0a0a0a" : over(bg, fg, 0.04))
  readonly property color surfaceHi: mono && !overrides.dotmatrixSurface ? "#141414" : over(surface, fg, 0.04)
  // Lit LEDs, slider segments, active toggles and filled buttons.
  readonly property color lit: pick("dotmatrixLit", fg)
  // The Nothing red: lit LEDs and the active workspace take the theme accent,
  // destructive confirmations and critical states take urgent.
  readonly property color signal: pick("dotmatrixSignal", mono ? "#d71921" : Commons.Color.accent)
  readonly property color danger: pick("dotmatrixDanger", mono ? "#d71921" : Commons.Color.urgent)
  // Ink on a signal/danger fill.
  readonly property color onSignal: mono ? "#f2f2f2" : bg

  // Stock popups (qs.Ui PopupCard / KeyboardPanel) hard-code the card colour and radius
  // on their inner BorderSurface; repaint it in the DOT-MATRIX palette. Call from Component.onCompleted.
  function restyleCard(win, radius) {
    var kids = []
    if (win && win.data) for (var d = 0; d < win.data.length; d++) kids.push(win.data[d])
    if (win && win.contentItem && win.contentItem.children)
      for (var k = 0; k < win.contentItem.children.length; k++) kids.push(win.contentItem.children[k])
    for (var i = 0; i < kids.length; i++) {
      var c = kids[i]
      if (!c || c.borderSpec === undefined || c.padding === undefined || c.radius === undefined) continue
      c.color = Qt.binding(function() { return root.bg })
      c.radius = radius === undefined ? 18 : radius
    }
  }

  // Шрифты. ~/.config/omarchy/fonts.json — профиль шрифтов системы (omarchy-font-profile):
  //   stock — Space Grotesk / Space Mono как в Nihil-Shell; nothing / dot / pixel — sans и mono профиля
  //   (Geist, GeistMono / Terminess, с кириллицей). dot / pixel / dot-accents / dots-all — точечный слой (dotLayer):
  //   DotMatrix Dot во всём крупном и коротком — заголовках, номерах, метках.
  // DotMatrix Dot — Doto с кириллицей (kamradsmeshnyavy.customizer/fonts); без него — Doto, потом шрифт Omarchy.
  property var fontProfile: ({ profile: "stock" })
  readonly property bool dotLayer: fontProfile.profile === "dot" || fontProfile.profile === "pixel" || fontProfile.profile === "dot-accents" || String(fontProfile.profile).indexOf("dots-all") === 0
  // dot-accents / dots-all: ещё и заголовки карточек, уведомлений, пункты меню (fontHeading), не только крупное.
  readonly property bool dotEverywhere: fontProfile.profile === "dot-accents" || String(fontProfile.profile).indexOf("dots-all") === 0
  readonly property var families: Qt.fontFamilies()
  function family(name, fallback) {
    if (families.indexOf(name) >= 0) return name
    return fallback !== undefined ? fallback : Commons.Style.font.family
  }
  readonly property string fontDot: family("DotMatrix Dot", family("Doto"))
  readonly property string fontMono: fontProfile.profile !== "stock" && fontProfile.mono ? family(fontProfile.mono, family("Space Mono")) : family("Space Mono")
  readonly property string fontSans: fontProfile.profile !== "stock" && fontProfile.sans ? family(fontProfile.sans, family("Space Grotesk")) : family("Space Grotesk")
  readonly property string fontIcon: Commons.Style.font.family
  // Метки и заголовки: точками при точечном слое, иначе — моно-голос DotMatrix.
  readonly property string fontLabel: dotLayer ? fontDot : fontMono
  readonly property string fontTitle: dotLayer ? fontDot : fontSans
  // Заголовки второго уровня (карточки, уведомления, пункты меню): точками только у профиля dots.
  readonly property string fontHeading: dotEverywhere ? fontDot : fontSans
  function headingWeight(normal) { return dotEverywhere ? Font.Black : normal }
  // Точки при обычной толщине бледные — заголовки точечного слоя набираются Black, как часы.
  function titleWeight(normal) { return dotLayer ? Font.Black : normal }

  property FileView file: FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/dotmatrix.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var cfg = JSON.parse(text()) || {}
        root.mode = cfg.palette === "mono" ? "mono" : "theme"
        root.overrides = cfg
      } catch (e) { root.mode = "theme"; root.overrides = {} }
    }
    onLoadFailed: { root.mode = "theme"; root.overrides = {} }
  }

  property FileView fontsFile: FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/fonts.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try { root.fontProfile = JSON.parse(text()) || { profile: "stock" } } catch (e) { root.fontProfile = { profile: "stock" } }
    }
    onLoadFailed: root.fontProfile = { profile: "stock" }
  }

  property FileView themeFile: FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var out = {}
      var lines = String(text() || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        var m = lines[i].match(/^\s*([A-Za-z0-9_]+)\s*=\s*"(#[0-9a-fA-F]{6})"/)
        if (m) out[m[1]] = m[2]
      }
      root.themeColors = out
    }
  }
}
