import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateHome: home + "/.local/state"
  readonly property string currentBackgroundLink: stateHome + "/omarchy/current/background"

  property string currentBackground: ""
  property string displayedBackground: ""
  property string incomingBackground: ""
  property string oldBackground: ""
  property bool finishingTransition: false
  property int backgroundVersion: 0
  property int revealStartedVersion: -1
  property int pendingThemeVersion: -1
  property string pendingColorsRaw: ""
  property string pendingShellRaw: ""
  property real revealProgress: 1

  // fx: переход из ~/.config/omarchy/wallpaper-transition.json (TransitionEffect.qml).
  //   type      none | random | одно из TransitionEffect.modes (по умолчанию slant — как в стоке)
  //   duration  мс, easing — имя кривой (InOutCubic, OutExpo, …)
  //   angle     градусы для wipe / wave / slide, origin — center | cursor | random
  //   softness  ширина мягкого края (доля экрана)
  property var fxConfig: ({})
  readonly property string fxType: String(fxConfig.type || "slant")
  readonly property int fxDuration: Math.max(80, Math.min(5000, Number(fxConfig.duration) || 420))
  readonly property string fxEasing: String(fxConfig.easing || "InOutCubic")
  readonly property real fxAngle: Number(fxConfig.angle !== undefined ? fxConfig.angle : 0)
  readonly property real fxSoftness: Number(fxConfig.softness !== undefined ? fxConfig.softness : 0.02)
  readonly property string fxOrigin: String(fxConfig.origin || "center")
  // Что играет текущий переход (random разрешается в конкретный эффект на старте).
  property string fxActive: "slant"
  property real fxSeed: 0
  property point fxRandomOrigin: Qt.point(0.5, 0.5)
  property var fxCursor: null
  readonly property var fxEffects: ["slant", "fade", "wipe", "wave", "grow", "outer", "diamond", "clock",
    "blinds", "doors", "mosaic", "dissolve", "pixelize", "ripple", "swirl", "crosszoom", "slide", "zoom",
    "glitch", "burn", "waterdrop", "hexagon"]

  function fxEasingType(name) {
    var map = {
      "Linear": Easing.Linear, "InOutQuad": Easing.InOutQuad, "InOutCubic": Easing.InOutCubic,
      "InOutQuart": Easing.InOutQuart, "InOutSine": Easing.InOutSine, "InOutExpo": Easing.InOutExpo,
      "OutCubic": Easing.OutCubic, "OutExpo": Easing.OutExpo, "OutQuint": Easing.OutQuint,
      "OutBack": Easing.OutBack, "OutBounce": Easing.OutBounce, "OutElastic": Easing.OutElastic,
      "InCubic": Easing.InCubic, "InExpo": Easing.InExpo
    }
    return map[name] !== undefined ? map[name] : Easing.InOutCubic
  }

  // Подготовить эффект к очередному переходу.
  function fxPrepare() {
    fxActive = fxType === "random" ? fxEffects[Math.floor(Math.random() * fxEffects.length)] : fxType
    fxSeed = Math.random()
    fxRandomOrigin = Qt.point(0.15 + Math.random() * 0.7, 0.15 + Math.random() * 0.7)
    if (fxOrigin === "cursor" && !cursorProc.running) cursorProc.running = true
  }

  FileView {
    path: root.home + "/.config/omarchy/wallpaper-transition.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var v = JSON.parse(text())
        root.fxConfig = v && typeof v === "object" ? v : ({})
      } catch (e) {
        console.warn("wallpaper-transition.json: " + e)
      }
    }
    onLoadFailed: root.fxConfig = ({})
  }

  Process {
    id: cursorProc
    command: ["hyprctl", "cursorpos", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.fxCursor = JSON.parse(text) } catch (e) { root.fxCursor = null }
      }
    }
  }

  // fx: replay — показать следующие обои темы и снова открыть текущие эффектом.
  Process {
    id: replayProc
    property string current: ""
    command: ["bash", "-c", "cur=$(readlink -f \"$1\"); dir=$(dirname \"$cur\"); " +
      "find -L \"$dir\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) " +
      "| sort | grep -vxF \"$cur\" | head -n 1; echo \"$cur\"", "_", root.currentBackgroundLink]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = String(text || "").trim().split("\n")
        var cur = lines[lines.length - 1]
        var other = lines.length > 1 ? lines[0] : cur
        if (!cur) return
        // Сначала мгновенно поставить соседние обои, потом обычный переход к текущим:
        // так incomingBackground и кадр base меняются и цепочка reveal отрабатывает как
        // при настоящей смене (переход «в те же обои» застревал на старом кадре).
        root.setBackground(other, true)
        Qt.callLater(function() { root.transitionBackground("", cur, cur, false, true) })
      }
    }
  }

  function imageUrl(path) {
    return Util.fileUrl(path)
  }

  function refreshBackground() {
    if (!readlinkProc.running) readlinkProc.running = true
  }

  function setBackground(path, instant) {
    transitionBackground("", path, path, instant, false)
  }

  function transitionBackground(fromPath, path, finalPath, instant, force) {
    path = String(path || "").trim()
    finalPath = String(finalPath || path).trim()
    fromPath = String(fromPath || "").trim()
    if (!path || (!force && finalPath === currentBackground)) return
    currentBackground = finalPath
    backgroundVersion += 1
    revealStartedVersion = -1

    revealAnimation.stop()
    finishingTransition = false
    // fx: эффект выбирается на каждый переход; none — без анимации.
    fxPrepare()

    if (instant || !displayedBackground || fxType === "none") {
      oldBackground = ""
      incomingBackground = ""
      displayedBackground = path
      revealProgress = 1
      return
    }

    oldBackground = fromPath || displayedBackground
    incomingBackground = path
    revealProgress = 0
  }

  function setPendingTheme(colorsB64, shellB64) {
    pendingColorsRaw = Util.decodeBase64(colorsB64)
    pendingShellRaw = Util.decodeBase64(shellB64)
    pendingThemeVersion = backgroundVersion
    pendingThemeFallbackTimer.restart()
  }

  function applyPendingTheme() {
    // Background polling can advance backgroundVersion while a theme switch is
    // pending; the latest theme payload should still apply.
    if (pendingThemeVersion < 0) return
    pendingThemeFallbackTimer.stop()
    Commons.Color.loadColors(pendingColorsRaw)
    // Commons.Color.loadShell also refreshes Style so the type scale flips with the
    // background reveal instead of waiting for a separate reload path.
    Commons.Color.loadShell(pendingShellRaw)
    Style.scheduleRefresh()
    pendingThemeVersion = -1
    pendingColorsRaw = ""
    pendingShellRaw = ""
  }

  function transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64) {
    transitionBackground(fromPath, path, finalPath, false, true)
    setPendingTheme(colorsB64, shellB64)
    if (!incomingBackground || revealProgress >= 1) applyPendingTheme()
  }

  function startReveal(panel) {
    if (!incomingBackground) return
    panel.maskReady = true
    if (revealStartedVersion === backgroundVersion) return
    revealStartedVersion = backgroundVersion
    applyPendingTheme()
    revealAnimation.restart()
  }

  function openSelector() {
    if (!bgSwitchProc.running) bgSwitchProc.running = true
  }

  function openThemeSwitcher() {
    if (!themeSwitchProc.running) themeSwitchProc.running = true
  }

  Process {
    id: bgSwitchProc
    command: ["bash", "-c", "background=$(omarchy-theme-bg-switcher); [[ -n $background ]] && omarchy-theme-bg-set \"$background\""]
    onExited: root.refreshBackground()
  }

  Process {
    id: themeSwitchProc
    command: ["bash", "-c", "theme=$(omarchy-theme-switcher); [[ -n $theme ]] && omarchy-theme-set \"$theme\" >/dev/null 2>&1 &"]
    onExited: root.refreshBackground()
  }

  Process {
    id: readlinkProc
    command: ["readlink", "-f", root.currentBackgroundLink]
    stdout: StdioCollector {
      onStreamFinished: root.setBackground(String(text || "").trim(), false)
    }
  }

  IpcHandler {
    target: "background"

    function refresh(): void {
      root.refreshBackground()
    }

    function set(path: string): void {
      root.setBackground(path, false)
    }

    function setInstant(path: string): void {
      root.setBackground(path, true)
    }

    function transition(fromPath: string, path: string): void {
      root.transitionBackground(fromPath, path, path, false, false)
    }

    function themeTransition(fromPath: string, path: string, finalPath: string, colorsB64: string, shellB64: string): void {
      root.transitionBackgroundWithTheme(fromPath, path, finalPath, colorsB64, shellB64)
    }

    // fx: проиграть текущий эффект ещё раз (для превью в Customizer).
    function replay(): void {
      if (!replayProc.running) replayProc.running = true
    }
  }

  Timer {
    id: pendingThemeFallbackTimer
    interval: 300
    repeat: false
    onTriggered: root.applyPendingTheme()
  }

  NumberAnimation {
    id: revealAnimation
    target: root
    property: "revealProgress"
    from: 0
    to: 1
    // fx: длительность и кривая из wallpaper-transition.json.
    duration: root.fxDuration
    easing.type: root.fxEasingType(root.fxEasing)
    onFinished: {
      if (root.incomingBackground) {
        root.displayedBackground = root.currentBackground || root.incomingBackground
        root.finishingTransition = true
      }
      root.revealProgress = 1
    }
  }

  Component.onCompleted: refreshBackground()

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      visible: !remapGuard.remapping
      anchors { top: true; bottom: true; left: true; right: true }

      ScreenMoveRemap {
        id: remapGuard
        window: panel
      }
      color: "transparent"
      // Keep render updates enabled. The background layer has been observed to
      // lose its committed buffer while parked with updatesEnabled=false,
      // leaving a black desktop until omarchy-shell is restarted. The wallpaper
      // itself is static, so this favors correctness over a small render-loop
      // optimization.
      updatesEnabled: true

      property bool maskReady: false

      function maybeStartReveal() {
        if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
        if (incomingFrame.status !== Image.Ready) return
        Qt.callLater(function() {
          if (!root.incomingBackground || root.revealProgress !== 0 || maskReady) return
          if (incomingFrame.status !== Image.Ready) return
          root.startReveal(panel)
        })
      }

      WlrLayershell.namespace: "omarchy-background"
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore

      Image {
        id: base
        anchors.fill: parent
        source: root.imageUrl(root.displayedBackground)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        onStatusChanged: {
          if (status === Image.Ready && root.finishingTransition) {
            root.incomingBackground = ""
            root.oldBackground = ""
            root.finishingTransition = false
          }
        }
      }

      Image {
        id: oldFrame
        anchors.fill: parent
        source: root.imageUrl(root.oldBackground)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
        visible: root.oldBackground !== "" && root.revealProgress < 1
        onStatusChanged: panel.maybeStartReveal()
      }

      Item {
        id: incomingLayer
        anchors.fill: parent
        visible: root.incomingBackground !== "" && incomingFrame.status === Image.Ready && (root.revealProgress >= 1 || panel.maskReady)
        // fx: маску-шторку заменил TransitionEffect ниже (slant рисует шейдер).
        layer.enabled: false
        layer.smooth: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: revealMask
          maskThresholdMin: 0.5
          maskSpreadAtMin: 0.02
        }

        Image {
          id: incomingFrame
          anchors.fill: parent
          source: root.imageUrl(root.incomingBackground)
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          cache: false
          smooth: true
          mipmap: true
          onStatusChanged: panel.maybeStartReveal()
        }
      }

      Item {
        id: revealMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        readonly property real slant: -0.18
        readonly property real centerTop: width / 2 - slant * height / 2
        readonly property real centerBottom: width / 2 + slant * height / 2
        readonly property real reach: width / 2 + Math.abs(slant) * height / 2 + 4
        readonly property real spread: reach * root.revealProgress

        Shape {
          anchors.fill: parent
          antialiasing: true
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            fillColor: "white"
            strokeColor: "transparent"
            startX: revealMask.centerTop - revealMask.spread; startY: 0
            PathLine { x: revealMask.centerTop + revealMask.spread; y: 0 }
            PathLine { x: revealMask.centerBottom + revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerBottom - revealMask.spread; y: revealMask.height }
            PathLine { x: revealMask.centerTop - revealMask.spread; y: 0 }
          }
        }
      }

      // fx: переход — шейдер поверх старого и нового кадра.
      TransitionEffect {
        anchors.fill: parent
        visible: root.incomingBackground !== "" && panel.maskReady && root.revealProgress < 1
          && incomingFrame.status === Image.Ready
        fromItem: oldFrame
        toItem: incomingFrame
        progress: root.revealProgress
        effect: root.fxActive
        angleDegrees: root.fxAngle
        softness: root.fxSoftness
        seed: root.fxSeed
        origin: {
          if (root.fxOrigin === "random") return root.fxRandomOrigin
          var c = root.fxCursor
          var sc = panel.modelData
          if (root.fxOrigin === "cursor" && c && sc && sc.width > 0)
            return Qt.point(Math.max(0, Math.min(1, (c.x - sc.x) / sc.width)), Math.max(0, Math.min(1, (c.y - sc.y) / sc.height)))
          return Qt.point(0.5, 0.5)
        }
      }

      Connections {
        target: root
        function onIncomingBackgroundChanged() {
          panel.maskReady = false
          panel.maybeStartReveal()
        }
      }

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onDoubleClicked: function(mouse) {
          if (mouse.button === Qt.RightButton) root.openThemeSwitcher()
          else root.openSelector()
          mouse.accepted = true
        }
      }
    }
  }
}
