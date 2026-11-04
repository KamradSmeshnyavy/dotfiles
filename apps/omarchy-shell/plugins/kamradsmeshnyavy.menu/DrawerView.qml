import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons

// Drawer: the DOT-MATRIX launcher's structure (DotMatrixView.qml — adapted from poligle/Nihil-Shell, MIT License,
// Copyright (c) 2026 Pol Iglesias) in the finish of a Customizer style. Same layout and keys: a drawer at
// the bottom edge, a search field, a 7-column app grid, ">" actions with a second Enter for power actions,
// "=" calculator, a hint line. Only the finish changes, chosen by the skin name drawer-<look>:
//   flat     square, solid, accent underline under the selection
//   glass    floating translucent sheet, frosted pill, soft shadow
//   fluent   floating layered card, gentle radius, accent pill under the selection
//   paper    a sheet of paper with grain and tape, handwriting, a highlighter stroke on the selection
//   neumorph floating soft slab, raised selection made of two shadows, sunken search field
//   brutal   thick ink border, hard offset shadow, the selection filled with the accent
//   retro    grey panel with a 3D bevel and a title bar, pixel font, sunken search field
//   neon     dark glass, accent border and glow, mono uppercase labels
// Colours always come from the theme.
SkinBase {
  id: root

  launchDelay: 0

  readonly property string look: ["flat", "glass", "fluent", "paper", "neumorph", "brutal", "retro", "neon"].indexOf(root.variant) >= 0
    ? root.variant : "flat"
  function pick(map) { return map[root.look] !== undefined ? map[root.look] : map["flat"] }

  // ── логика (как в DotMatrixView) ─────────────────────────────────────────
  readonly property string trimmedQuery: String(root.query || "").replace(/^\s+/, "")
  readonly property bool calcMode: trimmedQuery.indexOf("=") === 0
  readonly property bool actionsMode: trimmedQuery.indexOf(">") === 0
  readonly property string calcExpr: calcMode ? trimmedQuery.slice(1).trim() : ""
  property string calcResult: ""
  property string armedItemId: ""

  property var barSkin: ({})
  property string barPos: "top"
  readonly property bool framedBar: String(barSkin.shape || "") === "frame"
  readonly property int bezelBottom: framedBar && barPos !== "bottom" ? Math.max(1, Number(barSkin.frameWidth || 8)) : 0
  readonly property int bezelLeft: framedBar
    ? (barPos === "left" ? Math.max(24, Number(barSkin.height || 44)) : Math.max(1, Number(barSkin.frameWidth || 8))) : 0
  readonly property int bezelRight: framedBar
    ? (barPos === "right" ? Math.max(24, Number(barSkin.height || 44)) : Math.max(1, Number(barSkin.frameWidth || 8))) : 0

  readonly property real innerWidth: Math.max(360, width - bezelLeft - bezelRight)
  readonly property real centerX: bezelLeft + innerWidth / 2
  readonly property real drawerWidth: Math.min(860, innerWidth - 96)
  readonly property real targetHeight: Math.min(root.look === "retro" ? 500 : 470, height - bezelBottom - 80)

  property real openProgress: 1
  NumberAnimation {
    id: openAnim
    target: root; property: "openProgress"; from: 0; to: 1
    duration: root.look === "retro" ? 0 : (root.look === "brutal" ? 160 : 260)
    easing.type: root.look === "neumorph" || root.look === "glass" ? Easing.OutBack : Easing.OutCubic
  }
  onWoke: { armedItemId = ""; openAnim.restart() }
  onQueryChanged: { armedItemId = ""; if (calcMode) calcDebounce.restart(); else calcResult = "" }
  onSelectedIndexChanged: {
    armedItemId = ""
    if (actionsMode && actionsList.count > 0 && root.selectedIndex >= 0 && root.selectedIndex < actionsList.count)
      actionsList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    else if (!calcMode && !actionsMode && appGrid.count > 0 && root.selectedIndex >= 0 && root.selectedIndex < appGrid.count)
      appGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
  }

  function isConfirmRow(row) {
    if (!row) return false
    var id = String(row.itemId || "")
    return id === "cmd.reboot" || id === "cmd.poweroff" || id === "cmd.logout"
  }
  function triggerRow(index) {
    if (index < 0 || index >= root.count) return
    var row = root.rowAt(index)
    if (actionsMode && isConfirmRow(row)) {
      var id = String(row.itemId)
      if (armedItemId !== id) { armedItemId = id; disarmTimer.restart(); return }
      armedItemId = ""
    }
    root.activated(index)
  }
  function handleEnter() {
    if (calcMode) {
      if (calcResult !== "" && calcResult !== "ERR") {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy 2>/dev/null || true", "drawer-calc", calcResult])
        root.dismissRequested()
      }
      return true
    }
    if (actionsMode && root.cursorActive && root.selectedIndex >= 0 && root.selectedIndex < root.count) {
      if (isConfirmRow(root.rowAt(root.selectedIndex))) { triggerRow(root.selectedIndex); return true }
    }
    return false
  }
  function navigate(dx, dy) {
    if (calcMode || root.count === 0) return
    if (actionsMode) { var s = dy !== 0 ? dy : dx; if (s !== 0) root.step(s); return }
    var cols = 7, next = root.selectedIndex
    if (dx !== 0) next = Math.max(0, Math.min(root.count - 1, root.selectedIndex + dx))
    else if (dy !== 0) {
      var c = root.selectedIndex + dy * cols
      if (c >= 0 && c < root.count) next = c
      else if (dy > 0 && root.selectedIndex < root.count - 1) next = root.count - 1
      else if (dy < 0 && root.selectedIndex > 0) next = 0
    }
    root.selectRequested(next)
  }

  Timer { id: disarmTimer; interval: 3000; onTriggered: root.armedItemId = "" }
  Timer {
    id: calcDebounce
    interval: 90
    onTriggered: {
      if (!root.calcMode || root.calcExpr === "") { root.calcResult = ""; return }
      if (calcProc.running) calcProc.running = false
      calcProc.expr = root.calcExpr
      calcProc.running = true
    }
  }
  Process {
    id: calcProc
    property string expr: ""
    command: [
      "sh", "-c",
      "if command -v qalc >/dev/null 2>&1; then qalc -t \"$1\" 2>/dev/null | head -n1; else python3 -c '" +
      "import ast, math, operator, sys\n" +
      "OPS = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul, ast.Div: operator.truediv, ast.FloorDiv: operator.floordiv, ast.Mod: operator.mod, ast.Pow: operator.pow, ast.BitXor: operator.pow}\n" +
      "UOPS = {ast.UAdd: operator.pos, ast.USub: operator.neg}\n" +
      "FN = {\"sqrt\": math.sqrt, \"sin\": math.sin, \"cos\": math.cos, \"tan\": math.tan, \"log\": math.log, \"log10\": math.log10, \"exp\": math.exp, \"abs\": abs, \"round\": round, \"floor\": math.floor, \"ceil\": math.ceil}\n" +
      "CONST = {\"pi\": math.pi, \"e\": math.e, \"tau\": math.tau}\n" +
      "def ev(n):\n" +
      "  if isinstance(n, ast.Constant) and isinstance(n.value, (int, float)): return n.value\n" +
      "  if isinstance(n, ast.Name) and n.id in CONST: return CONST[n.id]\n" +
      "  if isinstance(n, ast.UnaryOp) and type(n.op) in UOPS: return UOPS[type(n.op)](ev(n.operand))\n" +
      "  if isinstance(n, ast.BinOp) and type(n.op) in OPS: return OPS[type(n.op)](ev(n.left), ev(n.right))\n" +
      "  if isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id in FN: return FN[n.func.id](*[ev(a) for a in n.args])\n" +
      "  raise ValueError\n" +
      "try:\n" +
      "  v = ev(ast.parse(sys.argv[1], mode=\"eval\").body)\n" +
      "  if isinstance(v, float) and v.is_integer(): v = int(v)\n" +
      "  elif isinstance(v, float): v = round(v, 8)\n" +
      "  print(v)\n" +
      "except Exception:\n" +
      "  print(\"\")\n" +
      "' \"$1\"; fi",
      "drawer-calc-eval", calcProc.expr
    ]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.calcResult = String(text || "").trim() }
  }
  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/bar-skin.json"
    watchChanges: true; printErrors: false
    onLoaded: { try { root.barSkin = JSON.parse(text() || "{}") || {} } catch (e) { root.barSkin = {} } }
    onLoadFailed: root.barSkin = {}
    onFileChanged: reload()
  }
  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/shell.json"
    watchChanges: true; printErrors: false
    onLoaded: {
      try { var cfg = JSON.parse(text() || "{}") || {}; root.barPos = cfg.bar && cfg.bar.position ? String(cfg.bar.position) : "top" }
      catch (e) { root.barPos = "top" }
    }
    onFileChanged: reload()
  }

  // ── отделка ──────────────────────────────────────────────────────────
  readonly property var families: Qt.fontFamilies()
  function face(name, fallback) { return families.indexOf(name) >= 0 ? name : fallback }
  function mix(a, b, t) { return root.theme ? root.theme.mix(a, b, t) : a }
  readonly property bool dark: 0.299 * root.base.r + 0.587 * root.base.g + 0.114 * root.base.b < 0.45
  readonly property color fg: root.foreground
  readonly property color acc: root.accent
  readonly property color onAcc: root.theme ? root.theme.ink(root.acc) : "#ffffff"
  readonly property color danger: root.theme ? root.theme.red : "#e05050"
  readonly property color dim: Util.alpha(root.fg, 0.78)
  readonly property color muted: Color.muted

  // Цвета — как у дашборда, меню выключения, OSD и уведомлений (BarStyle.qml в kamradsmeshnyavy.widgets):
  // фон панели — подложка бара из ~/.config/omarchy/bar-skin.json (почти прозрачный бар → фон всплывающих
  // окон), текст — foreground / muted темы, выделения и скотч — акцент. Своих оттенков у отделок нет.
  function resolve(spec, fallback) {
    var s = String(spec === undefined || spec === null ? "" : spec).trim()
    if (s === "" || s === "bar") return fallback
    if (s.charAt(0) === "#") return Qt.color(s)
    if (s === "background") return Color.background
    if (s === "foreground") return Color.foreground
    if (s === "accent") return Color.accent
    if (s === "muted") return Color.muted
    if (s === "urgent") return Color.urgent
    if (root.theme && root.theme.values && root.theme.values[s]) return Qt.color(root.theme.values[s])
    return fallback
  }
  readonly property color barFill: {
    var c = root.resolve(root.barSkin.background, Color.bar.background)
    var a = Number(root.barSkin.backgroundAlpha)
    return isFinite(a) && a >= 0 ? Qt.rgba(c.r, c.g, c.b, a) : c
  }
  readonly property bool barGlass: root.barFill.a < 0.15 || String(root.barSkin.shape || "") === "islands" || root.barSkin.transparent === true
  // Фон шторки (подложка бара без альфы).
  readonly property color base: {
    var c = root.barGlass ? Color.popups.background : root.barFill
    return Qt.rgba(c.r, c.g, c.b, 1)
  }
  // Альфа шторки — 1 у всех отделок: слой меню с альфой < 1 композитор показывает почти насквозь
  // (0.92 читается как ~0.5), и сквозь стекло читался текст окон. Стекло держится на рамке и тени.
  readonly property real baseAlpha: 1
  readonly property color surface: Util.alpha(root.fg, 0.05)
  readonly property color surfaceHi: Util.alpha(root.fg, 0.1)
  readonly property color line: root.pick({
    brutal: root.fg, neon: Util.alpha(root.acc, 0.7), paper: Util.alpha(root.fg, 0.35),
    glass: Util.alpha(root.fg, 0.18), neumorph: "transparent", flat: Util.alpha(root.fg, 0.16)
  })
  readonly property int border: root.pick({ brutal: 3, neumorph: 0, retro: 0, flat: 1 })
  readonly property bool floating: root.pick({ glass: true, fluent: true, neumorph: true, neon: true, flat: false })
  readonly property int gap: root.floating ? 18 : 0
  readonly property int radius: root.pick({ flat: 0, glass: 24, fluent: 12, paper: 4, neumorph: 28, brutal: 0, retro: 0, neon: 12 })
  readonly property int pillRadius: root.pick({ flat: 0, glass: 22, fluent: 8, paper: 0, neumorph: 22, brutal: 0, retro: 0, neon: 8 })
  readonly property int cellRadius: root.pick({ flat: 0, glass: 16, fluent: 8, paper: 2, neumorph: 18, brutal: 0, retro: 0, neon: 8 })

  readonly property string labelFont: root.pick({
    paper: root.face("Caveat", root.fontFamily), retro: root.face("Pixelify Sans", root.mono), neon: root.mono, flat: root.fontFamily
  })
  readonly property string textFont: root.pick({
    paper: root.face("Pangolin", root.face("Caveat", root.fontFamily)), retro: root.face("Pixelify Sans", root.mono),
    neon: root.mono, flat: root.fontFamily
  })
  readonly property bool upper: root.pick({ brutal: true, neon: true, retro: false, flat: false })
  readonly property int labelSize: root.pick({ paper: 19, retro: 12, brutal: 11, neon: 10, flat: 11 })
  readonly property int labelWeight: root.pick({ brutal: Font.Black, retro: Font.Normal, flat: Font.Normal })
  function cap(s) { return root.upper ? String(s).toUpperCase() : String(s) }
  readonly property string grain: Quickshell.env("HOME") + "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/textures/"
    + (root.dark ? "paper-dark.png" : "paper.png")
  // Как у дашборда: скотч — акцент 0.55 (BarStyle.tapeColor), выделение бумаги — акцент 0.2.
  readonly property color tape: Util.alpha(root.acc, 0.55)
  readonly property color marker: Util.alpha(root.acc, 0.2)
  function lift(c, k) { return Qt.rgba(c.r + (1 - c.r) * k, c.g + (1 - c.g) * k, c.b + (1 - c.b) * k, 1) }
  function shade(c, k) { return Qt.rgba(c.r * k, c.g * k, c.b * k, 1) }

  // ── фон и закрытие ───────────────────────────────────────────────────
  Rectangle {
    anchors.fill: parent
    color: root.background
    opacity: Math.max(0, Math.min(0.45, (root.backdrop - 0.5) * 0.7)) * root.openProgress
  }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) { if (mouse.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  readonly property real curHeight: Math.round(targetHeight * openProgress)
  readonly property real baseY: height - bezelBottom - root.gap
  readonly property real topY: baseY - curHeight
  readonly property real leftX: Math.round(centerX - drawerWidth / 2)

  // ── шторка ───────────────────────────────────────────────────────────
  // brutal: жёсткая тень-плашка.
  Rectangle {
    visible: root.look === "brutal" && root.curHeight > 1
    x: root.leftX + 7; y: root.topY + 7
    width: root.drawerWidth; height: root.curHeight + 7
    color: root.fg
  }
  // neumorph: светлая тень вверх-влево (тёмная — у самой шторки).
  Rectangle {
    visible: root.look === "neumorph" && root.curHeight > 1
    x: root.leftX; y: root.topY; width: root.drawerWidth; height: root.curHeight
    radius: root.radius
    color: root.base
    layer.enabled: visible
    layer.effect: MultiEffect {
      shadowEnabled: true; shadowColor: root.lift(root.base, root.dark ? 0.12 : 0.85)
      shadowOpacity: 0.9; shadowBlur: 0.8; shadowHorizontalOffset: -8; shadowVerticalOffset: -8
    }
  }
  Rectangle {
    id: panel
    x: root.leftX; y: root.topY
    width: root.drawerWidth
    height: root.curHeight + (root.floating ? 0 : root.radius)   // у прилипшей шторки нижние углы уходят за край
    radius: root.radius
    color: Util.alpha(root.base, root.baseAlpha)
    border.width: root.curHeight > 1 ? root.border : 0
    border.color: root.line
    layer.enabled: root.curHeight > 1 && root.look !== "brutal" && root.look !== "retro" && root.look !== "flat"
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: root.look === "neon" ? root.acc : (root.look === "neumorph" ? root.shade(root.base, root.dark ? 0.35 : 0.72) : "#000000")
      shadowOpacity: root.pick({ neon: 0.85, neumorph: 0.95, paper: 0.4, glass: 0.35, flat: 0.3 })
      shadowBlur: root.pick({ neon: 1.0, neumorph: 0.9, flat: 0.8 })
      shadowHorizontalOffset: root.look === "neumorph" ? 8 : 0
      shadowVerticalOffset: root.look === "neumorph" ? 8 : (root.look === "neon" ? 0 : -2)
    }
  }
  // paper: зерно и полоска скотча.
  Item {
    visible: root.look === "paper" && root.curHeight > 1
    x: panel.x + 1; y: panel.y + 1; width: panel.width - 2; height: root.curHeight - 1
    clip: true
    Image {
      anchors.fill: parent
      source: "file://" + root.grain
      fillMode: Image.Tile; horizontalAlignment: Image.AlignLeft; verticalAlignment: Image.AlignTop
      opacity: 0.85; asynchronous: true; smooth: false
    }
  }
  Rectangle {
    visible: root.look === "paper" && root.curHeight > 30
    width: 92; height: 22; x: root.centerX - width / 2; y: root.topY - 11; rotation: -2
    color: root.tape
  }
  // retro: объёмный кант (светлый сверху-слева, тёмный справа).
  Item {
    visible: root.look === "retro" && root.curHeight > 1
    x: panel.x; y: panel.y; width: panel.width; height: root.curHeight
    Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top } height: 2; color: root.lift(root.base, 0.45) }
    Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: 2; color: root.lift(root.base, 0.45) }
    Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 2; color: root.shade(root.base, 0.4) }
  }

  Item {
    id: drawerBody
    x: root.leftX; y: root.topY
    width: root.drawerWidth; height: root.curHeight
    clip: true
    opacity: Math.max(0, (root.openProgress - 0.4) / 0.6)

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: function(mouse) { if (mouse.button === Qt.RightButton) root.backRequested() }
    }

    Item {
      width: root.drawerWidth
      height: root.targetHeight

      // retro: заголовок окна цветом акцента.
      Rectangle {
        id: titleBar
        visible: root.look === "retro"
        x: 4; y: 4; width: parent.width - 8; height: visible ? 26 : 0
        color: root.acc
        Text {
          anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: (root.subtitle.length > 0 ? root.subtitle : (root.title.length > 0 ? root.title : "Programs"))
          font.family: root.labelFont; font.pixelSize: 14; font.bold: true
          color: root.onAcc
        }
        Row {
          anchors.right: parent.right; anchors.rightMargin: 4; anchors.verticalCenter: parent.verticalCenter
          spacing: 2
          Repeater {
            model: ["_", "□", "×"]
            Rectangle {
              required property string modelData
              width: 18; height: 16; color: root.base
              Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top } height: 1; color: root.lift(root.base, 0.5) }
              Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: root.shade(root.base, 0.4) }
              Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 11; font.bold: true; color: root.fg }
            }
          }
        }
      }

      // ── поиск ──
      Item {
        id: searchPill
        anchors.top: titleBar.visible ? titleBar.bottom : parent.top
        anchors.left: parent.left; anchors.right: parent.right
        anchors.topMargin: root.look === "retro" ? 12 : 24
        anchors.leftMargin: 28; anchors.rightMargin: 28
        height: 44

        // brutal: жёсткая тень поля.
        Rectangle {
          visible: root.look === "brutal"
          x: 4; y: 4; width: parent.width; height: parent.height; color: root.fg
        }
        Rectangle {
          anchors.fill: parent
          radius: root.pillRadius
          visible: root.look !== "paper"
          color: root.pick({
            glass: root.surface, neon: Util.alpha(root.acc, 0.08),
            neumorph: root.shade(root.base, root.dark ? 0.82 : 0.94), retro: root.shade(root.base, root.dark ? 0.85 : 0.96),
            brutal: root.base, flat: root.surface
          })
          border.width: root.pick({ brutal: 2, neumorph: 0, retro: 0, flat: 1 })
          border.color: root.pick({ brutal: root.fg, neon: root.acc, glass: Util.alpha(root.fg, 0.2), flat: root.line })
        }
        // retro / neumorph: вдавленное поле — тёмный кант сверху-слева, светлый снизу-справа.
        Item {
          visible: root.look === "retro"
          anchors.fill: parent
          Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top } height: 2; color: root.shade(root.base, 0.45) }
          Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: 2; color: root.shade(root.base, 0.45) }
          Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 2; color: root.lift(root.base, 0.5) }
          Rectangle { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 2; color: root.lift(root.base, 0.5) }
        }
        // paper: строка, подчёркнутая карандашом.
        Rectangle {
          visible: root.look === "paper"
          anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 4 }
          height: 1.5; color: Util.alpha(root.fg, 0.45)
        }

        Text {
          id: modeGlyph
          anchors.left: parent.left; anchors.leftMargin: root.look === "paper" ? 2 : 18
          anchors.verticalCenter: parent.verticalCenter
          text: root.calcMode ? String.fromCodePoint(0xF00EC) : (root.actionsMode ? String.fromCodePoint(0xF018D) : String.fromCodePoint(0xF0349))
          font.family: Style.font.family; font.pixelSize: 16
          color: root.query.length > 0 ? root.fg : root.muted
        }
        QueryText {
          anchors.left: modeGlyph.right; anchors.leftMargin: 12
          anchors.right: crumb.visible ? crumb.left : parent.right; anchors.rightMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          height: 30
          query: root.query
          placeholder: root.look === "paper" ? "write here to search  ·  > actions  ·  = calculate" : root.cap("Search  ·  > actions  ·  = calculate")
          color: root.fg
          placeholderColor: root.muted
          caretColor: root.acc
          fontFamily: root.look === "paper" ? root.labelFont : root.textFont
          pixelSize: root.look === "paper" ? 24 : 14
          live: root.live
        }
        Text {
          id: crumb
          visible: root.subtitle.length > 0 && root.query.length === 0 && root.look !== "retro"
          anchors.right: parent.right; anchors.rightMargin: 18; anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: root.cap(root.subtitle)
          font.family: root.labelFont; font.pixelSize: root.look === "paper" ? 20 : 11
          color: root.muted
        }
      }

      // ── сетка ──
      GridView {
        id: appGrid
        visible: !root.calcMode && !root.actionsMode
        anchors.top: searchPill.bottom; anchors.bottom: footerText.top
        anchors.left: parent.left; anchors.right: parent.right
        anchors.topMargin: 16; anchors.bottomMargin: 12; anchors.leftMargin: 24; anchors.rightMargin: 24
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: Math.floor(width / 7)
        cellHeight: root.look === "paper" ? 110 : 104
        model: root.rowModel

        delegate: Item {
          id: cell
          required property int index
          required property string kind
          required property string icon
          required property string iconFont
          required property string appIcon
          required property string label

          readonly property bool selected: root.cursorActive && cell.index === root.selectedIndex
          readonly property bool hot: cell.selected || cellArea.containsMouse
          readonly property bool nearViewport: Math.abs(cell.index - root.selectedIndex) < 42
          width: appGrid.cellWidth
          height: appGrid.cellHeight

          // brutal: тень выбранной.
          Rectangle {
            visible: cell.selected && root.look === "brutal"
            x: 8; y: 8; width: parent.width - 8; height: parent.height - 8
            color: root.fg
          }
          Rectangle {
            id: plate
            anchors.fill: parent
            anchors.margins: 4
            radius: root.cellRadius
            rotation: cell.selected && root.look === "paper" ? -1.5 : 0
            color: cell.selected ? root.pick({
                flat: Util.alpha(root.acc, 0.16), glass: Util.alpha(root.fg, 0.1), fluent: root.surfaceHi,
                paper: root.marker, neumorph: root.base, brutal: root.acc, retro: root.acc, neon: Util.alpha(root.acc, 0.12)
              })
              : (cellArea.containsMouse ? Util.alpha(root.fg, 0.06) : "transparent")
            border.width: cell.selected ? root.pick({ glass: 1, brutal: 2, neon: 1, flat: 0 }) : 0
            border.color: root.pick({ glass: Util.alpha(root.fg, 0.25), brutal: root.fg, neon: root.acc, flat: "transparent" })
            layer.enabled: cell.selected && (root.look === "neumorph" || root.look === "neon")
            layer.effect: MultiEffect {
              shadowEnabled: true
              shadowColor: root.look === "neon" ? root.acc : root.shade(root.base, root.dark ? 0.35 : 0.72)
              shadowOpacity: 0.9
              shadowBlur: root.look === "neon" ? 0.9 : 0.6
              shadowHorizontalOffset: root.look === "neumorph" ? 4 : 0
              shadowVerticalOffset: root.look === "neumorph" ? 4 : 0
            }
          }
          // flat / fluent: полоска акцента под выбранной.
          Rectangle {
            visible: cell.selected && (root.look === "flat" || root.look === "fluent")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom; anchors.bottomMargin: 4
            width: root.look === "flat" ? parent.width - 8 : 22
            height: 3; radius: root.look === "fluent" ? 1.5 : 0
            color: root.acc
          }

          Item {
            id: iconBox
            anchors.horizontalCenter: parent.horizontalCenter
            y: 16; width: 44; height: 44
            RowIcon {
              anchors.fill: parent
              size: 44
              kind: cell.kind
              glyph: cell.icon
              glyphFont: cell.iconFont
              appIcon: cell.appIcon
              resolver: root.iconResolver
              fontFamily: root.fontFamily
              load: cell.nearViewport || root.count <= 56
              fallback: cell.label.length > 0 ? cell.label.charAt(0).toUpperCase() : "•"
              color: cell.selected && (root.look === "brutal" || root.look === "retro") ? root.onAcc : (cell.hot ? root.fg : root.dim)
            }
          }
          Text {
            anchors.top: iconBox.bottom; anchors.topMargin: root.look === "paper" ? 4 : 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 14
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: root.cap(cell.label)
            font.family: root.labelFont
            font.pixelSize: root.labelSize
            font.weight: cell.selected ? Math.max(root.labelWeight, Font.Bold) : root.labelWeight
            font.letterSpacing: root.upper ? 0.8 : 0
            color: cell.selected && (root.look === "brutal" || root.look === "retro") ? root.onAcc
              : (cell.selected ? (root.look === "neon" ? root.acc : root.fg) : root.muted)
          }
          MouseArea {
            id: cellArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
            onPositionChanged: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
            onClicked: root.activated(cell.index)
          }
        }
      }

      Text {
        visible: !root.calcMode && root.count === 0
        anchors.centerIn: appGrid
        textFormat: Text.PlainText
        text: root.cap(root.emptyText())
        font.family: root.labelFont; font.pixelSize: root.look === "paper" ? 26 : 12
        color: root.muted
      }

      // ── «>» действия ──
      ListView {
        id: actionsList
        visible: root.actionsMode
        anchors.top: searchPill.bottom; anchors.bottom: footerText.top
        anchors.left: parent.left; anchors.right: parent.right
        anchors.topMargin: 14; anchors.bottomMargin: 12; anchors.leftMargin: 28; anchors.rightMargin: 28
        clip: true
        spacing: 3
        boundsBehavior: Flickable.StopAtBounds
        model: root.rowModel

        delegate: Rectangle {
          id: actRow
          required property int index
          required property string itemId
          required property string icon
          required property string label
          required property string detail
          readonly property bool selected: root.cursorActive && actRow.index === root.selectedIndex
          readonly property bool isArmed: root.armedItemId !== "" && root.armedItemId === actRow.itemId
          readonly property bool isDanger: actRow.itemId === "cmd.poweroff"

          width: actionsList.width
          height: 44
          radius: Math.min(root.cellRadius, 14)
          color: isArmed ? root.danger : (selected ? (root.look === "paper" ? root.marker : (root.look === "brutal" || root.look === "retro" ? root.acc : root.surfaceHi))
            : (actArea.containsMouse ? root.surface : "transparent"))
          border.width: selected && !isArmed ? root.pick({ brutal: 2, neon: 1, glass: 1, flat: 0 }) : 0
          border.color: root.pick({ brutal: root.fg, neon: root.acc, glass: Util.alpha(root.fg, 0.25), flat: "transparent" })
          readonly property color ink: actRow.isArmed ? root.theme.ink(root.danger)
            : (actRow.selected && (root.look === "brutal" || root.look === "retro") ? root.onAcc : (actRow.selected ? root.fg : root.dim))

          Text {
            id: actGlyph
            anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: actRow.icon
            font.family: Style.font.family; font.pixelSize: 16
            color: actRow.isDanger && !actRow.isArmed ? root.danger : actRow.ink
          }
          Text {
            anchors.left: actGlyph.right; anchors.leftMargin: 14
            anchors.right: actHint.left; anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: root.cap(actRow.label)
            font.family: root.look === "paper" ? root.labelFont : root.textFont
            font.pixelSize: root.look === "paper" ? 22 : 14
            font.weight: actRow.selected ? Font.Medium : Font.Normal
            color: actRow.ink
          }
          Text {
            id: actHint
            anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.cap(actRow.isArmed ? "Enter again" : actRow.detail)
            font.family: root.labelFont; font.pixelSize: root.look === "paper" ? 18 : 10
            color: actRow.isArmed ? actRow.ink : root.muted
          }
          MouseArea {
            id: actArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverSelect(actRow.index, mapToItem(root, mouseX, mouseY))
            onPositionChanged: root.hoverSelect(actRow.index, mapToItem(root, mouseX, mouseY))
            onClicked: root.triggerRow(actRow.index)
          }
        }
      }

      // ── «=» калькулятор ──
      Column {
        visible: root.calcMode
        anchors.centerIn: appGrid
        spacing: 14
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          textFormat: Text.PlainText
          text: root.cap(root.calcExpr.length > 0 ? root.calcExpr : "Type an expression")
          font.family: root.labelFont; font.pixelSize: root.look === "paper" ? 22 : 12
          color: root.muted
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          width: Math.min(implicitWidth, root.drawerWidth - 80)
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.calcResult !== "" ? root.calcResult : "0"
          font.family: root.look === "paper" || root.look === "retro" ? root.labelFont : (root.look === "neon" ? root.mono : root.fontFamily)
          font.weight: root.look === "brutal" ? Font.Black : Font.Light
          font.pixelSize: root.look === "paper" ? 72 : 56
          color: root.calcResult !== "" ? (root.look === "neon" ? root.acc : root.fg) : root.muted
        }
      }

      Text {
        id: footerText
        anchors.bottom: parent.bottom; anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.cap(root.calcMode ? "Enter copy result  ·  Esc close"
          : (root.actionsMode ? "↑↓ select  ·  Enter run  ·  Esc close"
             : "Arrows move  ·  Enter open  ·  > actions  ·  = calc  ·  Esc close"))
        font.family: root.labelFont
        font.pixelSize: root.look === "paper" ? 18 : 10
        font.letterSpacing: root.upper ? 1.4 : 0.3
        color: root.muted
      }
    }
  }
}
