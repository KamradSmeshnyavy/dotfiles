import QtQuick
import qs.Commons

// "Candy Pop" from omlauch's ta da !!.qml: rows as candy bubbles on a
// polka-dot sky, balloons drifting up, a mascot cat that watches the pointer
// and jumps when something is popped, confetti everywhere. The candy colours
// are the theme's hues and the sky is its background tinted with them, so a
// dark theme throws a night party instead of a blinding one.
SkinBase {
  id: root

  launchDelay: 650

  readonly property real pitchX: 128 * u
  readonly property real pitchY: 132 * u
  readonly property int cols: Math.max(4, Math.min(8, Math.floor((width - 100 * u) / pitchX)))
  readonly property int visibleRows: Math.max(1, Math.floor((height - 170 * u - 200 * u) / pitchY))
  readonly property int perPage: root.cols * root.visibleRows
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.perPage)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.perPage))
  readonly property int pageStart: root.page * root.perPage
  readonly property real ox: (width - (cols * pitchX - 12 * u)) / 2
  readonly property real oy: 170 * u

  readonly property var candy: root.theme ? root.theme.hues : ["#ff6b8a", "#ffb347", "#ffe066", "#69db7c", "#4dabf7", "#b197fc", "#f783ac", "#63e6be"]
  readonly property color ink: root.foreground
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color bubble: root.theme ? root.theme.mix(root.background, root.foreground, 0.08) : "#ffffff"

  property int frame: 0
  property var parts: []
  property real jumpT: -9999

  function rnd(i, s) { var x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453; return x - Math.floor(x) }

  function confettiBurst(x, y, n) {
    for (var k = 0; k < n; k++) {
      var a = -1.5708 + (Math.random() - 0.5) * 2.4
      var sp = 4 + Math.random() * 8
      root.parts.push({ x: x, y: y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp,
                        rot: Math.random() * 6.28, vr: (Math.random() - 0.5) * 0.4,
                        col: Math.floor(Math.random() * root.candy.length),
                        t0: Date.now(), life: 900 + Math.random() * 900,
                        sz: 4 + Math.random() * 5, round: Math.random() < 0.4 })
    }
  }

  function navigate(dx, dy) {
    if (dx !== 0) root.step(dx)
    else root.clampTo(root.selectedIndex + dy * root.cols)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    root.jumpT = Date.now()
    var slot = index - root.pageStart
    root.confettiBurst(root.ox + (slot % root.cols) * root.pitchX + 60 * u,
                       root.oy + Math.floor(slot / root.cols) * root.pitchY + 60 * u, 40)
  }

  onWoke: { root.parts = []; root.confettiBurst(root.width / 2, 120 * u, 60) }
  Component.onCompleted: root.confettiBurst(width / 2, 120 * u, 60)

  Timer { interval: 40; repeat: true; running: root.live; onTriggered: { root.frame++; fx.requestPaint() } }

  // Candy sky.
  Canvas {
    anchors.fill: parent
    opacity: Math.max(0.6, root.backdrop)
    property var key: [root.background, root.candy]
    onKeyChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var g = ctx.createLinearGradient(0, 0, width, height)
      g.addColorStop(0, th.rgba(th.mix(root.background, th.red, 0.14), 1))
      g.addColorStop(0.5, th.rgba(th.mix(root.background, th.yellow, 0.1), 1))
      g.addColorStop(1, th.rgba(th.mix(root.background, th.cyan, 0.14), 1))
      ctx.fillStyle = g
      ctx.fillRect(0, 0, width, height)
      ctx.fillStyle = th.rgba(root.foreground, th.light ? 0.25 : 0.06)
      for (var y = 0, r = 0; y < height + 40; y += 46, r++) {
        for (var x = (r % 2) * 23; x < width + 40; x += 46) {
          ctx.beginPath(); ctx.arc(x, y, 3, 0, 6.2832); ctx.fill()
        }
      }
      for (var i = 0; i < 6; i++) {
        ctx.beginPath()
        ctx.arc(-60, -60, 190 + i * 14, 0, 1.5708)
        ctx.strokeStyle = th.rgba(root.candy[i % root.candy.length], 0.33)
        ctx.lineWidth = 10
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

  // The mascot watches the pointer wherever it is.
  HoverHandler { id: hover }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: bub

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: bub.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.perPage
      readonly property bool selHere: root.cursorActive && bub.index === root.selectedIndex
      readonly property color myCol: root.candy[bub.index % root.candy.length] || root.accent
      readonly property bool popped: root.launching && root.launchIndex === bub.index
      property bool entered: false

      visible: bub.onPage
      x: root.ox + (Math.max(0, slot) % root.cols) * root.pitchX
      y: root.oy + Math.floor(Math.max(0, slot) / root.cols) * root.pitchY
      width: 120 * u; height: 126 * u
      rotation: (root.rnd(bub.index, 9) - 0.5) * 8
      scale: popped ? 1.6 : (entered ? (selHere ? 1.14 : 1) : 0)
      opacity: popped ? 0 : 1
      Behavior on scale { NumberAnimation { duration: bub.selHere ? 220 : 420; easing.type: Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 260 } }
      Timer {
        id: enterTimer
        interval: root.burst ? 40 * Math.min(Math.max(0, bub.slot), 24) : 0
        running: true
        onTriggered: bub.entered = true
      }
      Connections {
        target: root
        function onWoke() { bub.entered = false; enterTimer.restart() }
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: 96 * u; height: 96 * u
        radius: 48 * u
        color: root.bubble
        border.color: bub.myCol
        border.width: bub.selHere ? 5 : 3
        Rectangle {
          x: 16 * u; y: 12 * u
          width: 26 * u; height: 16 * u
          radius: 10 * u
          rotation: -25
          color: Util.alpha("#ffffff", 0.3)
        }
      }
      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 22 * u
        size: 52 * u
        kind: bub.kind
        glyph: bub.icon
        glyphFont: bub.iconFont
        appIcon: bub.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: bub.onPage
        fallback: bub.label.charAt(0).toUpperCase()
        color: bub.myCol
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 100 * u
        width: 116 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: bub.label
        color: root.ink
        font.family: root.fontFamily
        font.pixelSize: 11 * u
        font.bold: bub.selHere
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(bub.index)
        onClicked: root.activated(bub.index)
      }
    }
  }

  // Balloons, the mascot, confetti and the WOOHOO stamp.
  Canvas {
    id: fx
    anchors.fill: parent
    z: 500
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var t = Date.now()
      var W = width, H = height
      var inkS = th.rgba(root.ink, 1)

      for (var i = 0; i < 5; i++) {
        var speed = 0.02 + root.rnd(i, 1) * 0.02
        var by = H + 80 - ((t * speed + root.rnd(i, 2) * (H + 200)) % (H + 200))
        var bx = root.rnd(i, 3) * W + Math.sin(t / 1500 + i * 2) * 30
        ctx.strokeStyle = th.rgba(root.ink, 0.25)
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.moveTo(bx, by + 26)
        ctx.quadraticCurveTo(bx + Math.sin(t / 700 + i) * 6, by + 50, bx, by + 70)
        ctx.stroke()
        ctx.beginPath(); ctx.ellipse(bx, by, 20, 25, 0, 0, 6.2832)
        ctx.fillStyle = th.rgba(root.candy[i % root.candy.length], 0.8)
        ctx.fill()
        ctx.beginPath(); ctx.ellipse(bx - 7, by - 9, 5, 8, -0.5, 0, 6.2832)
        ctx.fillStyle = "rgba(255,255,255,0.5)"
        ctx.fill()
      }

      // Mascot cat, bottom centre.
      var jt = t - root.jumpT
      var jump = jt < 600 ? Math.sin(jt / 600 * Math.PI) * 46 : 0
      var mx = W / 2, my = H - 150 * root.u - jump
      var blink = (t % 3200) < 140
      var px = hover.hovered ? hover.point.position.x : mx
      var py = hover.hovered ? hover.point.position.y : my - 100
      var la = Math.atan2(py - my, px - mx)
      var lx = Math.cos(la) * 4, ly = Math.sin(la) * 3
      var fur = th.mix(th.yellow, th.orange, 0.3)
      ctx.save()
      ctx.translate(mx, my)
      var squash = jt < 600 ? 1 + Math.sin(jt / 600 * Math.PI) * 0.12 : 1 + Math.sin(t / 600) * 0.02
      ctx.scale(2 - squash, squash)
      ctx.fillStyle = th.rgba(th.orange, 1)
      ctx.beginPath(); ctx.moveTo(-34, -34); ctx.lineTo(-22, -62); ctx.lineTo(-8, -40); ctx.closePath(); ctx.fill()
      ctx.beginPath(); ctx.moveTo(34, -34); ctx.lineTo(22, -62); ctx.lineTo(8, -40); ctx.closePath(); ctx.fill()
      ctx.fillStyle = th.rgba(th.magenta, 1)
      ctx.beginPath(); ctx.moveTo(-27, -38); ctx.lineTo(-21, -53); ctx.lineTo(-14, -41); ctx.closePath(); ctx.fill()
      ctx.beginPath(); ctx.moveTo(27, -38); ctx.lineTo(21, -53); ctx.lineTo(14, -41); ctx.closePath(); ctx.fill()
      ctx.beginPath(); ctx.arc(0, 0, 46, 0, 6.2832)
      ctx.fillStyle = th.rgba(fur, 1)
      ctx.fill()
      ctx.strokeStyle = th.rgba(th.orange, 1)
      ctx.lineWidth = 2
      ctx.stroke()
      ctx.fillStyle = th.rgba(th.magenta, 0.55)
      ctx.beginPath(); ctx.ellipse(-26, 12, 9, 6, 0, 0, 6.2832); ctx.fill()
      ctx.beginPath(); ctx.ellipse(26, 12, 9, 6, 0, 0, 6.2832); ctx.fill()
      var face = th.rgba(th.mix(root.background, "#000000", 0.3), 1)
      if (jump > 4) {
        ctx.strokeStyle = face; ctx.lineWidth = 3
        ctx.beginPath(); ctx.arc(-15, -6, 8, Math.PI, 0); ctx.stroke()
        ctx.beginPath(); ctx.arc(15, -6, 8, Math.PI, 0); ctx.stroke()
      } else if (blink) {
        ctx.strokeStyle = face; ctx.lineWidth = 3
        ctx.beginPath(); ctx.moveTo(-22, -6); ctx.lineTo(-8, -6); ctx.stroke()
        ctx.beginPath(); ctx.moveTo(8, -6); ctx.lineTo(22, -6); ctx.stroke()
      } else {
        ctx.fillStyle = "#ffffff"
        ctx.beginPath(); ctx.ellipse(-15, -6, 9, 10, 0, 0, 6.2832); ctx.fill()
        ctx.beginPath(); ctx.ellipse(15, -6, 9, 10, 0, 0, 6.2832); ctx.fill()
        ctx.fillStyle = face
        ctx.beginPath(); ctx.arc(-15 + lx, -6 + ly, 4.5, 0, 6.2832); ctx.fill()
        ctx.beginPath(); ctx.arc(15 + lx, -6 + ly, 4.5, 0, 6.2832); ctx.fill()
      }
      ctx.strokeStyle = face
      ctx.lineWidth = 2.5
      ctx.beginPath(); ctx.arc(0, 10, 8, 0.2, Math.PI - 0.2); ctx.stroke()
      ctx.lineWidth = 1.5
      ctx.beginPath()
      ctx.moveTo(-46, 0); ctx.lineTo(-62, -4)
      ctx.moveTo(-46, 8); ctx.lineTo(-62, 10)
      ctx.moveTo(46, 0); ctx.lineTo(62, -4)
      ctx.moveTo(46, 8); ctx.lineTo(62, 10)
      ctx.stroke()
      ctx.restore()

      for (var p = root.parts.length - 1; p >= 0; p--) {
        var pt = root.parts[p]
        var age = t - pt.t0
        if (age > pt.life) { root.parts.splice(p, 1); continue }
        pt.x += pt.vx; pt.y += pt.vy
        pt.vy += 0.18
        pt.vx *= 0.99
        pt.rot += pt.vr
        ctx.save()
        ctx.translate(pt.x, pt.y)
        ctx.rotate(pt.rot)
        ctx.globalAlpha = 1 - age / pt.life
        ctx.fillStyle = th.rgba(root.candy[pt.col % root.candy.length], 1)
        if (pt.round) { ctx.beginPath(); ctx.arc(0, 0, pt.sz / 2, 0, 6.2832); ctx.fill() }
        else ctx.fillRect(-pt.sz / 2, -pt.sz / 4, pt.sz, pt.sz / 2)
        ctx.restore()
      }

      if (jt < 700 && jt >= 0) {
        ctx.save()
        ctx.translate(W / 2, H / 2 - 40)
        ctx.rotate(-0.12 + Math.sin(jt / 120) * 0.02)
        var s = 1 + (1 - Math.min(1, jt / 200)) * 0.6
        ctx.scale(s, s)
        ctx.font = "bold 52px sans-serif"
        ctx.textAlign = "center"
        ctx.fillStyle = th.rgba(root.candy[0], 1)
        ctx.strokeStyle = th.rgba(root.background, 1)
        ctx.lineWidth = 8
        ctx.strokeText("WOOHOO!!", 0, 0)
        ctx.fillText("WOOHOO!!", 0, 0)
        ctx.restore()
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 34 * u
    textFormat: Text.PlainText
    text: "🎉  " + root.title.toUpperCase().split("").join(" ") + " !  🎉"
    color: root.ink
    font.family: root.fontFamily
    font.pixelSize: 28 * u
    font.bold: true
    z: 600
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 74 * u
    text: root.pages > 1 ? "pick a bubble, any bubble — party " + (root.page + 1) + " of " + root.pages : "pick a bubble, any bubble — go on, poke it"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 12 * u
    font.italic: true
    z: 600
  }
  Text {
    visible: root.count === 0
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: root.query.length > 0 ? "no bubbles for “" + root.query + "” — the party moved on" : "no bubbles here"
    color: root.ink
    font.family: root.fontFamily
    font.pixelSize: 16 * u
    z: 600
  }

  Rectangle {
    x: root.width / 2 - 190 * u; y: root.height - 84 * u
    width: 380 * u; height: 44 * u
    radius: 22 * u
    color: root.bubble
    border.color: root.query.length > 0 ? root.candy[0] : Util.alpha(root.ink, 0.2)
    border.width: 2
    z: 600
    QueryText {
      anchors.centerIn: parent
      width: 330 * u
      height: parent.height
      alignment: Text.AlignHCenter
      query: root.query
      placeholder: "🔍  search the party…"
      color: root.ink
      placeholderColor: root.dim
      caretColor: root.candy[0]
      fontFamily: root.fontFamily
      pixelSize: 14 * u
      live: root.live
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 28 * u
    text: "poke = boing · click / ↵ = POP + confetti · wheel = next bubble · ⌫ = back · esc = leave the party"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 10 * u
    opacity: 0.9
    z: 600
  }
}
