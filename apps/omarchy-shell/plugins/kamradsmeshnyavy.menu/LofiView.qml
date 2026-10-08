import QtQuick
import qs.Commons

// "Lo-Fi Studio" from omlauch's lazy.qml: a bedroom at night with rain on the
// window, a sleeping cat, a steaming mug and a turntable that spins whatever
// row is selected. The rows are the tracklist. The warm amber is the theme
// accent, the room is the theme background warmed with its brown, the city
// bokeh uses its hues.
SkinBase {
  id: root

  launchDelay: 600

  readonly property real wx: 50 * u
  readonly property real wy: 70 * u
  readonly property real ww: width * 0.36
  readonly property real wh: height - 250 * u
  readonly property real px: width * 0.56
  readonly property real py: height * 0.54
  readonly property real pr: Math.min(150 * u, height * 0.22)

  readonly property color amber: root.accent
  readonly property color cream: root.foreground
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color wood: root.theme ? root.theme.mix(root.background, root.theme.brown, 0.55) : "#3a2a1c"
  readonly property color room: root.theme ? root.theme.mix(root.background, root.theme.brown, 0.12) : "#1a1410"

  property real spin: 0
  property real spinV: 0.02
  property real armA: -0.35
  readonly property real armTarget: root.launching ? -0.85 : -0.30 - (root.selectedIndex % 6) * 0.035
  property var rain: []
  property var parts: []

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    root.spinV = 0.16
    for (var k = 0; k < 14; k++)
      root.parts.push({ x: root.px + (Math.random() - 0.5) * 60, y: root.py + (Math.random() - 0.5) * 60,
                        vx: (Math.random() - 0.5) * 2, vy: -Math.random() * 1.5, t0: Date.now(), life: 400 + Math.random() * 300 })
  }

  onWoke: root.spinV = 0.02

  Component.onCompleted: {
    var r = []
    for (var i = 0; i < 26; i++) r.push({ x: Math.random() * 2000, y: Math.random() * 1000, v: 2 + Math.random() * 3 })
    root.rain = r
  }

  Timer {
    interval: 60; repeat: true; running: root.live
    onTriggered: {
      root.spin += root.spinV
      root.armA += (root.armTarget - root.armA) * 0.12
      for (var i = 0; i < root.rain.length; i++) {
        var d = root.rain[i]
        d.y += d.v
        if (d.y > root.wh) { d.y = -20; d.x = Math.random() * root.ww; d.v = 2 + Math.random() * 3 }
      }
      fx.requestPaint()
    }
  }

  // The room: walls, the window onto a night city, lamp glow, turntable deck.
  Canvas {
    id: roomCanvas
    anchors.fill: parent
    opacity: Math.max(0.6, root.backdrop)
    property var key: [root.room, root.wood, root.amber, root.theme ? root.theme.hues : []]
    onKeyChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    function rnd2(i, s) { var x = Math.sin(i * 91.7 + s * 47.3) * 24634.6345; return x - Math.floor(x) }
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var W = width, H = height
      var g = ctx.createLinearGradient(0, 0, 0, H)
      g.addColorStop(0, th.rgba(th.mix(root.room, th.brown, 0.1), 1))
      g.addColorStop(1, th.rgba(th.mix(root.room, "#000000", 0.45), 1))
      ctx.fillStyle = g
      ctx.fillRect(0, 0, W, H)

      ctx.fillStyle = th.rgba(th.mix(root.background, th.blue, 0.08), 1)
      ctx.fillRect(root.wx, root.wy, root.ww, root.wh)
      ctx.save()
      ctx.beginPath()
      ctx.rect(root.wx, root.wy, root.ww, root.wh)
      ctx.clip()
      var bokeh = [th.orange, th.cyan, th.yellow, th.magenta, th.green]
      for (var i = 0; i < 16; i++) {
        var bx = root.wx + rnd2(i, 1) * root.ww
        var by = root.wy + root.wh * 0.35 + rnd2(i, 2) * root.wh * 0.6
        var br = 8 + rnd2(i, 3) * 22
        var bg = ctx.createRadialGradient(bx, by, 0, bx, by, br)
        bg.addColorStop(0, th.rgba(bokeh[i % 5], 0.27))
        bg.addColorStop(1, th.rgba(bokeh[i % 5], 0))
        ctx.fillStyle = bg
        ctx.fillRect(bx - br, by - br, br * 2, br * 2)
      }
      ctx.restore()
      ctx.strokeStyle = th.rgba(root.wood, 1)
      ctx.lineWidth = 8
      ctx.strokeRect(root.wx - 4, root.wy - 4, root.ww + 8, root.wh + 8)
      ctx.fillStyle = th.rgba(th.mix(root.wood, root.foreground, 0.08), 1)
      ctx.fillRect(root.wx - 14, root.wy + root.wh + 4, root.ww + 28, 12)

      var lg = ctx.createRadialGradient(W - 120, 140, 0, W - 120, 140, 300)
      lg.addColorStop(0, th.rgba(root.amber, 0.16))
      lg.addColorStop(1, th.rgba(root.amber, 0))
      ctx.fillStyle = lg
      ctx.fillRect(W - 420, 0, 420, 440)

      ctx.fillStyle = th.rgba(th.mix(root.room, root.wood, 0.5), 1)
      ctx.fillRect(root.px - root.pr - 40, root.py - root.pr - 30, (root.pr + 40) * 2, (root.pr + 30) * 2)
      ctx.strokeStyle = th.rgba(root.wood, 1)
      ctx.lineWidth = 2
      ctx.strokeRect(root.px - root.pr - 40, root.py - root.pr - 30, (root.pr + 40) * 2, (root.pr + 30) * 2)
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

  // The selected row's icon, drawn onto the spinning label.
  Image {
    id: selImage
    visible: false
    source: root.current && root.current.kind === "app" && root.iconResolver ? root.iconResolver(root.current.appIcon) : ""
    sourceSize: Qt.size(96, 96)
    asynchronous: false
    onStatusChanged: fx.requestPaint()
  }

  // The living layer: rain, cat, steam, vinyl, tonearm, VU.
  Canvas {
    id: fx
    anchors.fill: parent
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var t = Date.now()
      var u = root.u

      ctx.save()
      ctx.beginPath()
      ctx.rect(root.wx, root.wy, root.ww, root.wh)
      ctx.clip()
      ctx.strokeStyle = th.rgba(th.blue, 0.35)
      ctx.lineWidth = 1.2
      for (var i = 0; i < root.rain.length; i++) {
        var d = root.rain[i]
        var x = root.wx + (d.x % root.ww) + Math.sin(d.y / 30 + i) * 2
        ctx.beginPath()
        ctx.moveTo(x, root.wy + d.y)
        ctx.lineTo(x - 1.5, root.wy + d.y + 10 + d.v * 2)
        ctx.stroke()
      }
      ctx.restore()

      // Cat on the sill.
      var shadow = th.rgba(th.mix(root.background, "#000000", 0.7), 1)
      var sillY = root.wy + root.wh + 4
      var cx2 = root.wx + root.ww * 0.68
      ctx.fillStyle = shadow
      ctx.beginPath(); ctx.ellipse(cx2, sillY - 12, 30, 14, 0, 0, 6.2832); ctx.fill()
      ctx.beginPath(); ctx.arc(cx2 + 24, sillY - 22, 12, 0, 6.2832); ctx.fill()
      ctx.beginPath()
      ctx.moveTo(cx2 + 16, sillY - 30); ctx.lineTo(cx2 + 20, sillY - 40); ctx.lineTo(cx2 + 25, sillY - 31)
      ctx.moveTo(cx2 + 27, sillY - 31); ctx.lineTo(cx2 + 32, sillY - 40); ctx.lineTo(cx2 + 35, sillY - 29)
      ctx.fill()
      var tail = Math.sin(t / 900) * 0.5
      ctx.strokeStyle = shadow
      ctx.lineWidth = 5
      ctx.beginPath()
      ctx.moveTo(cx2 - 28, sillY - 10)
      ctx.quadraticCurveTo(cx2 - 46, sillY - 18 + tail * 10, cx2 - 40, sillY - 34 + tail * 14)
      ctx.stroke()
      ctx.font = "10px sans-serif"
      ctx.fillStyle = th.rgba(root.cream, 0.3 + 0.2 * Math.sin(t / 700))
      ctx.fillText("z", cx2 + 40, sillY - 44 - (t / 40 % 12))
      ctx.fillText("z", cx2 + 48, sillY - 56 - (t / 40 % 12))

      // Mug and steam.
      var mx = root.wx + root.ww * 0.22, my = sillY - 2
      ctx.fillStyle = th.rgba(th.orange, 1)
      ctx.fillRect(mx - 10, my - 18, 20, 18)
      ctx.strokeStyle = th.rgba(th.orange, 1)
      ctx.lineWidth = 3
      ctx.beginPath(); ctx.arc(mx + 13, my - 9, 5, -1.2, 1.2); ctx.stroke()
      ctx.strokeStyle = th.rgba(root.cream, 0.14)
      ctx.lineWidth = 2
      for (var k = 0; k < 3; k++) {
        ctx.beginPath()
        for (var s = 0; s <= 8; s++) {
          var yy = my - 22 - s * 6
          var xx = mx - 6 + k * 6 + Math.sin(t / 600 + s * 0.7 + k * 2) * 4
          if (s === 0) ctx.moveTo(xx, yy); else ctx.lineTo(xx, yy)
        }
        ctx.stroke()
      }

      // The vinyl.
      var px = root.px, py = root.py, pr = root.pr
      ctx.beginPath(); ctx.arc(px, py, pr, 0, 6.2832)
      ctx.fillStyle = th.rgba(th.mix(root.background, "#000000", 0.75), 1)
      ctx.fill()
      ctx.strokeStyle = th.rgba(th.mix(root.background, root.foreground, 0.1), 1)
      for (var g2 = 1; g2 < 7; g2++) {
        ctx.beginPath(); ctx.arc(px, py, pr * (0.45 + g2 * 0.085), 0, 6.2832)
        ctx.lineWidth = 1; ctx.stroke()
      }
      ctx.save()
      ctx.translate(px, py)
      ctx.rotate(t / 3000)
      var sh = ctx.createLinearGradient(-pr, -pr, pr, pr)
      sh.addColorStop(0.42, "rgba(255,255,255,0)")
      sh.addColorStop(0.5, "rgba(255,255,255,0.07)")
      sh.addColorStop(0.58, "rgba(255,255,255,0)")
      ctx.fillStyle = sh
      ctx.fillRect(-pr, -pr, pr * 2, pr * 2)
      ctx.restore()

      ctx.save()
      ctx.translate(px, py)
      ctx.rotate(root.spin)
      ctx.beginPath(); ctx.arc(0, 0, pr * 0.38, 0, 6.2832)
      ctx.fillStyle = th.rgba(root.amber, 1)
      ctx.fill()
      var row = root.current
      if (row && row.kind === "app" && selImage.status === Image.Ready) {
        ctx.save()
        ctx.beginPath(); ctx.arc(0, 0, pr * 0.30, 0, 6.2832); ctx.clip()
        ctx.drawImage(selImage, -pr * 0.28, -pr * 0.28, pr * 0.56, pr * 0.56)
        ctx.restore()
      } else if (row) {
        ctx.font = Math.round(pr * 0.34) + "px \"" + (row.iconFont || root.fontFamily) + "\""
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillStyle = th.rgba(th.ink(root.amber), 1)
        ctx.fillText(row.icon || row.label.charAt(0).toUpperCase(), 0, 0)
      }
      ctx.beginPath(); ctx.arc(0, 0, 3, 0, 6.2832)
      ctx.fillStyle = th.rgba(th.mix(root.background, "#000000", 0.5), 1)
      ctx.fill()
      ctx.restore()

      // Tonearm.
      var pivX = px + pr + 26, pivY = py - pr - 12
      ctx.save()
      ctx.translate(pivX, pivY)
      ctx.rotate(root.armA)
      ctx.strokeStyle = th.rgba(th.mix(root.foreground, root.background, 0.2), 1)
      ctx.lineWidth = 4
      ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(-pr * 1.15, pr * 0.75); ctx.stroke()
      ctx.fillStyle = th.rgba(th.mix(root.foreground, root.background, 0.45), 1)
      ctx.fillRect(-pr * 1.15 - 5, pr * 0.75 - 4, 12, 10)
      ctx.restore()
      ctx.beginPath(); ctx.arc(pivX, pivY, 9, 0, 6.2832)
      ctx.fillStyle = th.rgba(th.mix(root.background, root.foreground, 0.25), 1)
      ctx.fill()

      for (var pi = root.parts.length - 1; pi >= 0; pi--) {
        var p = root.parts[pi]
        var age = t - p.t0
        if (age > p.life) { root.parts.splice(pi, 1); continue }
        p.x += p.vx; p.y += p.vy
        ctx.fillStyle = th.rgba(root.cream, 1 - age / p.life)
        ctx.fillRect(p.x, p.y, 2, 2)
      }

      for (var v = 0; v < 2; v++) {
        var vx = root.px - 46 + v * 52, vy = root.py + root.pr + 26
        ctx.fillStyle = th.rgba(th.mix(root.background, "#000000", 0.4), 1)
        ctx.fillRect(vx, vy, 40, 10)
        var lvl = 8 + Math.abs(Math.sin(t / (180 + v * 70) + v)) * 30
        ctx.fillStyle = th.rgba(lvl > 30 ? th.orange : root.amber, 1)
        ctx.fillRect(vx + 1, vy + 1, lvl, 8)
      }

      ctx.font = "italic " + Math.round(13 * u) + "px sans-serif"
      ctx.textAlign = "center"
      ctx.textBaseline = "alphabetic"
      ctx.fillStyle = th.rgba(root.cream, 0.8)
      ctx.fillText("now spinning: " + (row ? row.label : "—"), root.px, root.py + root.pr + 56)
    }
  }

  // Tracklist.
  Text {
    x: root.width - 320 * u; y: 96 * u
    textFormat: Text.PlainText
    text: "SIDE A · " + root.title.toUpperCase() + " · " + root.count + " TRACKS"
    color: root.dim
    font.family: root.mono
    font.pixelSize: 10 * u
  }

  ListView {
    id: tracks
    x: root.width - 330 * u
    y: 120 * u
    width: 300 * u
    height: Math.min(11, Math.max(1, Math.floor((root.height - 200 * u) / (46 * u)))) * 46 * u
    model: root.rowModel
    spacing: 4 * u
    clip: true
    interactive: false
    highlightMoveDuration: 180
    currentIndex: root.selectedIndex
    preferredHighlightBegin: height / 2 - 23 * u
    preferredHighlightEnd: height / 2 + 23 * u
    highlightRangeMode: ListView.ApplyRange

    delegate: Item {
      id: track

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property bool selHere: root.cursorActive && track.index === root.selectedIndex

      width: tracks.width
      height: 42 * u

      Rectangle {
        anchors.fill: parent
        radius: 8 * u
        color: track.selHere ? Util.alpha(root.amber, 0.14) : "transparent"
      }
      Rectangle {
        visible: track.selHere
        x: 0; y: 8 * u
        width: 3; height: 26 * u
        radius: 2
        color: root.amber
      }
      Text {
        x: 12 * u; anchors.verticalCenter: parent.verticalCenter
        text: track.selHere ? "▶" : String(track.index + 1).padStart(2, "0")
        color: track.selHere ? root.amber : root.dim
        font.family: root.mono
        font.pixelSize: 10 * u
      }
      RowIcon {
        x: 36 * u; anchors.verticalCenter: parent.verticalCenter
        size: 26 * u
        kind: track.kind
        glyph: track.icon
        glyphFont: track.iconFont
        appIcon: track.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        fallback: track.label.charAt(0).toUpperCase()
        color: track.selHere ? root.amber : root.cream
      }
      Text {
        x: 70 * u; anchors.verticalCenter: parent.verticalCenter
        width: 170 * u
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: track.label
        color: track.selHere ? root.cream : Util.alpha(root.cream, 0.72)
        font.family: root.fontFamily
        font.pixelSize: 12 * u
        font.bold: track.selHere
      }
      Text {
        x: 252 * u; anchors.verticalCenter: parent.verticalCenter
        text: root.isBranch(track.kind) ? "side ›" : "3:" + String(10 + (track.index * 7) % 50)
        color: root.dim
        font.family: root.mono
        font.pixelSize: 10 * u
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(track.index)
        onClicked: root.activated(track.index)
      }
    }
  }

  Text {
    visible: root.count === 0
    x: root.width - 330 * u; y: 130 * u
    width: 300 * u
    wrapMode: Text.WordWrap
    textFormat: Text.PlainText
    text: root.query.length > 0 ? "nothing in the crate for “" + root.query + "”" : "the crate is empty"
    color: root.dim
    font.family: root.fontFamily
    font.italic: true
    font.pixelSize: 12 * u
  }

  // Search the crate.
  Rectangle {
    x: root.width / 2 - 180 * u; y: 20 * u
    width: 360 * u; height: 40 * u
    radius: 20 * u
    color: Util.alpha(root.room, 0.87)
    border.color: root.query.length > 0 ? root.amber : root.wood
    QueryText {
      anchors.centerIn: parent
      width: 310 * u
      height: parent.height
      alignment: Text.AlignHCenter
      query: root.query
      placeholder: root.subtitle.length > 0 ? root.subtitle.toLowerCase() + "…" : "search the crate…"
      color: root.cream
      placeholderColor: root.dim
      caretColor: root.amber
      fontFamily: root.fontFamily
      pixelSize: 13 * u
      live: root.live
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 30 * u
    text: "hover a track = tonearm swings · click / ↵ = drop the needle · wheel / ↑↓ = flip tracks · ⌫ = back · esc = lights out"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 10 * u
    font.italic: true
    opacity: 0.9
  }
}
