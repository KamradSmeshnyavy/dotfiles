import QtQuick
import QtQuick.Shapes
import qs.Commons

// "Hexgrid" from bjarneo/omarchy-quickapps: a ring of hex tiles over a faint
// honeycomb, each tile with its own accent, the selected name in the middle.
// The per-tile accents cycle through the theme's hues. The ring holds a
// dozen tiles; longer menus turn the ring a page at a time.
SkinBase {
  id: root

  launchDelay: 180

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))
  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color glow: root.current ? root.hues[root.selectedIndex % root.hues.length] : root.accent

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Rectangle {
    anchors.fill: parent
    color: root.background
    opacity: Math.min(0.97, root.backdrop)
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

  // Faint honeycomb.
  Canvas {
    anchors.fill: parent
    property color line: root.foreground
    onLineChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      if (!root.theme) return
      ctx.strokeStyle = root.theme.rgba(root.foreground, 0.04)
      ctx.lineWidth = 1
      var s = 38 * root.u
      for (var row = -1; row * s * 0.75 < height + s; ++row) {
        for (var col = -1; col * s * 1.5 < width + s; ++col) {
          var cx = col * s * 1.5 + (row % 2 ? s * 0.75 : 0)
          var cy = row * s * 0.866
          ctx.beginPath()
          for (var i = 0; i < 6; ++i) {
            var a = i * Math.PI / 3
            var x = cx + Math.cos(a) * s / 2, y = cy + Math.sin(a) * s / 2
            if (i) ctx.lineTo(x, y); else ctx.moveTo(x, y)
          }
          ctx.closePath()
          ctx.stroke()
        }
      }
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 780 * u; height: 780 * u

    Column {
      anchors.centerIn: parent
      spacing: 8 * u
      width: 380 * u
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label.toUpperCase() : "—"
        color: root.glow
        Behavior on color { ColorAnimation { duration: 200 } }
        font.family: root.fontFamily; font.pixelSize: 28 * u; font.letterSpacing: 4; font.weight: Font.DemiBold
      }
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 60 * u; height: 2; color: root.glow }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? (root.current.detail || (root.isBranch(root.current.kind) ? root.current.label.toLowerCase() + " ›" : "")) : root.emptyText()
        color: root.dim
        font.family: root.mono; font.pixelSize: 11 * u
      }
      Item { width: 1; height: 14 * u }
      QueryText {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 18 * u
        alignment: Text.AlignHCenter
        visible: root.query.length > 0
        query: root.query
        placeholder: ""
        color: root.foreground
        caretColor: root.glow
        fontFamily: root.mono
        pixelSize: 13 * u
        live: root.live
      }
    }

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
        readonly property bool focusedTile: root.cursorActive && tile.index === root.selectedIndex
        readonly property color tileAccent: root.hues[tile.index % root.hues.length] || root.accent
        readonly property real angle: root.angleFor(Math.max(0, tile.slot))

        visible: tile.onPage
        width: 100 * u; height: 124 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 270 * u
        y: stage.height / 2 - 50 * u + Math.sin(angle) * 270 * u
        Behavior on x { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.12 : 1.0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Shape {
          id: hex
          width: 100 * u; height: 100 * u
          anchors.horizontalCenter: parent.horizontalCenter
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            strokeColor: tile.focusedTile ? tile.tileAccent : Util.alpha(root.foreground, 0.15)
            strokeWidth: tile.focusedTile ? 2 : 1
            fillColor: tile.focusedTile ? Util.alpha(tile.tileAccent, 0.12) : Util.alpha(root.foreground, 0.03)
            startX: 25 * u; startY: 0
            PathLine { x: 75 * u; y: 0 }
            PathLine { x: 100 * u; y: 50 * u }
            PathLine { x: 75 * u; y: 100 * u }
            PathLine { x: 25 * u; y: 100 * u }
            PathLine { x: 0; y: 50 * u }
            PathLine { x: 25 * u; y: 0 }
          }
        }
        RowIcon {
          anchors.centerIn: hex
          size: 44 * u
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0).toUpperCase()
          color: tile.focusedTile ? tile.tileAccent : root.foreground
        }
        Text {
          anchors.horizontalCenter: hex.horizontalCenter
          anchors.top: hex.bottom; anchors.topMargin: 6 * u
          width: 130 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label.toUpperCase()
          color: tile.focusedTile ? root.foreground : root.dim
          font.family: root.fontFamily; font.pixelSize: 10 * u; font.letterSpacing: 2
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(tile.index)
          onClicked: root.activated(tile.index)
        }
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 40 * u
    text: (root.pages > 1 ? "ring " + (root.page + 1) + "/" + root.pages + "  ·  " : "")
      + "tab cycle  ·  enter launch  ·  alt+1-9 jump  ·  ⌫ back  ·  esc quit"
    color: root.dim
    font.family: root.fontFamily; font.pixelSize: 11 * u; font.letterSpacing: 3
  }
}
