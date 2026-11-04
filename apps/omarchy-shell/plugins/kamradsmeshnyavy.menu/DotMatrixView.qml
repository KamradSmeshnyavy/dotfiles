import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Commons
import "dotmatrix" as DotMatrix

// DOT-MATRIX bottom hardware drawer launcher (adapted from poligle/Nihil-Shell, MIT License,
// Copyright (c) 2026 Pol Iglesias):
//   - Bump in the DOT-MATRIX background colour growing out of the bottom bezel with 14px concave fillets
//   - 7-column desaturated monochrome app grid (regains colour on selection/hover)
//   - ">" command list with 2-click red (theme urgent) confirmation for destructive power actions
//   - "=" calculator in 56px Doto Bold LED digits (Enter copies via wl-copy)
SkinBase {
  id: root

  launchDelay: 0

  readonly property string trimmedQuery: String(root.query || "").replace(/^\s+/, "")
  readonly property bool calcMode: trimmedQuery.indexOf("=") === 0
  readonly property bool actionsMode: trimmedQuery.indexOf(">") === 0
  readonly property string calcExpr: calcMode ? trimmedQuery.slice(1).trim() : ""

  property string calcResult: ""
  property string armedItemId: ""

  // Read bar-skin.json + shell.json so the drawer centers inside the frame workspace
  // and joins ScreenBorder's bottom hairline seamlessly when shape === "frame".
  property var barSkin: ({})
  property string barPos: "top"

  readonly property bool framedBar: String(barSkin.shape || "") === "frame"
  readonly property int bezelBottom: framedBar && barPos !== "bottom"
    ? Math.max(1, Number(barSkin.frameWidth || 8))
    : 0
  readonly property int bezelLeft: framedBar
    ? (barPos === "left" ? Math.max(24, Number(barSkin.height || 44)) : Math.max(1, Number(barSkin.frameWidth || 8)))
    : 0
  readonly property int bezelRight: framedBar
    ? (barPos === "right" ? Math.max(24, Number(barSkin.height || 44)) : Math.max(1, Number(barSkin.frameWidth || 8)))
    : 0

  // Радиус стыков — как у углов рамки (radius скина), как у дашборда и Super+M.
  readonly property int flare: framedBar ? Math.max(8, Math.round(Number(barSkin.radius || 0))) : 14
  readonly property int cornerRadius: 18
  // Линия ящика — тем же цветом, что линия рамки (border + borderAlpha скина, как в BarSkin.qml),
  // иначе стык с рамкой виден по смене цвета.
  readonly property color lineColor: {
    var s = String(barSkin.border || "")
    var key = s.indexOf("dotmatrix.") === 0 ? s.slice("dotmatrix.".length) : ""
    var c = key !== "" && DotMatrix.Palette[key] !== undefined ? DotMatrix.Palette[key]
      : s.charAt(0) === "#" ? Qt.color(s) : DotMatrix.Palette.line
    var a = Number(barSkin.borderAlpha)
    return framedBar && Number(barSkin.borderWidth || 0) > 0 ? Qt.rgba(c.r, c.g, c.b, isFinite(a) ? Math.max(0, Math.min(1, a)) : 1)
      : DotMatrix.Palette.line
  }
  readonly property real innerWidth: Math.max(360, width - bezelLeft - bezelRight)
  readonly property real centerX: bezelLeft + innerWidth / 2
  readonly property real drawerWidth: Math.min(860, innerWidth - 96)
  readonly property real targetHeight: Math.min(470, height - bezelBottom - 80)

  property real openProgress: 1
  NumberAnimation {
    id: openAnim
    target: root
    property: "openProgress"
    from: 0
    to: 1
    duration: 250
    easing.type: Easing.OutCubic
  }

  onWoke: {
    armedItemId = ""
    openAnim.restart()
  }

  onQueryChanged: {
    armedItemId = ""
    if (calcMode) calcDebounce.restart()
    else calcResult = ""
  }

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

  function isDangerRow(row) {
    return !!row && String(row.itemId || "") === "cmd.poweroff"
  }

  function triggerRow(index) {
    if (index < 0 || index >= root.count) return
    var row = root.rowAt(index)
    if (actionsMode && isConfirmRow(row)) {
      var id = String(row.itemId)
      if (armedItemId !== id) {
        armedItemId = id
        disarmTimer.restart()
        return
      }
      armedItemId = ""
    }
    root.activated(index)
  }

  function handleEnter() {
    if (calcMode) {
      if (calcResult !== "" && calcResult !== "ERR") {
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy 2>/dev/null || true", "dotmatrix-calc", calcResult])
        root.dismissRequested()
      }
      return true
    }
    if (actionsMode && root.cursorActive && root.selectedIndex >= 0 && root.selectedIndex < root.count) {
      var row = root.rowAt(root.selectedIndex)
      if (isConfirmRow(row)) {
        triggerRow(root.selectedIndex)
        return true
      }
    }
    return false
  }

  function navigate(dx, dy) {
    if (calcMode || root.count === 0) return
    if (actionsMode) {
      var stepA = dy !== 0 ? dy : dx
      if (stepA !== 0) root.step(stepA)
      return
    }
    var cols = 7
    var next = root.selectedIndex
    if (dx !== 0) {
      next = Math.max(0, Math.min(root.count - 1, root.selectedIndex + dx))
    } else if (dy !== 0) {
      var candidate = root.selectedIndex + dy * cols
      if (candidate >= 0 && candidate < root.count) next = candidate
      else if (dy > 0 && root.selectedIndex < root.count - 1) next = root.count - 1
      else if (dy < 0 && root.selectedIndex > 0) next = 0
    }
    root.selectRequested(next)
  }

  Timer {
    id: disarmTimer
    interval: 3000
    onTriggered: root.armedItemId = ""
  }

  Timer {
    id: calcDebounce
    interval: 90
    onTriggered: {
      if (!root.calcMode || root.calcExpr === "") {
        root.calcResult = ""
        return
      }
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
      "FN = {\"sqrt\": math.sqrt, \"sin\": math.sin, \"cos\": math.cos, \"tan\": math.tan, \"log\": math.log, \"log10\": math.log10, \"exp\": math.exp, \"abs\": abs, \"round\": round, \"floor\": math.floor, \"ceil\": math.ceil, \"hex\": lambda x: hex(int(x)), \"bin\": lambda x: bin(int(x))}\n" +
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
      "dotmatrix-calc-eval",
      calcProc.expr
    ]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.calcResult = String(text || "").trim()
    }
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/bar-skin.json"
    watchChanges: true
    printErrors: false
    onLoaded: { try { root.barSkin = JSON.parse(text() || "{}") || {} } catch (e) { root.barSkin = {} } }
    onLoadFailed: root.barSkin = {}
    onFileChanged: reload()
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/shell.json"
    watchChanges: true
    printErrors: false
    onLoaded: {
      try {
        var cfg = JSON.parse(text() || "{}") || {}
        root.barPos = cfg.bar && cfg.bar.position ? String(cfg.bar.position) : "top"
      } catch (e) {
        root.barPos = "top"
      }
    }
    onFileChanged: reload()
  }

  // Subtle backdrop wash outside the bottom drawer.
  Rectangle {
    anchors.fill: parent
    color: DotMatrix.Palette.bg
    opacity: Math.max(0, Math.min(0.45, (root.backdrop - 0.5) * 0.7)) * root.openProgress
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  readonly property real curHeight: Math.round(targetHeight * openProgress)
  readonly property real baseY: height - bezelBottom + 0.5
  readonly property real topY: baseY - curHeight
  readonly property real leftX: Math.round(centerX - drawerWidth / 2)
  readonly property real rightX: leftX + drawerWidth

  // Выдвижной ящик из нижней рамки: стыки скругляют угол свободной области, как у рамки и дашборда.
  Shape {
    id: drawerShape
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    readonly property real fy: Math.min(root.flare, root.curHeight)
    readonly property real tr: Math.max(0, Math.min(root.cornerRadius, (root.curHeight - fy) / 2))

    ShapePath {
      fillColor: DotMatrix.Palette.bg
      strokeWidth: -1
      startX: root.leftX - root.flare
      startY: root.height

      PathLine { x: root.leftX - root.flare; y: root.baseY }
      PathArc {
        x: root.leftX
        y: root.baseY - drawerShape.fy
        radiusX: Math.max(0.01, root.flare)
        radiusY: Math.max(0.01, drawerShape.fy)
        direction: PathArc.Counterclockwise
      }
      PathLine { x: root.leftX; y: root.topY + drawerShape.tr }
      PathArc {
        x: root.leftX + drawerShape.tr
        y: root.topY
        radiusX: Math.max(0.01, drawerShape.tr)
        radiusY: Math.max(0.01, drawerShape.tr)
      }
      PathLine { x: root.rightX - drawerShape.tr; y: root.topY }
      PathArc {
        x: root.rightX
        y: root.topY + drawerShape.tr
        radiusX: Math.max(0.01, drawerShape.tr)
        radiusY: Math.max(0.01, drawerShape.tr)
      }
      PathLine { x: root.rightX; y: root.baseY - drawerShape.fy }
      PathArc {
        x: root.rightX + root.flare
        y: root.baseY
        radiusX: Math.max(0.01, root.flare)
        radiusY: Math.max(0.01, drawerShape.fy)
        direction: PathArc.Counterclockwise
      }
      PathLine { x: root.rightX + root.flare; y: root.height }
    }

    ShapePath {
      fillColor: "transparent"
      strokeColor: root.lineColor
      strokeWidth: root.curHeight > 1 ? 1 : -1
      startX: root.leftX - root.flare
      startY: root.baseY

      PathArc {
        x: root.leftX
        y: root.baseY - drawerShape.fy
        radiusX: Math.max(0.01, root.flare)
        radiusY: Math.max(0.01, drawerShape.fy)
        direction: PathArc.Counterclockwise
      }
      PathLine { x: root.leftX; y: root.topY + drawerShape.tr }
      PathArc {
        x: root.leftX + drawerShape.tr
        y: root.topY
        radiusX: Math.max(0.01, drawerShape.tr)
        radiusY: Math.max(0.01, drawerShape.tr)
      }
      PathLine { x: root.rightX - drawerShape.tr; y: root.topY }
      PathArc {
        x: root.rightX
        y: root.topY + drawerShape.tr
        radiusX: Math.max(0.01, drawerShape.tr)
        radiusY: Math.max(0.01, drawerShape.tr)
      }
      PathLine { x: root.rightX; y: root.baseY - drawerShape.fy }
      PathArc {
        x: root.rightX + root.flare
        y: root.baseY
        radiusX: Math.max(0.01, root.flare)
        radiusY: Math.max(0.01, drawerShape.fy)
        direction: PathArc.Counterclockwise
      }
    }
  }

  Item {
    id: drawerBody
    x: root.leftX
    y: root.topY
    width: root.drawerWidth
    height: root.curHeight
    clip: true
    opacity: Math.max(0, (root.openProgress - 0.4) / 0.6)

    // Absorb clicks inside the drawer so they don't hit the backdrop dismiss area.
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton) root.backRequested()
      }
    }

    Item {
      width: root.drawerWidth
      height: root.targetHeight

      // Search pill
      Rectangle {
        id: searchPill
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 24
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        height: 44
        radius: 22
        color: DotMatrix.Palette.surface
        border.width: 1
        border.color: DotMatrix.Palette.line

        Text {
          id: modeGlyph
          anchors.left: parent.left
          anchors.leftMargin: 18
          anchors.verticalCenter: parent.verticalCenter
          text: root.calcMode
            ? String.fromCodePoint(0xF00EC)
            : (root.actionsMode ? String.fromCodePoint(0xF018D) : String.fromCodePoint(0xF0349))
          font.family: DotMatrix.Palette.fontIcon
          font.pixelSize: 16
          color: root.query.length > 0 ? DotMatrix.Palette.fg : DotMatrix.Palette.muted
        }

        Text {
          anchors.left: modeGlyph.right
          anchors.leftMargin: 12
          anchors.right: crumbText.visible ? crumbText.left : parent.right
          anchors.rightMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          elide: Text.ElideRight
          text: root.query.length > 0
            ? root.query
            : "Search  ·  > actions  ·  = calculate"
          // Точечный слой: введённый запрос — DotMatrix Dot крупнее, подсказка остаётся моно.
          font.family: root.query.length > 0 && DotMatrix.Palette.dotLayer ? DotMatrix.Palette.fontDot : DotMatrix.Palette.fontMono
          font.pixelSize: root.query.length > 0 && DotMatrix.Palette.dotLayer ? 18 : 13
          font.weight: root.query.length > 0 ? DotMatrix.Palette.titleWeight(Font.Normal) : Font.Normal
          color: root.query.length > 0 ? DotMatrix.Palette.fg : DotMatrix.Palette.muted
        }

        Text {
          id: crumbText
          visible: root.subtitle.length > 0 && root.query.length === 0
          anchors.right: parent.right
          anchors.rightMargin: 18
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: root.subtitle.toUpperCase()
          font.family: DotMatrix.Palette.fontMono
          font.pixelSize: 10
          font.letterSpacing: 1.5
          color: DotMatrix.Palette.muted
        }
      }

      // 1. 7-column Monochrome App / Menu Grid
      GridView {
        id: appGrid
        visible: !root.calcMode && !root.actionsMode
        anchors.top: searchPill.bottom
        anchors.bottom: footerText.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 16
        anchors.bottomMargin: 12
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: Math.floor(width / 7)
        cellHeight: 104
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
          readonly property bool nearViewport: Math.abs(cell.index - root.selectedIndex) < 42

          width: appGrid.cellWidth
          height: appGrid.cellHeight

          Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 18
            color: cell.selected ? DotMatrix.Palette.surfaceHi : (cellArea.containsMouse ? DotMatrix.Palette.surface : "transparent")
            border.width: cell.selected ? 1 : 0
            border.color: DotMatrix.Palette.line
          }

          Item {
            id: iconBox
            anchors.horizontalCenter: parent.horizontalCenter
            y: 16
            width: 44
            height: 44

            RowIcon {
              id: rowIco
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
              color: cell.selected || cellArea.containsMouse ? DotMatrix.Palette.fg : DotMatrix.Palette.dim

              layer.enabled: cell.kind === "app"
              layer.effect: MultiEffect {
                saturation: (cell.selected || cellArea.containsMouse) ? 0 : -1
                brightness: (cell.selected || cellArea.containsMouse) ? 0 : -0.05
                Behavior on saturation { NumberAnimation { duration: 160 } }
              }
            }
          }

          Text {
            anchors.top: iconBox.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 14
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: cell.label.toUpperCase()
            font.family: DotMatrix.Palette.fontMono
            font.pixelSize: 10
            font.letterSpacing: 0.8
            color: cell.selected ? DotMatrix.Palette.fg : DotMatrix.Palette.muted
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

      // Empty state for apps/actions search
      Text {
        visible: !root.calcMode && root.count === 0
        anchors.centerIn: appGrid
        textFormat: Text.PlainText
        text: root.emptyText().toUpperCase()
        font.family: DotMatrix.Palette.fontMono
        font.pixelSize: 11
        font.letterSpacing: 1.6
        color: DotMatrix.Palette.muted
      }

      // 2. ">" Actions List with 2-click red confirm
      ListView {
        id: actionsList
        visible: root.actionsMode
        anchors.top: searchPill.bottom
        anchors.bottom: footerText.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.bottomMargin: 12
        anchors.leftMargin: 28
        anchors.rightMargin: 28
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
          radius: 14
          color: isArmed ? DotMatrix.Palette.danger : (selected ? DotMatrix.Palette.surfaceHi : (actArea.containsMouse ? DotMatrix.Palette.surface : "transparent"))
          border.width: selected && !isArmed ? 1 : 0
          border.color: DotMatrix.Palette.line

          Text {
            id: actGlyph
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: actRow.icon
            font.family: DotMatrix.Palette.fontIcon
            font.pixelSize: 16
            color: actRow.isArmed ? DotMatrix.Palette.onSignal : (actRow.isDanger ? DotMatrix.Palette.danger : (actRow.selected ? DotMatrix.Palette.fg : DotMatrix.Palette.dim))
          }

          Text {
            anchors.left: actGlyph.right
            anchors.leftMargin: 14
            anchors.right: actHint.left
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: actRow.label
            font.family: DotMatrix.Palette.fontSans
            font.pixelSize: 14
            font.weight: actRow.selected ? Font.Medium : Font.Normal
            color: actRow.isArmed ? DotMatrix.Palette.onSignal : (actRow.selected ? DotMatrix.Palette.fg : DotMatrix.Palette.dim)
          }

          Text {
            id: actHint
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: (actRow.isArmed ? "ENTER AGAIN" : actRow.detail).toUpperCase()
            font.family: DotMatrix.Palette.fontMono
            font.pixelSize: 10
            font.letterSpacing: 1.4
            color: actRow.isArmed ? DotMatrix.Palette.onSignal : DotMatrix.Palette.muted
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

      // 3. "=" Calculator in 56px Doto Bold LED digits
      Column {
        visible: root.calcMode
        anchors.centerIn: appGrid
        spacing: 14

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          textFormat: Text.PlainText
          text: (root.calcExpr.length > 0 ? root.calcExpr : "TYPE AN EXPRESSION").toUpperCase()
          font.family: DotMatrix.Palette.fontMono
          font.pixelSize: 11
          font.letterSpacing: 1.6
          color: DotMatrix.Palette.muted
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          width: Math.min(implicitWidth, root.drawerWidth - 80)
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.calcResult !== "" ? root.calcResult : "0"
          font.family: DotMatrix.Palette.fontDot
          font.weight: Font.Bold
          font.pixelSize: 56
          color: root.calcResult !== "" ? DotMatrix.Palette.fg : DotMatrix.Palette.unlit
        }
      }

      // Footer hint
      Text {
        id: footerText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: root.calcMode
          ? "ENTER COPY RESULT  ·  ESC CLOSE"
          : (root.actionsMode
             ? "↑↓ SELECT  ·  ENTER RUN  ·  ESC CLOSE"
             : "ARROWS MOVE  ·  ENTER OPEN  ·  > ACTIONS  ·  = CALC  ·  ESC CLOSE")
        font.family: DotMatrix.Palette.fontMono
        font.pixelSize: 10
        font.letterSpacing: 1.5
        color: DotMatrix.Palette.muted
      }
    }
  }
}
