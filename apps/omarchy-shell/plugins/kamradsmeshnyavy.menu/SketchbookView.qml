import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import qs.Commons

// Sketchbook: the menu as a page of a sketchbook (made for the Customizer's Paper style). A ruled sheet with
// a red margin, a spiral binding and slightly torn edges lies on the desk; each row is a small
// polaroid card pinned to the page at its own tilt. The selected card straightens up, gets a strip
// of tape and a pencil circle drawn around it, and a sticky note beside the book tells what it
// is. Typing writes the query on the page by hand; launching tears the card off the page.
// Colours come from the theme: a light theme gives white paper, a dark one kraft. Handwriting is
// Caveat and Pangolin (bundled with kamradsmeshnyavy.customizer), with the menu font as a fallback.
SkinBase {
  id: root

  launchDelay: 480

  // ── шрифты ───────────────────────────────────────────────────────────
  readonly property var families: Qt.fontFamilies()
  readonly property string hand: families.indexOf("Caveat") >= 0 ? "Caveat" : root.fontFamily
  readonly property string printFace: families.indexOf("Pangolin") >= 0 ? "Pangolin" : root.hand

  // ── бумага и чернила из темы ─────────────────────────────────────────
  readonly property bool kraft: root.theme ? root.theme.luma(root.background) < 0.45 : true
  readonly property color desk: root.theme ? root.theme.mix(root.background, "#000000", root.kraft ? 0.35 : 0.12) : "#141210"
  readonly property color paper: root.theme
    ? (root.kraft ? root.theme.mix(root.theme.mix(root.background, root.theme.brown, 0.3), root.foreground, 0.04)
                  : root.theme.mix(root.background, root.theme.yellow, 0.05))
    : "#efe6d2"
  readonly property color card: root.theme ? root.theme.mix(root.paper, root.kraft ? root.foreground : "#ffffff", root.kraft ? 0.06 : 0.55) : "#fbf7ee"
  readonly property color ink: root.foreground
  readonly property color pencil: root.theme ? root.theme.mix(root.foreground, root.paper, 0.45) : "#77706a"
  readonly property color rule: root.theme ? root.theme.mix(root.kraft ? root.ink : root.theme.blue, root.paper, root.kraft ? 0.72 : 0.7) : "#9fb6cf"
  readonly property color margin: root.theme ? root.theme.mix(root.theme.red, root.kraft ? root.ink : root.paper, 0.2) : "#d06060"
  // Малярный скотч: светлый и полупрозрачный на любой бумаге.
  readonly property color tape: root.theme ? Util.alpha(root.theme.mix(root.theme.yellow, "#ffffff", 0.45), 0.62) : Qt.rgba(1, 0.95, 0.8, 0.6)
  // Карандаш выделения: акцент, сдвинутый к чернилам, — читается и на крафте, и на белой бумаге.
  readonly property color mark: root.theme ? root.theme.mix(root.accent, root.ink, root.kraft ? 0.45 : 0.15) : root.accent
  readonly property color note: root.theme ? root.theme.mix(root.theme.yellow, root.paper, root.kraft ? 0.55 : 0.35) : "#f4e39a"
  readonly property string grain: Quickshell.env("HOME") + "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/textures/"
    + (root.kraft ? "paper-dark.png" : "paper.png")

  // ── раскладка ────────────────────────────────────────────────────────
  readonly property real sheetX: 90 * u
  readonly property real sheetY: 70 * u
  readonly property real sheetW: Math.min(root.width * 0.62, root.width - 520 * u)
  readonly property real sheetH: root.height - 140 * u
  readonly property real lineGap: 34 * u
  readonly property real marginX: 78 * u                 // красное поле от левого края листа
  readonly property real gridX: root.sheetX + root.marginX + 26 * u
  readonly property real gridY: root.sheetY + 170 * u
  readonly property real cellW: 150 * u
  readonly property real cellH: 156 * u
  readonly property int cols: Math.max(3, Math.floor((root.sheetX + root.sheetW - 30 * u - root.gridX) / root.cellW))
  readonly property int rows: Math.max(1, Math.floor((root.sheetY + root.sheetH - 70 * u - root.gridY) / root.cellH))
  pageSize: root.cols * root.rows

  function hash(i, s) { var x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453; return x - Math.floor(x) }

  function navigate(dx, dy) {
    if (dx !== 0) root.clampTo(root.selectedIndex + dx)
    else root.clampTo(root.selectedIndex + dy * root.cols)
  }

  // Карандашная обводка: эллипс с дрожью и перехлёстом, детерминированный по индексу.
  function scribble(w, h, seed) {
    var pts = []
    var cx = w / 2, cy = h / 2
    var a0 = -2.2 + root.hash(seed, 9) * 0.6
    var n = 46
    for (var k = 0; k <= n; k++) {
      var t = k / n
      var a = a0 + t * (Math.PI * 2 + 0.55)
      var wob = 1 + (root.hash(seed * 7 + k, 3) - 0.5) * 0.05 + t * 0.04
      pts.push(Qt.point(cx + Math.cos(a) * cx * wob, cy + Math.sin(a) * cy * wob))
    }
    return pts
  }

  // Волнистое подчёркивание заголовка.
  function squiggle(w, h) {
    var pts = []
    for (var x = 0; x <= w; x += 6) pts.push(Qt.point(x, h / 2 + Math.sin(x / 9) * h * 0.35 + (x / w) * 2))
    return pts
  }

  // Край листа: чуть неровный, правый край — оторванный.
  function sheetEdge(w, h) {
    var pts = [Qt.point(0, 0)]
    for (var x = 12; x < w; x += 12) pts.push(Qt.point(x, (root.hash(x, 1) - 0.5) * 1.6))
    for (var y = 0; y < h; y += 7) pts.push(Qt.point(w - 2 - root.hash(y, 2) * 5, y))
    for (var x2 = w; x2 > 0; x2 -= 12) pts.push(Qt.point(x2, h + (root.hash(x2, 4) - 0.5) * 1.6))
    pts.push(Qt.point(0, h))
    pts.push(Qt.point(0, 0))
    return pts
  }

  // ── вход и отрыв карточки ────────────────────────────────────────────
  property real enter: 1
  NumberAnimation { id: enterAnim; target: root; property: "enter"; from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
  onWoke: { root.flight = 0; if (root.burst) enterAnim.restart() }
  onRevisionChanged: if (root.burst) enterAnim.restart()

  property real flight: 0
  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    flightAnim.restart()
  }
  NumberAnimation { id: flightAnim; target: root; property: "flight"; from: 0; to: 1; duration: 480; easing.type: Easing.InCubic }

  // ── стол ─────────────────────────────────────────────────────────────
  Rectangle { anchors.fill: parent; color: root.desk; opacity: Math.min(0.97, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // ── лист ─────────────────────────────────────────────────────────────
  Item {
    id: sheet
    x: root.sheetX
    y: root.sheetY
    width: root.sheetW
    height: root.sheetH
    layer.enabled: true
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: "#000000"
      shadowOpacity: root.kraft ? 0.55 : 0.3
      shadowBlur: 0.9
      shadowVerticalOffset: 6 * root.u
      shadowHorizontalOffset: 3 * root.u
    }

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        fillColor: root.paper
        strokeColor: Util.alpha(root.pencil, 0.35)
        strokeWidth: 1
        PathPolyline { path: root.sheetEdge(sheet.width, sheet.height) }
      }
    }
    // Зерно бумаги.
    Image {
      anchors { fill: parent; rightMargin: 6 * root.u }
      source: "file://" + root.grain
      fillMode: Image.Tile
      horizontalAlignment: Image.AlignLeft
      verticalAlignment: Image.AlignTop
      opacity: 0.85
      asynchronous: true
      smooth: false
    }
    // Линовка и красное поле.
    Repeater {
      model: Math.max(0, Math.floor((sheet.height - 130 * root.u) / root.lineGap))
      Rectangle {
        required property int index
        x: 0
        y: 130 * root.u + index * root.lineGap
        width: sheet.width - 8 * root.u
        height: 1
        color: root.rule
        opacity: root.kraft ? 0.8 : 0.6
      }
    }
    Rectangle { x: root.marginX; y: 0; width: 2; height: sheet.height; color: root.margin; opacity: 0.9 }
    Rectangle { x: root.marginX + 5 * root.u; y: 0; width: 1; height: sheet.height; color: root.margin; opacity: 0.5 }
  }

  // Спираль переплёта: дырки в листе и проволочные кольца поверх края.
  Repeater {
    model: Math.max(0, Math.floor((root.sheetH - 40 * root.u) / (34 * root.u)))
    Item {
      required property int index
      x: root.sheetX - 16 * root.u
      y: root.sheetY + 22 * root.u + index * 34 * root.u
      width: 44 * root.u
      height: 14 * root.u
      Rectangle { x: 26 * root.u; y: 3 * root.u; width: 9 * root.u; height: 9 * root.u; radius: width / 2; color: root.desk }
      Rectangle {
        width: 34 * root.u
        height: 9 * root.u
        y: 2.5 * root.u
        radius: height / 2
        color: "transparent"
        border.width: 2.5 * root.u
        border.color: root.theme ? root.theme.mix(root.pencil, root.ink, 0.4) : "#555"
        rotation: -8
      }
    }
  }

  // ── заголовок, поиск и номер страницы ────────────────────────────────
  Text {
    id: titleText
    x: root.sheetX + root.marginX + 22 * u
    y: root.sheetY + 20 * u
    textFormat: Text.PlainText
    text: root.title.length > 0 ? root.title : "Apps"
    color: root.ink
    font.family: root.hand
    font.pixelSize: 54 * u
    font.weight: Font.Bold
  }
  Shape {
    x: titleText.x
    y: titleText.y + titleText.height - 6 * u
    width: Math.max(80 * u, titleText.width)
    height: 10 * u
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      fillColor: "transparent"
      strokeColor: root.mark
      strokeWidth: 2.5 * root.u
      capStyle: ShapePath.RoundCap
      PathPolyline { path: root.squiggle(Math.max(80 * root.u, titleText.width), 10 * root.u) }
    }
  }
  // Солнышко-дудл рядом с заголовком.
  Shape {
    x: titleText.x + titleText.width + 18 * u
    y: titleText.y + 14 * u
    width: 34 * u
    height: 34 * u
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      fillColor: "transparent"
      strokeColor: Util.alpha(root.theme ? root.theme.yellow : root.accent, 0.9)
      strokeWidth: 2 * root.u
      capStyle: ShapePath.RoundCap
      PathAngleArc { centerX: 17 * root.u; centerY: 17 * root.u; radiusX: 7 * root.u; radiusY: 7 * root.u; startAngle: 0; sweepAngle: 340 }
    }
    Repeater {
      model: 8
      Rectangle {
        required property int index
        x: 17 * root.u + Math.cos(index * Math.PI / 4) * 12 * root.u - width / 2
        y: 17 * root.u + Math.sin(index * Math.PI / 4) * 12 * root.u - height / 2
        width: 6 * root.u
        height: 2 * root.u
        radius: 1
        rotation: index * 45
        color: Util.alpha(root.theme ? root.theme.yellow : root.accent, 0.9)
      }
    }
  }

  // Путь подменю — карандашом под заголовком, если он не повторяет заголовок.
  Text {
    visible: root.subtitle.length > 0 && root.subtitle !== root.title
    x: titleText.x + titleText.width + 70 * u
    y: titleText.y + 26 * u
    textFormat: Text.PlainText
    text: root.subtitle
    color: root.pencil
    font.family: root.hand
    font.pixelSize: 26 * u
  }

  QueryText {
    x: root.sheetX + root.marginX + 24 * u
    y: root.sheetY + 130 * u - 34 * u + 4 * u
    width: root.sheetW - root.marginX - 80 * u
    height: 30 * u
    query: root.query
    placeholder: "write here to search…"
    color: root.ink
    placeholderColor: root.pencil
    caretColor: root.accent
    fontFamily: root.hand
    pixelSize: 28 * u
    live: root.live
  }

  Text {
    visible: root.pages > 1
    x: root.sheetX + root.sheetW - width - 36 * u
    y: root.sheetY + root.sheetH - 46 * u
    textFormat: Text.PlainText
    text: "p. " + (root.page + 1) + " / " + root.pages
    color: root.pencil
    font.family: root.hand
    font.pixelSize: 26 * u
  }
  // Загнутый уголок — есть ещё страницы.
  Shape {
    visible: root.pages > 1
    x: root.sheetX + root.sheetW - 40 * u
    y: root.sheetY + root.sheetH - 40 * u
    width: 34 * u
    height: 34 * u
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      fillColor: root.theme ? root.theme.mix(root.paper, "#000000", 0.12) : "#d8cfbc"
      strokeColor: Util.alpha(root.pencil, 0.5)
      strokeWidth: 1
      startX: 34 * root.u; startY: 0
      PathLine { x: 0; y: 34 * root.u }
      PathLine { x: 34 * root.u; y: 34 * root.u }
      PathLine { x: 34 * root.u; y: 0 }
    }
  }

  Text {
    visible: root.count === 0
    x: root.gridX
    y: root.gridY + 20 * u
    width: root.sheetW - root.marginX - 80 * u
    wrapMode: Text.Wrap
    textFormat: Text.PlainText
    text: root.emptyText() + "  ✎"
    color: root.pencil
    font.family: root.hand
    font.pixelSize: 34 * u
  }

  // ── карточки ─────────────────────────────────────────────────────────
  Repeater {
    model: root.rowModel

    delegate: Item {
      id: tile

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: tile.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property bool sel: root.cursorActive && tile.index === root.selectedIndex
      readonly property bool flying: root.launching && tile.index === root.launchIndex
      readonly property real tilt: (root.hash(tile.index, 5) - 0.5) * 7
      // Вход по очереди: карточки «ложатся» на лист сверху.
      readonly property real t: Math.max(0, Math.min(1, root.enter * (1 + root.pageCount * 0.05) - Math.max(0, slot) * 0.05))

      visible: tile.onPage
      width: 118 * root.u
      height: 128 * root.u
      x: root.gridX + (Math.max(0, slot) % root.cols) * root.cellW + (root.cellW - width) / 2
         + (root.hash(tile.index, 6) - 0.5) * 10 * root.u
      y: root.gridY + Math.floor(Math.max(0, slot) / root.cols) * root.cellH
         - (1 - tile.t) * 28 * root.u - (tile.flying ? root.flight * 160 * root.u : 0)
      opacity: tile.t * (tile.flying ? 1 - root.flight : 1)
      rotation: tile.sel ? 0 : tile.tilt + (tile.flying ? root.flight * 24 : 0)
      scale: (tile.sel ? 1.1 : 1) + (tile.flying ? root.flight * 0.25 : 0)
      z: tile.sel ? 20 : 10
      Behavior on rotation { enabled: !tile.flying; NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
      Behavior on scale { enabled: !tile.flying; NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

      // Полароид: светлая карточка с тенью.
      Rectangle {
        id: face
        anchors.fill: parent
        color: root.card
        radius: 2 * root.u
        border.width: 1
        border.color: Util.alpha(root.pencil, tile.sel ? 0.6 : 0.3)
        layer.enabled: true
        layer.effect: MultiEffect {
          shadowEnabled: true
          shadowColor: "#000000"
          shadowOpacity: tile.sel ? 0.45 : 0.25
          shadowBlur: tile.sel ? 0.8 : 0.45
          shadowVerticalOffset: (tile.sel ? 5 : 2) * root.u
          shadowHorizontalOffset: 1 * root.u
        }

        // «Окошко» снимка.
        Rectangle {
          x: 10 * root.u
          y: 10 * root.u
          width: parent.width - 20 * root.u
          height: 76 * root.u
          color: root.theme ? root.theme.mix(root.card, root.ink, 0.06) : "#eee"
          RowIcon {
            anchors.centerIn: parent
            size: 48 * root.u
            kind: tile.kind
            glyph: tile.icon
            glyphFont: tile.iconFont
            appIcon: tile.appIcon
            resolver: root.iconResolver
            fontFamily: root.fontFamily
            load: tile.onPage
            fallback: tile.label.charAt(0).toUpperCase()
            color: root.ink
          }
        }
        Text {
          anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 6 * root.u; bottomMargin: 4 * root.u }
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label + (root.isBranch(tile.kind) ? " →" : "")
          color: root.ink
          font.family: root.hand
          font.pixelSize: 22 * root.u
          font.weight: tile.sel ? Font.Bold : Font.Normal
        }
      }

      // Скотч и карандашный кружок — у выбранной.
      Rectangle {
        visible: tile.sel
        width: 58 * root.u
        height: 18 * root.u
        x: (parent.width - width) / 2 + (root.hash(tile.index, 7) - 0.5) * 16 * root.u
        y: -9 * root.u
        rotation: (root.hash(tile.index, 8) - 0.5) * 10
        color: root.tape
      }
      Shape {
        visible: tile.sel
        x: -18 * root.u
        y: -16 * root.u
        width: parent.width + 36 * root.u
        height: parent.height + 32 * root.u
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          fillColor: "transparent"
          strokeColor: root.mark
          strokeWidth: 3 * root.u
          capStyle: ShapePath.RoundCap
          joinStyle: ShapePath.RoundJoin
          PathPolyline { path: root.scribble(tile.width + 36 * root.u, tile.height + 32 * root.u, tile.index) }
        }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hoverSelect(tile.index, mapToItem(root, mouseX, mouseY))
        onPositionChanged: root.hoverSelect(tile.index, mapToItem(root, mouseX, mouseY))
        onClicked: root.activated(tile.index)
      }
    }
  }

  // ── стикер с подробностями ───────────────────────────────────────────
  Item {
    id: sticky
    visible: root.current !== null
    x: root.sheetX + root.sheetW + 50 * u
    y: root.sheetY + 90 * u
    width: Math.min(340 * u, root.width - x - 40 * u)
    height: 330 * u
    rotation: 2.5

    Rectangle {
      anchors.fill: parent
      color: root.note
      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#000000"
        shadowOpacity: 0.4
        shadowBlur: 0.8
        shadowVerticalOffset: 6 * root.u
        shadowHorizontalOffset: -2 * root.u
      }
    }
    Image {
      anchors.fill: parent
      source: "file://" + root.grain
      fillMode: Image.Tile
      horizontalAlignment: Image.AlignLeft
      verticalAlignment: Image.AlignTop
      opacity: 0.6
      asynchronous: true
      smooth: false
    }
    Rectangle { width: 70 * root.u; height: 20 * root.u; x: parent.width / 2 - width / 2; y: -10 * root.u; rotation: -4; color: root.tape }

    readonly property color noteInk: root.theme ? root.theme.ink(root.note) : "#2a2622"

    RowIcon {
      x: 24 * root.u
      y: 30 * root.u
      size: 64 * root.u
      kind: root.current ? root.current.kind : ""
      glyph: root.current ? root.current.icon : ""
      glyphFont: root.current ? root.current.iconFont : ""
      appIcon: root.current ? root.current.appIcon : ""
      resolver: root.iconResolver
      fontFamily: root.fontFamily
      fallback: root.current ? String(root.current.label).charAt(0).toUpperCase() : ""
      color: sticky.noteInk
    }
    Text {
      x: 104 * root.u
      y: 34 * root.u
      width: parent.width - x - 20 * root.u
      wrapMode: Text.Wrap
      maximumLineCount: 2
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.label : ""
      color: sticky.noteInk
      font.family: root.hand
      font.pixelSize: 38 * root.u
      font.weight: Font.Bold
      lineHeight: 0.85
    }
    Text {
      x: 24 * root.u
      y: 120 * root.u
      width: parent.width - 48 * root.u
      height: 130 * root.u
      wrapMode: Text.Wrap
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.current.detail || root.current.target || "") : ""
      color: Util.alpha(sticky.noteInk, 0.8)
      font.family: root.printFace
      font.pixelSize: 17 * root.u
      lineHeight: 1.15
    }
    Text {
      x: 24 * root.u
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 22 * root.u
      textFormat: Text.PlainText
      text: !root.current ? "" : (root.isBranch(root.current.kind) ? "⏎  open the page  →" : "⏎  launch  ·  esc  close")
      color: Util.alpha(sticky.noteInk, 0.7)
      font.family: root.hand
      font.pixelSize: 24 * root.u
    }
  }
}
