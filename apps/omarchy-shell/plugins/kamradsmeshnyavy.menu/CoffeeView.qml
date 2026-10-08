import QtQuick
import qs.Commons

// "Coffee" from bjarneo/omarchy-quickapps: paper with coffee stains, rows as
// mugs around a latte seen from above, the selected name poured into the
// foam. The paper is the theme background warmed with its brown, the brew is
// that brown pulled towards the foreground so it reads on dark themes, and
// the crema is the theme accent.
SkinBase {
  id: root

  launchDelay: 200

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property bool light: root.theme ? root.theme.light : false
  readonly property color cream: root.theme ? root.theme.mix(root.background, root.theme.brown, 0.08) : "#f5e6d3"
  readonly property color brew: root.theme
    ? (root.light ? root.theme.mix(root.theme.brown, "#000000", 0.25) : root.theme.mix(root.theme.brown, root.foreground, 0.45))
    : "#5b3a1c"
  readonly property color foam: root.theme ? root.theme.mix(root.cream, root.brew, 0.22) : "#e8d5b9"
  readonly property color crema: root.accent
  readonly property string serif: "serif"

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Rectangle { anchors.fill: parent; color: root.cream; opacity: Math.min(0.97, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Coffee stains and paper grain. Seeded, so a repaint doesn't reshuffle them.
  Canvas {
    anchors.fill: parent
    property color ink: root.brew
    onInkChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var stains = [[width * 0.12, height * 0.20, 70], [width * 0.88, height * 0.18, 50], [width * 0.08, height * 0.78, 90],
                    [width * 0.92, height * 0.82, 60], [width * 0.20, height * 0.55, 30]]
      var seed = 1
      for (var s = 0; s < stains.length; s++) {
        var x = stains[s][0], y = stains[s][1], r = stains[s][2] * root.u
        ctx.strokeStyle = th.rgba(root.brew, 0.18); ctx.lineWidth = 3
        ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI * 2); ctx.stroke()
        ctx.strokeStyle = th.rgba(root.brew, 0.10); ctx.lineWidth = 1.2
        ctx.beginPath(); ctx.arc(x, y, r - 7, 0, Math.PI * 2); ctx.stroke()
        for (var i = 0; i < 30; ++i) {
          ctx.fillStyle = th.rgba(root.brew, 0.04 + rnd(seed++) * 0.06)
          var a = rnd(seed++) * Math.PI * 2
          var rr = rnd(seed++) * (r - 4)
          ctx.fillRect(x + Math.cos(a) * rr, y + Math.sin(a) * rr, 2, 2)
        }
      }
      for (var g = 0; g < 800; ++g) {
        ctx.fillStyle = th.rgba(root.brew, rnd(seed++) * 0.03)
        ctx.fillRect(rnd(seed++) * width, rnd(seed++) * height, 1.5, 1.5)
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 60 * u
    spacing: 4 * u
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.title === "Omarchy" ? "the daily pour" : root.title.toLowerCase()
      color: root.brew
      font.family: root.serif; font.pixelSize: 38 * u; font.italic: true; font.weight: Font.Bold
    }
    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 80 * u; height: 1; color: root.crema }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.query.length > 0 ? "·  asking for “" + root.query + "”  ·"
        : (root.pages > 1 ? "·  batch " + (root.page + 1) + " of " + root.pages + "  ·" : "·  small batch · freshly ground  ·")
      color: root.crema
      font.family: root.serif; font.pixelSize: 12 * u; font.italic: true; font.letterSpacing: 2
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 800 * u; height: 800 * u

    Rectangle {
      anchors.centerIn: parent
      width: 260 * u; height: 260 * u; radius: 130 * u
      color: root.brew
      border.color: root.crema; border.width: 4

      Rectangle {
        anchors.centerIn: parent
        width: 230 * u; height: 230 * u; radius: 115 * u
        color: root.foam
        opacity: 0.9
      }
      Canvas {
        id: swirl
        anchors.centerIn: parent
        width: 220 * u; height: 220 * u
        property real phase: 0
        NumberAnimation on phase { from: 0; to: Math.PI * 2; duration: 18000; loops: Animation.Infinite; running: root.live }
        onPhaseChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          var th = root.theme
          if (!th) return
          ctx.translate(width / 2, height / 2)
          ctx.strokeStyle = th.rgba(root.brew, 0.55); ctx.lineWidth = 2
          ctx.beginPath()
          for (var t = 0; t < 200; ++t) {
            var r = t * 0.5 * root.u
            var a = t * 0.18 + phase
            if (t === 0) ctx.moveTo(Math.cos(a) * r, Math.sin(a) * r)
            else ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r)
          }
          ctx.stroke()
          ctx.fillStyle = th.rgba(root.brew, 0.7)
          ctx.beginPath()
          ctx.moveTo(0, 6)
          ctx.bezierCurveTo(-14, -8, -22, 8, 0, 22)
          ctx.bezierCurveTo(22, 8, 14, -8, 0, 6)
          ctx.fill()
        }
      }
      Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 80 * u
        width: 200 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label.toLowerCase() : "—"
        color: root.brew
        font.family: root.serif; font.pixelSize: 18 * u; font.italic: true; font.letterSpacing: 4; font.weight: Font.Bold
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 170 * u
      width: 360 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.current.detail ? "order:  " + root.current.detail : "") : root.emptyText().toLowerCase()
      color: root.crema
      font.family: root.serif; font.pixelSize: 12 * u; font.italic: true; font.letterSpacing: 2
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
        readonly property real angle: root.angleFor(Math.max(0, tile.slot))

        visible: tile.onPage
        width: 100 * u; height: 130 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 310 * u
        y: stage.height / 2 - height / 2 + Math.sin(angle) * 310 * u
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.14 : 1.0
        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        rotation: tile.focusedTile ? -3 : 0
        Behavior on rotation { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        Rectangle {
          id: body
          anchors.horizontalCenter: parent.horizontalCenter
          width: 86 * u; height: 96 * u; radius: 8 * u
          color: tile.focusedTile ? root.brew : root.cream
          border.color: tile.focusedTile ? root.crema : root.brew
          border.width: tile.focusedTile ? 3 : 1.5
        }
        Rectangle {
          anchors.verticalCenter: body.verticalCenter
          anchors.left: body.right; anchors.leftMargin: -4
          width: 16 * u; height: 30 * u; radius: 8 * u
          color: "transparent"
          border.color: tile.focusedTile ? root.crema : root.brew
          border.width: tile.focusedTile ? 3 : 1.5
        }
        Rectangle {
          anchors.horizontalCenter: body.horizontalCenter
          anchors.top: body.top; anchors.topMargin: 8 * u
          width: 68 * u; height: 16 * u; radius: 8 * u
          color: tile.focusedTile ? root.foam : root.brew
          opacity: 0.7
        }
        RowIcon {
          anchors.horizontalCenter: body.horizontalCenter
          anchors.verticalCenter: body.verticalCenter
          anchors.verticalCenterOffset: 6 * u
          size: 40 * u
          opacity: tile.focusedTile ? 0.95 : 0.75
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0).toLowerCase()
          color: tile.focusedTile ? root.foam : root.brew
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          width: 130 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label.toLowerCase()
          color: tile.focusedTile ? root.brew : root.crema
          font.family: root.serif; font.pixelSize: 11 * u; font.italic: true; font.letterSpacing: 2; font.weight: Font.Bold
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
    text: "tab to taste · enter to sip · type to order · backspace for the last cup · esc when full"
    color: root.crema
    font.family: root.serif; font.pixelSize: 12 * u; font.italic: true; font.letterSpacing: 2
  }
}
