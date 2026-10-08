import QtQuick
import QtQuick.Shapes
import qs.Commons

// "Tron" from bjarneo/omarchy-quickapps: neon on black, a perspective grid
// floor, sharp bracket corners, rows as boxes orbiting a hexagonal frame.
// The neon is the theme accent; each program's own glow cycles through the
// theme's hues.
SkinBase {
  id: root

  launchDelay: 0

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property color neon: root.accent
  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  readonly property color glow: root.current ? (root.hues[root.selectedIndex % root.hues.length] || root.neon) : root.neon
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.75) : "#000308"
  readonly property color dimNeon: root.theme ? root.theme.mix(root.deep, root.neon, 0.45) : "#3d8a99"
  readonly property color softNeon: root.theme ? root.theme.mix(root.neon, root.foreground, 0.35) : "#5fc6d4"
  readonly property color white: root.theme ? root.theme.bright : "#ffffff"

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Rectangle { anchors.fill: parent; color: root.deep; opacity: Math.min(0.95, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  Canvas {
    anchors.fill: parent
    property color line: root.neon
    onLineChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      if (!root.theme) return
      ctx.strokeStyle = root.theme.rgba(root.neon, 0.15)
      ctx.lineWidth = 1
      var horizon = height * 0.55
      for (var i = -20; i <= 20; ++i) {
        var x = width / 2 + (i * width / 8)
        ctx.beginPath(); ctx.moveTo(x, height); ctx.lineTo(width / 2, horizon); ctx.stroke()
      }
      for (var r = 0; r < 14; ++r) {
        var t = Math.pow(r / 14, 2.2)
        var y = horizon + t * (height - horizon)
        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
      }
    }
  }

  Repeater {
    model: 4
    delegate: Item {
      required property int index
      width: 60 * u; height: 60 * u
      x: (index % 2) ? root.width - width - 30 * u : 30 * u
      y: (index < 2) ? 30 * u : root.height - height - 30 * u
      Rectangle { width: parent.width; height: 2; color: root.neon; y: (index < 2) ? 0 : parent.height - 2 }
      Rectangle { width: 2; height: parent.height; color: root.neon; x: (index % 2) ? parent.width - 2 : 0 }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 50 * u
    textFormat: Text.PlainText
    text: "/ / / " + (root.title === "Omarchy" ? "GRID" : root.title.toUpperCase()).split("").join(" ") + " / / /"
      + (root.pages > 1 ? "   " + (root.page + 1) + "/" + root.pages : "")
    color: root.neon
    font.family: root.mono; font.pixelSize: 14 * u; font.letterSpacing: 8; font.weight: Font.Bold
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 760 * u; height: 760 * u

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeColor: Util.alpha(root.neon, 0.45); strokeWidth: 1.5; fillColor: "transparent"
        startX: stage.width / 2; startY: 60 * root.u
        PathLine { x: stage.width - 80 * root.u; y: stage.height / 2 - 100 * root.u }
        PathLine { x: stage.width - 80 * root.u; y: stage.height / 2 + 100 * root.u }
        PathLine { x: stage.width / 2; y: stage.height - 60 * root.u }
        PathLine { x: 80 * root.u; y: stage.height / 2 + 100 * root.u }
        PathLine { x: 80 * root.u; y: stage.height / 2 - 100 * root.u }
        PathLine { x: stage.width / 2; y: 60 * root.u }
      }
      ShapePath {
        strokeColor: Util.alpha(root.neon, 0.18); strokeWidth: 1; fillColor: "transparent"
        startX: stage.width / 2; startY: 120 * root.u
        PathLine { x: stage.width - 140 * root.u; y: stage.height / 2 - 60 * root.u }
        PathLine { x: stage.width - 140 * root.u; y: stage.height / 2 + 60 * root.u }
        PathLine { x: stage.width / 2; y: stage.height - 120 * root.u }
        PathLine { x: 140 * root.u; y: stage.height / 2 + 60 * root.u }
        PathLine { x: 140 * root.u; y: stage.height / 2 - 60 * root.u }
        PathLine { x: stage.width / 2; y: 120 * root.u }
      }
    }

    Column {
      anchors.centerIn: parent
      spacing: 12 * u
      width: 360 * u
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.query.length > 0 ? "QUERY" : "PROGRAM"
        color: root.dimNeon
        font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 4; font.weight: Font.Bold
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label.toUpperCase() : (root.query.length > 0 ? "NO MATCH" : "IDLE")
        color: root.glow
        Behavior on color { ColorAnimation { duration: 220 } }
        font.family: root.mono; font.pixelSize: 28 * u; font.letterSpacing: 10; font.weight: Font.Bold
      }
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 120 * u; height: 2; color: root.glow }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.query.length > 0 ? "> " + root.query + "_" : (root.current && root.current.detail ? "> " + root.current.detail : "")
        color: root.softNeon
        font.family: root.mono; font.pixelSize: 11 * u; font.letterSpacing: 2
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
        readonly property color tileAccent: root.hues[tile.index % root.hues.length] || root.neon
        readonly property real angle: root.angleFor(Math.max(0, tile.slot))

        visible: tile.onPage
        width: 100 * u; height: 124 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 280 * u
        y: stage.height / 2 - 50 * u + Math.sin(angle) * 280 * u
        Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.12 : 1.0
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Rectangle {
          id: box
          width: 100 * u; height: 100 * u
          anchors.horizontalCenter: parent.horizontalCenter
          color: tile.focusedTile ? Util.alpha(root.neon, 0.08) : root.theme ? root.theme.mix(root.deep, root.neon, 0.04) : "#000a0f"
          border.color: tile.focusedTile ? tile.tileAccent : root.theme ? root.theme.mix(root.deep, root.neon, 0.3) : "#1a5560"
          border.width: tile.focusedTile ? 2 : 1
        }
        Repeater {
          model: tile.focusedTile ? 4 : 0
          delegate: Item {
            required property int index
            width: 10 * u; height: 10 * u
            x: box.x + (index % 2 ? box.width - width : 0)
            y: box.y + (index < 2 ? 0 : box.height - height)
            Rectangle { width: 10 * u; height: 2; color: tile.tileAccent; y: index < 2 ? 0 : parent.height - 2 }
            Rectangle { width: 2; height: 10 * u; color: tile.tileAccent; x: index % 2 ? parent.width - 2 : 0 }
          }
        }
        RowIcon {
          anchors.centerIn: box
          size: 46 * u
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0)
          color: tile.focusedTile ? tile.tileAccent : root.softNeon
        }
        Text {
          anchors.horizontalCenter: box.horizontalCenter
          anchors.top: box.bottom; anchors.topMargin: 6 * u
          width: 130 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label.toUpperCase()
          color: tile.focusedTile ? root.white : root.dimNeon
          font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 2.5; font.weight: Font.Bold
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
    anchors.bottom: parent.bottom; anchors.bottomMargin: 50 * u
    text: "[ < > ] CYCLE   [ ENTER ] DERESOLUTION   [ ⌫ ] RETURN   [ ESC ] ESCAPE"
    color: root.dimNeon
    font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 4; font.weight: Font.Bold
  }
}
