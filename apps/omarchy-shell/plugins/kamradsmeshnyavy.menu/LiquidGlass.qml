import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Жидкое стекло под панелью (shaders/liquidglass.frag; идея — стекло Vitreus, MIT, код свой). Quickshell не видит, что под
// слоем, но обои известны: стекло рисует их само, с линзой у края, радужной каймой, матовостью и бликом под курсором.
// Где за панелью окно (или обои живые — видео рисует owe), преломлять нечего — стекло становится тонированной плёнкой,
// а размывает Hyprland (layer_rule blur в apps/hyprland/windows.lua).
//
// screenOrigin — левый верхний угол этого элемента на экране в логических px. Окно слоя не знает своего места на экране,
// его считает панель (по своим якорям и отступам); не задан — стекло всегда плёнка.
// Настройки — ~/.config/omarchy/glass.json (их пишет Customizer → Стекло): refraction, dispersion, frost, lens, rim,
// dome, tint (0…1 — сколько цвета панели), overWindows (film — плёнка над окнами, glass — преломлять обои всегда).
Item {
  id: glass

  property point screenOrigin: Qt.point(NaN, NaN)
  // Или имя слоя окна (WlrLayershell.namespace): место окна на экране стекло спросит у Hyprland (hyprctl layers),
  // своё место в окне — каждый кадр, пока видно (панели двигаются при открытии).
  property string layerNamespace: ""
  property point layerPos: Qt.point(NaN, NaN)
  property point mapped: Qt.point(0, 0)
  readonly property point origin: !isNaN(screenOrigin.x) ? screenOrigin
    : !isNaN(layerPos.x) ? Qt.point(layerPos.x + mapped.x, layerPos.y + mapped.y) : Qt.point(NaN, NaN)
  property real radius: 22
  property color tintColor: "#202020"
  property real tintAlpha: cfg.tint
  // На время анимаций (морф из бара) панель может попросить плёнку, чтобы не пересчитывать перекрытие.
  property bool forceFilm: false
  // слой ниже окон (виджеты рабочего стола): окна над стеклом, а не под ним — обои под ним видны всегда
  property bool belowWindows: false
  // Перешеек (как у Vitreus — панель одним куском стекла с баром): вторая фигура joinRect в координатах этого элемента
  // (обычно пилюля бара), joinK — ширина слияния. Стекло рисуется с запасом bleed вокруг элемента — там и тянется перешеек.
  property rect joinRect: Qt.rect(0, 0, 0, 0)
  property real joinRadius: 16
  property real joinK: 0
  property real bleed: 0
  // ещё две фигуры в координатах элемента (крылья у рамки, куски вырезов бара) и рамка вокруг поля стекла:
  // frameHole — «дырка» (рабочая область) со скруглением frameHoleRadius, frameK — слияние рамки с фигурами
  property rect join2Rect: Qt.rect(0, 0, 0, 0)
  property real join2Radius: 16
  property real join2K: 0
  property rect join3Rect: Qt.rect(0, 0, 0, 0)
  property real join3Radius: 16
  property real join3K: 0
  property bool frameOn: false
  property rect frameHole: Qt.rect(0, 0, 0, 0)
  property real frameHoleRadius: 24
  property real frameK: 0
  // где стекло не рисовать (в координатах элемента): внутренность бара и рамки — у них своё стекло, панель к ним только
  // тянется перешейком; без выреза кусок бара под перешейком светлее остального (стекло вдвое)
  property rect cutRect: Qt.rect(0, 0, 0, 0)
  property rect cut2Rect: Qt.rect(0, 0, 0, 0)
  // рябь по краю (DripMotion → бар): rippleAt — откуда, в координатах элемента; rippleT 0…1 — время; rippleAmp — сила, px
  property point rippleAt: Qt.point(0, 0)
  property real rippleT: 0
  property real rippleAmp: 0
  // главная фигура; по умолчанию — весь элемент
  property rect panelRect: Qt.rect(0, 0, width, height)
  property bool active: visible
  // окно панели прячется целиком, а элемент остаётся visible — смотреть и на окно
  readonly property bool live: active && Window.visibility !== Window.Hidden

  readonly property bool placed: !isNaN(origin.x) && !isNaN(origin.y)

  Process {
    id: readLayer
    command: ["hyprctl", "layers", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var d = JSON.parse(text), mons = {}
          var m = Hyprland.monitors.values
          for (var i = 0; i < m.length; i++) if (m[i].lastIpcObject) mons[m[i].name] = m[i].lastIpcObject
          for (var mon in d) {
            var lv = d[mon].levels
            for (var k in lv) for (var j = 0; j < lv[k].length; j++) {
              var l = lv[k][j]
              if (l.namespace !== glass.layerNamespace) continue
              var mo = mons[mon] || { x: 0, y: 0 }
              glass.layerPos = Qt.point(l.x - (mo.x || 0), l.y - (mo.y || 0))
              return
            }
          }
        } catch (e) {}
      }
    }
  }
  FrameAnimation {
    running: glass.live && glass.layerNamespace !== ""
    onTriggered: {
      var p = glass.mapToItem(null, 0, 0)
      if (p.x !== glass.mapped.x || p.y !== glass.mapped.y) glass.mapped = p
    }
  }

  // ── настройки ─────────────────────────────────────────────────────
  QtObject {
    id: cfg
    property real refraction: 0.55
    property real dispersion: 0.2
    property real frost: 0.15
    property real lens: 18
    property real rim: 0.8
    property real dome: 0.8
    property real tint: 0.28
    property string overWindows: "film"
  }
  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/glass.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var v = JSON.parse(text())
        function num(k, d, lo, hi) { var x = Number(v[k]); return isFinite(x) ? Math.max(lo, Math.min(hi, x)) : d }
        cfg.refraction = num("refraction", 0.55, 0, 1)
        cfg.dispersion = num("dispersion", 0.2, 0, 1)
        cfg.frost = num("frost", 0.15, 0, 1)
        cfg.lens = num("lens", 18, 2, 60)
        cfg.rim = num("rim", 0.8, 0, 1)
        cfg.dome = num("dome", 0.8, 0, 1)
        cfg.tint = num("tint", 0.28, 0, 1)
        cfg.overWindows = String(v.overWindows || "film")
      } catch (e) {}
    }
  }

  // ── обои: путь из current/background, перечитывается при показе ─────
  property string wallPath: ""
  readonly property bool liveWall: /\.(mp4|m4v|mov|webm|mkv|avi|gif)$/i.test(wallPath)
  Process {
    id: readWall
    command: ["readlink", "-f", Quickshell.env("HOME") + "/.local/state/omarchy/current/background"]
    stdout: StdioCollector { onStreamFinished: glass.wallPath = String(text || "").trim() }
  }
  onLiveChanged: if (live) { readWall.running = true; Hyprland.refreshToplevels(); layerProbe.restart() }
  // обои могут смениться, пока панель открыта
  Timer { interval: 3000; running: glass.live; repeat: true; onTriggered: if (!readWall.running) readWall.running = true }
  Component.onCompleted: { readWall.running = true; layerProbe.restart() }
  // слой появляется у Hyprland с первым кадром окна — спросить чуть позже
  Timer { id: layerProbe; interval: 120; onTriggered: if (glass.layerNamespace !== "" && !readLayer.running) readLayer.running = true }
  function url(p) { return p ? "file://" + p.split("/").map(encodeURIComponent).join("/") : "" }

  readonly property size screenSize: Qt.size(Screen.width, Screen.height)
  // Источники текстур — соседи эффекта с opacity 0 (невидимому Image сцена текстуру не обновляет).
  Image {
    id: sharp
    opacity: 0
    width: 1; height: 1
    asynchronous: true
    cache: true
    source: !glass.liveWall ? glass.url(glass.wallPath) : ""
    sourceSize: Qt.size(glass.screenSize.width, glass.screenSize.height)
  }
  Image {
    id: soft
    opacity: 0
    width: 1; height: 1
    asynchronous: true
    cache: true
    smooth: true
    source: sharp.source
    sourceSize: Qt.size(Math.max(16, glass.screenSize.width / 24), Math.max(10, glass.screenSize.height / 24))
  }
  readonly property bool wallReady: sharp.status === Image.Ready && soft.status === Image.Ready

  // ── окна под панелью ──────────────────────────────────────────────
  property int tick: 0
  Timer { interval: 900; running: glass.live && glass.placed; repeat: true; onTriggered: { Hyprland.refreshToplevels(); glass.tick++ } }
  readonly property bool overWindow: {
    tick
    if (!placed) return true
    var ws = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.activeWorkspace : null
    if (!ws) return false
    var x0 = origin.x, y0 = origin.y, x1 = x0 + width, y1 = y0 + height
    var mon = Hyprland.focusedMonitor
    var mx = mon && mon.lastIpcObject ? (mon.lastIpcObject.x || 0) : 0
    var my = mon && mon.lastIpcObject ? (mon.lastIpcObject.y || 0) : 0
    var tl = ws.toplevels.values
    for (var i = 0; i < tl.length; i++) {
      var o = tl[i].lastIpcObject
      if (!o || !o.at || !o.size || o.hidden) continue
      var wx = o.at[0] - mx, wy = o.at[1] - my
      if (wx < x1 && wx + o.size[0] > x0 && wy < y1 && wy + o.size[1] > y0) return true
    }
    return false
  }
  readonly property real film: forceFilm || !placed || liveWall || !wallReady || (cfg.overWindows !== "glass" && !belowWindows && overWindow) ? 1 : 0
  property real filmAnim: film
  Behavior on filmAnim { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

  // ── блик под курсором ─────────────────────────────────────────────
  HoverHandler { id: hov }
  property real shineOn: hov.hovered ? 1 : 0
  Behavior on shineOn { NumberAnimation { duration: 300 } }

  function crop() {
    var iw = Math.max(1, sharp.implicitWidth), ih = Math.max(1, sharp.implicitHeight)
    var ia = iw / ih, sa = screenSize.width / Math.max(1, screenSize.height)
    return ia > sa ? Qt.size(sa / ia, 1) : Qt.size(1, ia / sa)
  }

  ShaderEffect {
    anchors.fill: parent
    anchors.margins: -glass.bleed
    readonly property vector4d panel: Qt.vector4d(glass.panelRect.x + glass.bleed, glass.panelRect.y + glass.bleed, glass.panelRect.width, glass.panelRect.height)
    readonly property vector4d join2: Qt.vector4d(glass.join2Rect.x + glass.bleed, glass.join2Rect.y + glass.bleed, glass.join2Rect.width, glass.join2Rect.height)
    readonly property vector4d join3: Qt.vector4d(glass.join3Rect.x + glass.bleed, glass.join3Rect.y + glass.bleed, glass.join3Rect.width, glass.join3Rect.height)
    readonly property vector4d joinRK: Qt.vector4d(glass.join2Radius, glass.join3Radius, glass.join2K, glass.join3K)
    readonly property vector4d hole: Qt.vector4d(glass.frameHole.x + glass.bleed, glass.frameHole.y + glass.bleed, glass.frameHole.width, glass.frameHole.height)
    readonly property vector4d frame: Qt.vector4d(glass.frameOn ? 1 : 0, glass.frameHoleRadius, glass.frameK, 0)
    readonly property vector4d join: Qt.vector4d(glass.joinRect.x + glass.bleed, glass.joinRect.y + glass.bleed, glass.joinRect.width, glass.joinRect.height)
    readonly property vector4d cut: Qt.vector4d(glass.cutRect.x + glass.bleed, glass.cutRect.y + glass.bleed, glass.cutRect.width, glass.cutRect.height)
    readonly property vector4d cut2: Qt.vector4d(glass.cut2Rect.x + glass.bleed, glass.cut2Rect.y + glass.bleed, glass.cut2Rect.width, glass.cut2Rect.height)
    readonly property vector4d ripple: Qt.vector4d(glass.rippleAt.x + glass.bleed, glass.rippleAt.y + glass.bleed, glass.rippleT, glass.rippleAmp)
    readonly property real joinR: glass.joinRadius
    readonly property real joinK: glass.joinK
    property var sharpTex: sharp
    property var softTex: soft
    readonly property size size: Qt.size(width, height)
    readonly property size screen: glass.screenSize
    readonly property point origin: glass.placed ? Qt.point(glass.origin.x - glass.bleed, glass.origin.y - glass.bleed) : Qt.point(0, 0)
    readonly property size crop: glass.crop()
    readonly property color tint: Qt.rgba(glass.tintColor.r, glass.tintColor.g, glass.tintColor.b, glass.tintAlpha)
    readonly property vector4d shine: Qt.vector4d(hov.point.position.x + glass.bleed, hov.point.position.y + glass.bleed, 1, glass.shineOn)
    readonly property real radius: glass.radius
    readonly property real lens: cfg.lens
    readonly property real refr: cfg.refraction
    readonly property real disp: cfg.dispersion
    readonly property real frost: cfg.frost
    readonly property real rim: cfg.rim
    readonly property real dome: cfg.dome
    readonly property real over: glass.filmAnim
    readonly property real alphaOver: Math.max(0.3, glass.tintAlpha + 0.18)
    fragmentShader: Qt.resolvedUrl("shaders/liquidglass.frag.qsb")
  }
}
