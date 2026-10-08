import QtQuick
import qs.Commons

// "Aurora Coverflow" from omlauch's card.qml: a frosted-glass deck of cards
// over drifting aurora blobs. The blobs take the theme's accent, magenta and
// cyan, and the glass is the theme's foreground at low alpha, so it reads on
// light themes as well as dark ones.
SkinBase {
  id: root

  launchDelay: 420

  readonly property real cx: width / 2
  readonly property real cy: height / 2 + 30 * u
  readonly property real cardW: 120 * u
  readonly property real cardH: 140 * u
  readonly property color glass: root.foreground
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color glow: root.accent

  function cardX(k) {
    if (k === 0) return 0
    var a = Math.abs(k)
    return (k > 0 ? 1 : -1) * (120 + (a - 1) * 68) * u
  }

  function navigate(dx, dy) {
    root.clampTo(root.selectedIndex + (dx !== 0 ? dx : dy))
  }

  Rectangle {
    anchors.fill: parent
    color: root.theme ? root.theme.mix(root.background, "#000000", 0.25) : root.background
    opacity: root.backdrop
  }

  // Aurora: three slow blobs and a drift of rising motes.
  Canvas {
    id: aurora
    anchors.fill: parent
    property var blobColors: root.theme ? [root.theme.rgb(root.theme.magenta), root.theme.rgb(root.accent), root.theme.rgb(root.theme.cyan)] : ["124,58,237", "236,72,153", "34,211,238"]
    property string mote: root.theme ? root.theme.rgb(root.foreground) : "244,247,255"
    onBlobColorsChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var t = Date.now()
      var W = width, H = height
      var blobs = [
        [0.25 + 0.06 * Math.sin(t / 9000), 0.30 + 0.05 * Math.cos(t / 11000), 0.55, blobColors[0]],
        [0.75 + 0.05 * Math.cos(t / 8000), 0.65 + 0.06 * Math.sin(t / 10000), 0.60, blobColors[1]],
        [0.55 + 0.07 * Math.sin(t / 12000), 0.15 + 0.04 * Math.cos(t / 9000), 0.45, blobColors[2]]
      ]
      for (var b = 0; b < blobs.length; b++) {
        var bx = blobs[b][0] * W, by = blobs[b][1] * H
        var br = blobs[b][2] * Math.min(W, H)
        var g = ctx.createRadialGradient(bx, by, 0, bx, by, br)
        g.addColorStop(0, "rgba(" + blobs[b][3] + ",0.20)")
        g.addColorStop(1, "rgba(" + blobs[b][3] + ",0)")
        ctx.fillStyle = g
        ctx.fillRect(0, 0, W, H)
      }
      for (var i = 0; i < 40; i++) {
        var x = (Math.sin(i * 127.1) * 43758.5 % 1 + 1) % 1 * W
        var y = ((Math.sin(i * 311.7) * 43758.5 % 1 + 1) % 1 * H + t * 0.008 * (0.4 + (i % 5) * 0.2)) % H
        ctx.beginPath()
        ctx.arc(x, H - y, 1 + (i % 3) * 0.6, 0, 6.2832)
        ctx.fillStyle = "rgba(" + mote + "," + (0.06 + (i % 4) * 0.04) + ")"
        ctx.fill()
      }
    }
    Timer { interval: 120; repeat: true; running: root.live; onTriggered: aurora.requestPaint() }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    property real pressX: 0
    property bool dragged: false
    onPressed: function(mouse) { pressX = mouse.x; dragged = false }
    onPositionChanged: function(mouse) {
      if (!pressed) return
      var dx = mouse.x - pressX
      if (Math.abs(dx) > 6) dragged = true
      var steps = Math.floor(Math.abs(dx) / (90 * u))
      if (steps > 0) {
        root.clampTo(root.selectedIndex + (dx < 0 ? steps : -steps))
        pressX = mouse.x
      }
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else if (!dragged && Math.abs(mouse.y - root.cy) > 220 * u) root.dismissRequested()
    }
  }

  // Launch ring.
  Rectangle {
    x: root.cx - 70 * u; y: root.cy - 80 * u
    width: 140 * u; height: 160 * u
    radius: 22 * u
    color: "transparent"
    border.color: Util.alpha(root.glow, 0.67)
    border.width: 2
    scale: root.launching ? 3.2 : 0.6
    opacity: root.launching ? 0 : (root.count > 0 ? 0.9 : 0)
    Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 450 } }
    z: 400
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: card

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label
      required property string detail

      readonly property int k: card.index - root.selectedIndex
      readonly property int ak: Math.abs(k)
      property bool entered: false

      width: root.cardW; height: root.cardH
      x: root.cx - root.cardW / 2 + root.cardX(k)
      y: root.cy - root.cardH / 2 + ak * 8 * u
      z: 200 - ak
      scale: (k === 0 ? 1.14 : (ak === 1 ? 0.94 : 0.82)) * (entered ? 1 : 0.6)
      opacity: ak > 4 ? 0 : (entered ? (k === 0 ? 1 : 0.75 - ak * 0.12) : 0)
      visible: ak <= 4
      Behavior on x { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
      Behavior on y { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: root.launching && card.k === 0 ? 420 : 340; easing.type: root.launching && card.k === 0 ? Easing.OutCubic : Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 300 } }
      transform: Rotation {
        origin.x: root.cardW / 2; origin.y: root.cardH / 2
        axis { x: 0; y: 1; z: 0 }
        angle: card.k === 0 ? 0 : (card.k > 0 ? -44 : 44)
        Behavior on angle { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
      }
      Component.onCompleted: entered = true

      Rectangle {
        anchors.fill: parent
        anchors.margins: -10 * u
        radius: 26 * u
        color: root.glow
        opacity: card.k === 0 ? 0.16 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
      }
      Rectangle {
        anchors.fill: parent
        radius: 18 * u
        color: Util.alpha(root.glass, card.k === 0 ? 0.19 : 0.11)
        border.color: card.k === 0 ? Util.alpha(root.glow, 0.4) : Util.alpha(root.glass, 0.15)
        border.width: 1
      }
      Rectangle {
        x: 10 * u; y: 1
        width: parent.width - 20 * u; height: 1
        color: Util.alpha(root.glass, 0.33)
      }

      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 22 * u
        size: 56 * u
        kind: card.kind
        glyph: card.icon
        glyphFont: card.iconFont
        appIcon: card.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: card.ak <= 4
        fallback: card.label.charAt(0).toUpperCase()
        color: card.k === 0 ? root.glow : root.foreground
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 90 * u
        width: 110 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: card.label
        color: card.k === 0 ? root.foreground : Util.alpha(root.foreground, 0.7)
        font.family: root.fontFamily
        font.pixelSize: 12 * u
        font.bold: card.k === 0
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 110 * u
        width: Math.min(110 * u, tag.implicitWidth + 14 * u); height: 16 * u
        radius: 8 * u
        color: Util.alpha(root.glow, 0.08)
        border.color: Util.alpha(root.glow, 0.2)
        Text {
          id: tag
          anchors.centerIn: parent
          width: Math.min(implicitWidth, 100 * u)
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.isBranch(card.kind) ? "menu ›" : (card.kind === "app" ? "app" : "action")
          color: root.glow
          font.family: root.fontFamily
          font.pixelSize: 9 * u
        }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (card.k === 0) root.activated(card.index)
          else root.selectRequested(card.index)
        }
        onEntered: if (card.ak <= 2 && card.ak > 0) root.selectRequested(card.index)
      }
    }
  }

  // Big name under the deck.
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.cy + 110 * u
    width: parent.width * 0.8
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    textFormat: Text.PlainText
    text: root.current ? root.current.label : root.emptyText()
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: 26 * u
    font.bold: true
    opacity: 0.95
    z: 300
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.cy + 142 * u
    width: parent.width * 0.7
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    textFormat: Text.PlainText
    text: root.current ? root.current.detail : ""
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 12 * u
    z: 300
  }

  // Glass search bar.
  Rectangle {
    x: root.cx - 210 * u; y: 40 * u
    width: 420 * u; height: 52 * u
    radius: 26 * u
    color: Util.alpha(root.glass, 0.1)
    border.color: root.query.length > 0 ? Util.alpha(root.glow, 0.4) : Util.alpha(root.glass, 0.15)
    border.width: 1
    z: 300
    Text {
      x: 24 * u
      anchors.verticalCenter: parent.verticalCenter
      text: "⌕"
      color: root.glow
      font.pixelSize: 20 * u
    }
    QueryText {
      x: 52 * u
      anchors.verticalCenter: parent.verticalCenter
      width: 300 * u
      query: root.query
      placeholder: root.subtitle.length > 0 ? root.subtitle + "…" : "Search " + root.title + "…"
      color: root.foreground
      placeholderColor: root.dim
      caretColor: root.glow
      fontFamily: root.fontFamily
      pixelSize: 15 * u
      live: root.live
    }
    Text {
      anchors.right: parent.right
      anchors.rightMargin: 22 * u
      anchors.verticalCenter: parent.verticalCenter
      text: root.count > 0 ? (root.selectedIndex + 1) + "/" + root.count : "0"
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: 11 * u
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 34 * u
    text: "← → / wheel / drag = flip deck · hover = focus · click / ↵ = open · ⌫ = back · esc close"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 11 * u
    opacity: 0.8
    z: 300
  }
}
