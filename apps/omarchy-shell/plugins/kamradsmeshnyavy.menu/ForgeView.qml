import QtQuick
import qs.Commons

// "3D Forge" from omlauch's 3d tree.qml: every row is a core orbiting a forge
// on concentric rings in 3D. Drag tumbles the whole galaxy on both axes, the
// wheel spins it, the selected core is locked by a lightning arc and detonates
// on launch. Gold is the theme accent, embers are its orange.
SkinBase {
  id: root

  launchDelay: 480

  readonly property real cx: width / 2
  readonly property real cy: height / 2 - 10 * u
  property real orbit: 0
  property real yaw: 0
  property real pitch: 0.35
  property real vel: 0
  property real velP: 0
  property var rings: []
  property var nodes: []
  property real lungeT: 0

  readonly property color gold: root.accent
  readonly property color ember: root.theme ? root.theme.orange : "#f97316"
  readonly property color text: root.theme ? root.theme.bright : root.foreground
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color panel: root.theme ? root.theme.mix(root.background, root.gold, 0.07) : "#160b08"
  readonly property color hotPanel: root.theme ? root.theme.mix(root.background, root.ember, 0.18) : "#2a1206"
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.55) : "#070304"

  function rnd(i, s) { var x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453; return x - Math.floor(x) }

  function project(a, R) {
    var x0 = Math.cos(a) * R, z0 = Math.sin(a) * R
    var cyw = Math.cos(root.yaw), syw = Math.sin(root.yaw)
    var x1 = x0 * cyw + z0 * syw
    var z1 = -x0 * syw + z0 * cyw
    var cp = Math.cos(root.pitch), sp = Math.sin(root.pitch)
    return { x: x1, y: -z1 * sp, z: z1 * cp }
  }

  function nodeState(i) {
    var m = root.nodes[i]
    if (!m) return { x: root.cx, y: root.cy, depth: 0, scale: 0.6, tilt: 0 }
    var p = root.project(m.a + root.orbit, m.r)
    var depth = (p.z / m.r + 1) / 2
    return { x: root.cx + p.x, y: root.cy + p.y + 20 * u, depth: depth, scale: 0.62 + 0.5 * depth, tilt: (0.5 - depth) * 26 }
  }

  // Rings fill from the inside out, each holding as many cores as fit at a
  // fixed spacing along its circumference.
  function buildLayout() {
    var n = root.count
    var out = []
    var ringList = []
    var minPitch = 70 * u
    var r = n <= Math.floor(2 * Math.PI * 280 * u / minPitch) ? 280 * u : 195 * u
    var placed = 0, ringIdx = 0
    while (placed < n) {
      var cap = Math.max(1, Math.floor(2 * Math.PI * r / minPitch))
      var take = Math.min(cap, n - placed)
      ringList.push({ start: placed, count: take, r: r })
      for (var i = 0; i < take; i++) out.push({ a: (i / take) * 2 * Math.PI + ringIdx * 0.35, r: r })
      placed += take
      r += 105 * u
      ringIdx++
    }
    root.rings = ringList
    root.nodes = out
    base.requestPaint()
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    root.lungeT = Date.now()
  }

  onCountChanged: buildLayout()
  onRevisionChanged: buildLayout()
  onWidthChanged: buildLayout()
  Component.onCompleted: buildLayout()

  Timer {
    interval: 50; repeat: true; running: root.live
    onTriggered: {
      root.orbit += 0.0016
      root.yaw += root.vel
      root.pitch += root.velP
      root.vel *= 0.90
      root.velP *= 0.90
      fx.requestPaint()
    }
  }

  Rectangle { anchors.fill: parent; color: root.deep; opacity: Math.max(0.6, root.backdrop) }

  // Trackball: drag tumbles 360° on X and Y.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    property real lastX: 0
    property real lastY: 0
    property real pressX: 0
    property real pressY: 0
    property bool dragged: false
    onPressed: function(mouse) { lastX = mouse.x; lastY = mouse.y; pressX = mouse.x; pressY = mouse.y; dragged = false }
    onPositionChanged: function(mouse) {
      if (!pressed) return
      var dx = mouse.x - lastX, dy = mouse.y - lastY
      if (Math.abs(mouse.x - pressX) + Math.abs(mouse.y - pressY) > 6) dragged = true
      root.yaw += dx * 0.005
      root.pitch += dy * 0.005
      root.vel = dx * 0.0008
      root.velP = dy * 0.0008
      lastX = mouse.x; lastY = mouse.y
    }
    onClicked: function(mouse) {
      if (dragged) return
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.vel += (wheel.angleDelta.y > 0 ? 0.02 : -0.02) }
  }

  // Starfield and forge glow.
  Canvas {
    id: base
    anchors.fill: parent
    property var key: [root.gold, root.ember, root.text]
    onKeyChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      for (var i = 0; i < 120; i++) {
        ctx.beginPath()
        ctx.arc(root.rnd(i, 1) * width, root.rnd(i, 2) * height, 0.4 + root.rnd(i, 3) * 1.2, 0, 6.2832)
        ctx.fillStyle = th.rgba(root.text, 0.08 + root.rnd(i, 5) * 0.25)
        ctx.fill()
      }
      if (!root.rings.length) return
      var maxR = root.rings[root.rings.length - 1].r
      var g = ctx.createRadialGradient(root.cx, root.cy + 20, 0, root.cx, root.cy + 20, maxR + 80)
      g.addColorStop(0, th.rgba(root.gold, 0.10))
      g.addColorStop(0.7, th.rgba(root.ember, 0.03))
      g.addColorStop(1, th.rgba(root.ember, 0))
      ctx.fillStyle = g
      ctx.fillRect(0, 0, width, height)
    }
  }

  // Orbit paths, beams, core rings, sparks, pulses, lightning, detonation.
  Canvas {
    id: fx
    anchors.fill: parent
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var cx = root.cx, cy = root.cy + 20 * root.u
      var n = root.nodes.length
      var t = Date.now()
      var hi = root.cursorActive && root.selectedIndex < n ? root.selectedIndex : -1

      for (var r = 0; r < root.rings.length; r++) {
        ctx.beginPath()
        for (var s = 0; s <= 64; s++) {
          var p = root.project(s / 64 * 2 * Math.PI, root.rings[r].r)
          if (s === 0) ctx.moveTo(cx + p.x, cy + p.y); else ctx.lineTo(cx + p.x, cy + p.y)
        }
        ctx.strokeStyle = th.rgba(root.gold, 0.12)
        ctx.lineWidth = 1
        ctx.stroke()
      }

      var states = []
      for (var i = 0; i < n; i++) states.push(root.nodeState(i))
      for (var pass = 0; pass < 2; pass++) {
        for (var j = 0; j < n; j++) {
          var st = states[j]
          if ((pass === 0) !== (st.depth < 0.5)) continue
          ctx.beginPath()
          ctx.moveTo(cx, cy)
          ctx.lineTo(st.x, st.y)
          ctx.strokeStyle = th.rgba(root.gold, 0.05 + 0.30 * st.depth)
          ctx.lineWidth = 1.2
          ctx.stroke()
        }
      }

      ctx.save()
      ctx.translate(root.cx, root.cy)
      ctx.beginPath(); ctx.arc(0, 0, 48, 0, 6.2832)
      ctx.setLineDash([10, 14]); ctx.lineDashOffset = t / 18
      ctx.strokeStyle = th.rgba(root.gold, 0.55); ctx.lineWidth = 1.4; ctx.stroke()
      ctx.beginPath(); ctx.arc(0, 0, 60, 0, 6.2832)
      ctx.setLineDash([4, 10]); ctx.lineDashOffset = -t / 26
      ctx.strokeStyle = th.rgba(root.ember, 0.45); ctx.lineWidth = 1; ctx.stroke()
      ctx.setLineDash([])
      ctx.restore()

      for (var k = 0; k < 36; k++) {
        var sp = 0.02 + root.rnd(k, 3) * 0.05
        var sy = height + 20 - ((t * sp + root.rnd(k, 2) * (height + 60)) % (height + 60))
        var sx = root.rnd(k, 1) * width + Math.sin(t / 1400 + k) * 14
        var sa = 0.08 + 0.22 * Math.abs(Math.sin(t / 700 + k * 1.7))
        ctx.fillStyle = th.rgba(k % 5 === 0 ? root.ember : root.gold, sa)
        ctx.fillRect(sx, sy, 2, 2)
      }

      for (var q = 0; q < Math.min(n, 20); q++) {
        var qs = states[q]
        var f = ((t / 1100) + q * 0.37) % 1
        ctx.beginPath()
        ctx.arc(root.cx + (qs.x - root.cx) * f, root.cy + (qs.y - root.cy) * f, 1.6, 0, 6.2832)
        ctx.fillStyle = th.rgba(root.text, 0.7 * Math.sin(f * Math.PI) * qs.depth)
        ctx.fill()
      }

      if (hi >= 0 && !root.launching) {
        var hs = states[hi]
        var dist = Math.hypot(hs.x - root.cx, hs.y - root.cy) || 1
        ctx.beginPath()
        for (var b = 0; b <= 9; b++) {
          var fb = b / 9
          var bx = root.cx + (hs.x - root.cx) * fb, by = root.cy + (hs.y - root.cy) * fb
          var amp = (b === 0 || b === 9) ? 0 : Math.sin(t / 40 + b * 7.3) * 9 * Math.sin(fb * Math.PI)
          var lx = bx + (hs.y - root.cy) / dist * amp
          var ly = by - (hs.x - root.cx) / dist * amp
          if (b === 0) ctx.moveTo(lx, ly); else ctx.lineTo(lx, ly)
        }
        ctx.strokeStyle = th.rgba(root.ember, 0.7); ctx.lineWidth = 1.6; ctx.stroke()
        ctx.strokeStyle = th.rgba(root.text, 0.85); ctx.lineWidth = 0.6; ctx.stroke()
      }

      if (root.launching && root.launchIndex >= 0 && root.launchIndex < n) {
        var ds = states[root.launchIndex]
        var pr = Math.min(1, (t - root.lungeT) / 480)
        ctx.fillStyle = th.rgba(root.text, 0.16 * (1 - pr))
        ctx.fillRect(0, 0, width, height)
        ctx.beginPath(); ctx.arc(ds.x, ds.y, 10 + pr * 95, 0, 6.2832)
        ctx.strokeStyle = th.rgba(root.gold, 0.9 * (1 - pr)); ctx.lineWidth = 3; ctx.stroke()
        for (var e = 0; e < 16; e++) {
          var ea = e * 0.3927 + pr * 0.5
          ctx.beginPath()
          ctx.moveTo(ds.x + Math.cos(ea) * (12 + pr * 40), ds.y + Math.sin(ea) * (12 + pr * 40))
          ctx.lineTo(ds.x + Math.cos(ea) * (20 + pr * 110), ds.y + Math.sin(ea) * (20 + pr * 110))
          ctx.strokeStyle = th.rgba(e % 2 ? root.gold : root.ember, 0.8 * (1 - pr))
          ctx.lineWidth = 1.5
          ctx.stroke()
        }
      }
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: nd

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property bool hot: (root.cursorActive && nd.index === root.selectedIndex) || ma.containsMouse
      readonly property var st: {
        root.orbit; root.yaw; root.pitch; root.nodes
        return root.nodeState(nd.index)
      }
      property bool spawned: false

      x: st.x - width / 2
      y: st.y - height / 2
      z: Math.round(st.depth * 100)
      width: 44 * u; height: 44 * u
      scale: st.scale * (nd.spawned ? (nd.hot ? 1.14 : 1) : 0)
      opacity: 0.30 + 0.70 * st.depth
      Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
      Timer {
        id: spawnTimer
        interval: root.burst ? 60 + Math.min(nd.index, 60) * 8 : 0
        running: true
        onTriggered: nd.spawned = true
      }
      Connections {
        target: root
        function onWoke() { nd.spawned = false; spawnTimer.restart() }
      }
      transform: Rotation {
        origin.x: nd.width / 2; origin.y: nd.height / 2
        axis { x: 1; y: 0; z: 0 }
        angle: nd.st.tilt
      }

      Rectangle {
        anchors.centerIn: parent
        width: 56 * u; height: 56 * u
        radius: 28 * u
        color: "transparent"
        border.color: Util.alpha(root.ember, 0.4)
        border.width: 1.4
        opacity: nd.hot ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
      }
      Rectangle {
        anchors.centerIn: parent
        width: 34 * u; height: 34 * u
        radius: 9 * u
        color: nd.hot ? root.hotPanel : root.panel
        border.color: nd.hot ? root.ember : root.gold
        border.width: nd.hot ? 1.8 : 1
      }
      RowIcon {
        anchors.centerIn: parent
        size: 24 * u
        kind: nd.kind
        glyph: nd.icon
        glyphFont: nd.iconFont
        appIcon: nd.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        fallback: nd.label.charAt(0).toUpperCase()
        color: nd.hot ? root.ember : root.gold
      }
      Text {
        x: -20 * u; y: 44 * u
        width: 84 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: nd.label
        color: nd.hot ? root.text : root.dim
        font.family: root.fontFamily
        font.pixelSize: 10 * u
        opacity: nd.st.depth > 0.4 || nd.hot ? 1 : 0
      }
      MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(nd.index)
        onClicked: root.activated(nd.index)
      }
    }
  }

  // The core, with the search line across it.
  Item {
    x: root.cx - 42 * u
    y: root.cy - 42 * u
    width: 84 * u; height: 84 * u
    z: 50
    Rectangle { anchors.fill: parent; anchors.margins: -30 * u; radius: 72 * u; color: root.gold; opacity: 0.05 }
    Rectangle { anchors.fill: parent; radius: 42 * u; color: root.panel; border.color: root.gold; border.width: 2 }
    Rectangle {
      anchors.centerIn: parent
      width: 30 * u; height: 30 * u
      radius: 15 * u
      color: root.theme ? root.theme.mix(root.text, root.gold, 0.2) : "#fff7dd"
      SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: root.live
        NumberAnimation { from: 0.75; to: 1; duration: 900 }
        NumberAnimation { from: 1; to: 0.75; duration: 900 }
      }
    }
  }

  QueryText {
    x: root.cx - 130 * u; y: root.cy - 12 * u
    width: 260 * u; height: 24 * u
    z: 60
    alignment: Text.AlignHCenter
    query: root.query
    placeholder: root.current ? root.current.label : "the forge ignites…"
    color: root.text
    placeholderColor: root.dim
    caretColor: root.ember
    caret: root.query.length > 0
    fontFamily: root.fontFamily
    pixelSize: 16 * u
    bold: true
    live: root.live
  }

  Text {
    x: root.cx - 130 * u; y: root.cy + 54 * u
    width: 260 * u
    horizontalAlignment: Text.AlignHCenter
    textFormat: Text.PlainText
    text: root.count === 0 ? root.emptyText() : (root.query.length > 0 ? root.count + " cores locked" : root.count + " cores in " + root.title.toLowerCase())
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 11 * u
    z: 60
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 32 * u
    text: "drag → tumble 360° x+y · wheel spin · type → lock · arrows → cycle · ↵ detonate · ⌫ back · esc eject"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 11 * u
    opacity: 0.75
    z: 60
  }
}
