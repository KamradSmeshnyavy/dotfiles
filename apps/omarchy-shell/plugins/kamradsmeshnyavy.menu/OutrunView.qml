import QtQuick
import qs.Commons

// "Outrun" from omlauch's the 80s.qml: a striped neon sun over a scrolling
// perspective grid, with a coverflow of neon cards riding the horizon. The
// pink neon is the theme accent, the grid is its cyan, the sun runs from its
// yellow through orange into the accent.
SkinBase {
  id: root

  launchDelay: 420

  readonly property real cx: width / 2
  readonly property real cy: height / 2 + 40 * u
  readonly property real horizon: height * 0.62
  readonly property real cardW: 120 * u
  readonly property real cardH: 140 * u
  readonly property color pink: root.accent
  readonly property color cyan: root.theme ? root.theme.cyan : "#2de2e6"
  readonly property color gold: root.theme ? root.theme.yellow : "#ffd319"
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.45) : "#1a0b2e"
  property real gridOff: 0

  function cardX(k) {
    if (k === 0) return 0
    var a = Math.abs(k)
    return (k > 0 ? 1 : -1) * (125 + (a - 1) * 70) * u
  }

  function navigate(dx, dy) {
    root.clampTo(root.selectedIndex + (dx !== 0 ? dx : dy))
  }

  Timer {
    interval: 50; repeat: true; running: root.live
    onTriggered: { root.gridOff = (root.gridOff + 0.012) % 1; scene.requestPaint() }
  }

  Canvas {
    id: scene
    anchors.fill: parent
    opacity: Math.max(0.6, root.backdrop)
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var t = Date.now()
      var W = width, H = height, hz = root.horizon, cx = root.cx

      var sky = ctx.createLinearGradient(0, 0, 0, hz)
      sky.addColorStop(0, th.rgba(th.mix(root.background, "#000000", 0.5), 1))
      sky.addColorStop(0.55, th.rgba(th.mix(th.magenta, root.background, 0.72), 1))
      sky.addColorStop(1, th.rgba(th.mix(th.blue, root.background, 0.25), 1))
      ctx.fillStyle = sky
      ctx.fillRect(0, 0, W, hz)

      for (var i = 0; i < 70; i++) {
        var x = ((Math.sin(i * 127.1) * 43758.5 % 1) + 1) % 1 * W
        var y = ((Math.sin(i * 311.7) * 43758.5 % 1) + 1) % 1 * hz * 0.8
        var tw = 0.3 + 0.6 * Math.abs(Math.sin(t / 800 + i * 1.7))
        ctx.fillStyle = th.rgba(root.foreground, tw)
        ctx.fillRect(x, y, 1.5, 1.5)
      }

      // Striped sun.
      var sunY = hz - H * 0.10
      var sunR = H * 0.17
      var band = th.rgba(th.mix(th.magenta, root.background, 0.72), 1)
      ctx.save()
      ctx.beginPath()
      ctx.arc(cx, sunY, sunR, 0, 6.2832)
      ctx.clip()
      var sg = ctx.createLinearGradient(0, sunY - sunR, 0, sunY + sunR)
      sg.addColorStop(0, th.rgba(root.gold, 1))
      sg.addColorStop(0.5, th.rgba(th.orange, 1))
      sg.addColorStop(1, th.rgba(root.pink, 1))
      ctx.fillStyle = sg
      ctx.fillRect(cx - sunR, sunY - sunR, sunR * 2, sunR * 2)
      ctx.fillStyle = band
      for (var s = 0; s < 6; s++) {
        var sy = sunY + s * (sunR / 4.2) + ((t / 60) % (sunR / 4.2)) - sunR / 4.2
        ctx.fillRect(cx - sunR, sy, sunR * 2, 2 + s * 1.6)
      }
      ctx.restore()
      var gg = ctx.createRadialGradient(cx, sunY, sunR * 0.4, cx, sunY, sunR * 2.2)
      gg.addColorStop(0, th.rgba(root.pink, 0.25))
      gg.addColorStop(1, th.rgba(root.pink, 0))
      ctx.fillStyle = gg
      ctx.fillRect(cx - sunR * 2.2, sunY - sunR * 2.2, sunR * 4.4, sunR * 4.4)

      // Mountains.
      var ridgeL = [[0, 0], [0.10, 0.10], [0.22, 0.03], [0.33, 0.12], [0.46, 0]]
      var ridgeR = [[0.55, 0], [0.68, 0.11], [0.80, 0.04], [0.92, 0.13], [1, 0]]
      ctx.fillStyle = th.rgba(root.deep, 1)
      var ridges = [ridgeL, ridgeR]
      for (var r = 0; r < 2; r++) {
        ctx.beginPath()
        for (var p = 0; p < ridges[r].length; p++) {
          var px = W * ridges[r][p][0], py = hz - H * ridges[r][p][1]
          if (p === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
        }
        ctx.closePath()
        ctx.fill()
      }
      ctx.strokeStyle = th.rgba(root.pink, 0.6)
      ctx.lineWidth = 1.2
      ctx.beginPath()
      for (var r2 = 0; r2 < 2; r2++) {
        for (var p2 = 0; p2 < ridges[r2].length; p2++) {
          var qx = W * ridges[r2][p2][0], qy = hz - H * ridges[r2][p2][1]
          if (p2 === 0) ctx.moveTo(qx, qy); else ctx.lineTo(qx, qy)
        }
      }
      ctx.stroke()

      var gr = ctx.createLinearGradient(0, hz, 0, H)
      gr.addColorStop(0, th.rgba(th.mix(root.background, th.magenta, 0.12), 1))
      gr.addColorStop(1, th.rgba(th.mix(root.background, "#000000", 0.6), 1))
      ctx.fillStyle = gr
      ctx.fillRect(0, hz, W, H - hz)

      ctx.fillStyle = th.rgba(root.cyan, 0.8)
      ctx.fillRect(0, hz - 1, W, 2)

      for (var g = 0; g < 16; g++) {
        var gp = (g + root.gridOff) / 16
        var gy = hz + (H - hz) * gp * gp
        ctx.strokeStyle = th.rgba(root.cyan, 0.10 + 0.45 * gp)
        ctx.lineWidth = 1 + gp * 1.5
        ctx.beginPath()
        ctx.moveTo(0, gy)
        ctx.lineTo(W, gy)
        ctx.stroke()
      }
      ctx.strokeStyle = th.rgba(root.pink, 0.22)
      ctx.lineWidth = 1
      for (var k = -14; k <= 14; k++) {
        ctx.beginPath()
        ctx.moveTo(cx + k * 26, hz)
        ctx.lineTo(cx + k * 170, H + 30)
        ctx.stroke()
      }
    }
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

  // Launch flash.
  Rectangle {
    anchors.fill: parent
    color: root.gold
    opacity: root.launching ? 0.35 : 0
    Behavior on opacity { NumberAnimation { duration: 400 } }
    z: 500
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

      readonly property int k: card.index - root.selectedIndex
      readonly property int ak: Math.abs(k)
      property bool entered: false

      width: root.cardW; height: root.cardH
      x: root.cx - root.cardW / 2 + root.cardX(k)
      y: root.cy - root.cardH / 2 + ak * 10 * u
      z: 200 - ak
      scale: (k === 0 ? (root.launching ? 1.5 : 1.16) : (ak === 1 ? 0.94 : 0.82)) * (entered ? 1 : 0.6)
      opacity: ak > 4 ? 0 : (entered ? (k === 0 ? 1 : 0.8 - ak * 0.14) : 0)
      visible: ak <= 4
      Behavior on x { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
      Behavior on y { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 340; easing.type: Easing.OutBack } }
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
        anchors.margins: -7 * u
        radius: 20 * u
        color: "transparent"
        border.color: card.k === 0 ? Util.alpha(root.pink, 0.4) : Util.alpha(root.cyan, 0.2)
        border.width: 2
      }
      Rectangle {
        anchors.fill: parent
        radius: 14 * u
        color: Util.alpha(root.deep, 0.8)
        border.color: card.k === 0 ? root.pink : root.cyan
        border.width: card.k === 0 ? 2 : 1
      }
      Rectangle {
        x: 8 * u; y: 0
        width: parent.width - 16 * u; height: 2
        color: card.k === 0 ? root.pink : root.cyan
        opacity: 0.9
      }

      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 24 * u
        size: 56 * u
        kind: card.kind
        glyph: card.icon
        glyphFont: card.iconFont
        appIcon: card.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: card.ak <= 4
        fallback: card.label.charAt(0).toUpperCase()
        color: card.k === 0 ? root.pink : root.cyan
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 92 * u
        width: 110 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: card.label
        color: card.k === 0 ? root.foreground : Util.alpha(root.foreground, 0.7)
        font.family: root.fontFamily
        font.pixelSize: 11 * u
        font.bold: card.k === 0
      }
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 114 * u
        width: 30 * u; height: 4 * u; radius: 2 * u
        color: card.k === 0 ? root.pink : Util.alpha(root.foreground, 0.2)
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

  // Chrome title: a pink shadow under the bright face.
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.cy + 108 * u
    textFormat: Text.PlainText
    text: root.current ? root.current.label.toUpperCase() : "NO SIGNAL"
    color: root.pink
    font.family: root.fontFamily
    font.pixelSize: 26 * u
    font.bold: true
    font.italic: true
    opacity: 0.6
    z: 300
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.cy + 105 * u
    textFormat: Text.PlainText
    text: root.current ? root.current.label.toUpperCase() : "NO SIGNAL"
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: 26 * u
    font.bold: true
    font.italic: true
    z: 301
  }

  // Neon search pill.
  Rectangle {
    x: root.cx - 210 * u; y: 36 * u
    width: 420 * u; height: 50 * u
    radius: 25 * u
    color: Util.alpha(root.deep, 0.67)
    border.color: root.query.length > 0 ? root.pink : root.cyan
    border.width: 1
    z: 300
    Rectangle {
      anchors.fill: parent
      anchors.margins: -5 * u
      radius: 30 * u
      color: "transparent"
      border.color: root.query.length > 0 ? Util.alpha(root.pink, 0.27) : Util.alpha(root.cyan, 0.2)
      border.width: 2
    }
    Text {
      x: 24 * u; anchors.verticalCenter: parent.verticalCenter
      text: "»"
      color: root.gold
      font.pixelSize: 18 * u
    }
    QueryText {
      x: 48 * u; anchors.verticalCenter: parent.verticalCenter
      width: 300 * u
      query: root.query
      placeholder: root.subtitle.length > 0 ? root.subtitle.toLowerCase() + "…" : "search the grid…"
      color: root.foreground
      placeholderColor: root.dim
      caretColor: root.pink
      fontFamily: root.fontFamily
      pixelSize: 15 * u
      live: root.live
    }
    Text {
      anchors.right: parent.right
      anchors.rightMargin: 24 * u
      anchors.verticalCenter: parent.verticalCenter
      text: root.count > 0 ? (root.selectedIndex + 1) + "/" + root.count : "0"
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: 11 * u
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 32 * u
    text: "← → / wheel = cruise · hover = focus · click / ↵ = launch · ⌫ = back · esc = jack out"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 11 * u
    opacity: 0.85
    z: 300
  }
}
