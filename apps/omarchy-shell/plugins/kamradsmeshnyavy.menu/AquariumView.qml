import QtQuick
import qs.Commons

// Aquarium: rows are fish in a tank, swimming their lanes with light rippling
// down from the surface, bubbles rising and weed swaying on the sand. The
// selected fish leaves its lane and holds still in the spotlight with its
// name on a brass plate; launching sends it darting off in a burst of
// bubbles. The water is the theme's blue and cyan, the fish its hues.
SkinBase {
  id: root

  launchDelay: 460
  pageSize: 12
  radial: true

  readonly property real waterTop: 0
  readonly property real sandY: height * 0.86
  readonly property real laneTop: 150 * u
  readonly property real laneGap: (sandY - laneTop - 60 * u) / 6
  readonly property real spotX: width / 2
  readonly property real spotY: height * 0.46

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  // aquarium-hack (packets): ASCII fish on blank lanes, dots for bubbles.
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.mix(root.theme.muted, root.theme.cyan, 0.3) : "#6d8aa0")
  readonly property color shallow: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.theme.cyan, 0.22) : "#12384a")
  readonly property color abyss: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.theme.blue, 0.1) : "#050f18")
  readonly property color ink: root.foreground
  readonly property string face1: root.hack ? root.mono : root.fontFamily
  readonly property color sand: root.theme ? root.theme.mix(root.background, root.theme.yellow, 0.22) : "#3a3020"
  readonly property color brass: root.theme ? root.theme.mix(root.theme.yellow, root.theme.brown, 0.3) : "#c8a050"

  property real t: 0
  property var bubbles: []
  property var ripples: []
  property real dart: 0

  function swim(slot) {
    var lane = slot % 6
    var phase = slot < 6 ? 0 : Math.PI
    var speed = 0.16 + (lane % 3) * 0.05
    var a = root.t * speed + phase + lane * 0.9
    return {
      x: root.width / 2 + Math.sin(a) * root.width * 0.38,
      y: root.laneTop + (lane + 0.5) * root.laneGap + Math.sin(root.t * 1.3 + slot) * 10 * root.u,
      right: Math.cos(a) > 0
    }
  }

  function navigate(dx, dy) {
    root.ringStep(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    dartAnim.restart()
    for (var i = 0; i < 40; i++)
      root.bubbles.push({ x: root.spotX + (Math.random() - 0.5) * 120 * root.u, y: root.spotY + (Math.random() - 0.5) * 60 * root.u,
                          r: (2 + Math.random() * 6) * root.u, v: 1.5 + Math.random() * 3, w: Math.random() * 6.28 })
  }
  NumberAnimation { id: dartAnim; target: root; property: "dart"; from: 0; to: 1; duration: 460; easing.type: Easing.InCubic }
  onWoke: root.dart = 0

  Timer {
    interval: 33; repeat: true; running: root.live
    onTriggered: {
      root.t += 0.033
      if (root.bubbles.length < 60 && Math.random() < 0.3)
        root.bubbles.push({ x: Math.random() * root.width, y: root.sandY, r: (1.5 + Math.random() * 4) * root.u, v: 0.6 + Math.random() * 1.4, w: Math.random() * 6.28 })
      water.requestPaint()
    }
  }

  Rectangle {
    anchors.fill: parent
    opacity: Math.min(0.98, root.backdrop)
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.shallow }
      GradientStop { position: 0.8; color: root.abyss }
      GradientStop { position: 1.0; color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.abyss, "#000000", 0.4) : "#02060a") }
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

  // Moving the pointer through the water leaves rings behind it.
  HoverHandler {
    id: hover
    property real lastT: 0
    onPointChanged: {
      if (root.t - lastT < 0.2) return
      lastT = root.t
      root.ripples.push({ x: hover.point.position.x, y: hover.point.position.y, age: 0 })
    }
  }

  // Light from the surface, caustics, weed, sand, bubbles, ripples.
  Canvas {
    id: water
    anchors.fill: parent
    function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var u = root.u, W = width, H = height, T = root.t
      var light = th.mix(th.cyan, "#ffffff", 0.4)
      if (root.hack) {
        // Lanes, with their interface names, and dots for bubbles.
        ctx.font = Math.round(10 * u) + "px monospace"
        for (var ln = 0; ln < 6; ln++) {
          var ly = root.laneTop + (ln + 0.5) * root.laneGap
          ctx.fillStyle = th.rgba(root.ink, 0.07)
          for (var lx = 0; lx < W; lx += 12 * u) ctx.fillRect(lx, ly, 4 * u, 1)
          ctx.fillStyle = th.rgba(root.ink, 0.3)
          ctx.fillText("eth" + ln, 20 * u, ly - 6 * u)
        }
        for (var hb = root.bubbles.length - 1; hb >= 0; hb--) {
          var hbu = root.bubbles[hb]
          hbu.y -= hbu.v
          if (hbu.y < -10) { root.bubbles.splice(hb, 1); continue }
          ctx.fillStyle = th.rgba(root.ink, 0.35)
          ctx.fillText(hb % 4 ? "." : "o", hbu.x, hbu.y)
        }
        for (var hp = root.ripples.length - 1; hp >= 0; hp--) {
          var hr = root.ripples[hp]
          hr.age += 0.033
          if (hr.age > 1.2) { root.ripples.splice(hp, 1); continue }
          var rs = (6 + hr.age * 50) * u
          ctx.strokeStyle = th.rgba(root.ink, 0.3 * (1 - hr.age / 1.2))
          ctx.strokeRect(hr.x - rs, hr.y - rs, rs * 2, rs * 2)
        }
        return
      }

      for (var r = 0; r < 7; r++) {
        var rx = (rnd(r) * 1.2 - 0.1) * W + Math.sin(T * 0.2 + r) * 60 * u
        var a = 0.035 + 0.03 * Math.sin(T * 0.7 + r * 1.9)
        var g = ctx.createLinearGradient(0, 0, 0, root.sandY)
        g.addColorStop(0, th.rgba(light, a * 2))
        g.addColorStop(1, th.rgba(light, 0))
        ctx.fillStyle = g
        ctx.beginPath()
        ctx.moveTo(rx - 30 * u, 0)
        ctx.lineTo(rx + 50 * u, 0)
        ctx.lineTo(rx + 260 * u, root.sandY)
        ctx.lineTo(rx + 120 * u, root.sandY)
        ctx.closePath()
        ctx.fill()
      }
      // Caustic net near the surface.
      ctx.strokeStyle = th.rgba(light, 0.08)
      ctx.lineWidth = 2
      for (var c = 0; c < 5; c++) {
        ctx.beginPath()
        for (var x = 0; x <= W; x += 30) {
          var y = 30 * u + c * 22 * u + Math.sin(x / 90 + T * 1.6 + c * 2) * 9 * u + Math.sin(x / 37 - T * 2.3) * 4 * u
          if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
        }
        ctx.stroke()
      }

      var sg = ctx.createLinearGradient(0, root.sandY - 20 * u, 0, H)
      sg.addColorStop(0, th.rgba(root.sand, 0))
      sg.addColorStop(0.25, th.rgba(root.sand, 0.9))
      sg.addColorStop(1, th.rgba(th.mix(root.sand, "#000000", 0.5), 1))
      ctx.fillStyle = sg
      ctx.beginPath()
      ctx.moveTo(0, H)
      for (var sx = 0; sx <= W; sx += 40) ctx.lineTo(sx, root.sandY + Math.sin(sx / 160) * 10 * u)
      ctx.lineTo(W, H)
      ctx.closePath()
      ctx.fill()

      for (var wd = 0; wd < 14; wd++) {
        var bx = rnd(wd * 5) * W
        var hgt = (80 + rnd(wd * 5 + 1) * 160) * u
        ctx.strokeStyle = th.rgba(th.mix(th.green, root.abyss, 0.3 + rnd(wd * 5 + 2) * 0.3), 0.85)
        ctx.lineWidth = (4 + rnd(wd * 5 + 3) * 5) * u
        ctx.lineCap = "round"
        ctx.beginPath()
        ctx.moveTo(bx, root.sandY + 10 * u)
        for (var sgm = 1; sgm <= 8; sgm++) {
          var f = sgm / 8
          ctx.lineTo(bx + Math.sin(T * 0.9 + wd + f * 3) * 18 * u * f, root.sandY + 10 * u - hgt * f)
        }
        ctx.stroke()
      }

      ctx.strokeStyle = th.rgba(light, 0.5)
      ctx.lineWidth = 1
      for (var b = root.bubbles.length - 1; b >= 0; b--) {
        var bu = root.bubbles[b]
        bu.y -= bu.v; bu.w += 0.08
        if (bu.y < -10) { root.bubbles.splice(b, 1); continue }
        ctx.beginPath()
        ctx.arc(bu.x + Math.sin(bu.w) * 4 * u, bu.y, bu.r, 0, 6.2832)
        ctx.stroke()
      }
      for (var p = root.ripples.length - 1; p >= 0; p--) {
        var rp = root.ripples[p]
        rp.age += 0.033
        if (rp.age > 1.2) { root.ripples.splice(p, 1); continue }
        ctx.strokeStyle = th.rgba(light, 0.3 * (1 - rp.age / 1.2))
        ctx.beginPath()
        ctx.arc(rp.x, rp.y, (6 + rp.age * 70) * u, 0, 6.2832)
        ctx.stroke()
      }

      // Spotlight for the chosen fish.
      if (root.cursorActive && root.count > 0) {
        var sp = ctx.createRadialGradient(root.spotX, root.spotY, 0, root.spotX, root.spotY, 220 * u)
        sp.addColorStop(0, th.rgba(light, 0.14))
        sp.addColorStop(1, th.rgba(light, 0))
        ctx.fillStyle = sp
        ctx.fillRect(root.spotX - 220 * u, root.spotY - 220 * u, 440 * u, 440 * u)
      }
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: fish

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: fish.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property bool selHere: root.cursorActive && fish.index === root.selectedIndex
      readonly property var s: fish.onPage ? root.swim(fish.slot) : { x: 0, y: 0, right: true }
      readonly property color hue: root.hues[fish.index % root.hues.length] || root.accent
      readonly property bool darting: root.launching && root.launchIndex === fish.index
      // 0 = in its lane, 1 = in the spotlight.
      property real spot: fish.selHere ? 1 : 0
      Behavior on spot { NumberAnimation { duration: 620; easing.type: Easing.InOutCubic } }
      readonly property bool facingRight: fish.spot > 0.5 ? true : fish.s.right

      visible: fish.onPage
      width: 100 * u; height: 56 * u
      x: fish.s.x + (root.spotX - fish.s.x) * fish.spot - width / 2 + (fish.darting ? root.dart * root.width * 0.7 : 0)
      y: fish.s.y + (root.spotY - fish.s.y) * fish.spot - height / 2
      z: fish.selHere ? 30 : 10 + fish.slot
      scale: 1 + 0.65 * fish.spot
      opacity: fish.darting ? 1 - root.dart : (0.8 + 0.2 * fish.spot)

      // aquarium-hack: the fish is ASCII, facing its way, with a tag.
      Text {
        visible: root.hack
        anchors.centerIn: parent
        textFormat: Text.PlainText
        text: (fish.darting ? ">>> " : "") + (fish.facingRight ? "><(((°>" : "<°)))><")
        color: fish.selHere ? root.hackInk : Util.alpha(root.hackText, 0.75)
        font.family: root.mono; font.pixelSize: 18 * root.u; font.weight: Font.Bold
      }
      Text {
        visible: root.hack && !fish.selHere
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        width: 140 * root.u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: fish.label.toLowerCase()
        color: root.hackDim
        font.family: root.mono; font.pixelSize: 9 * root.u
      }
      Rectangle {
        visible: root.hack && fish.selHere
        anchors.centerIn: parent
        width: parent.width + 16 * root.u; height: parent.height
        color: "transparent"
        border.color: root.hackInk
        border.width: 1
      }
      Item {
        id: shape
        visible: !root.hack
        anchors.fill: parent
        transform: Scale { origin.x: shape.width / 2; xScale: fish.facingRight ? 1 : -1 }

        // Tail, wagging.
        Rectangle {
          x: 2 * u
          anchors.verticalCenter: parent.verticalCenter
          width: 30 * u; height: 30 * u
          rotation: 45 + Math.sin(root.t * (fish.selHere ? 5 : 9) + fish.index) * 12
          color: root.theme ? root.theme.mix(fish.hue, "#000000", 0.25) : fish.hue
          radius: 4 * u
        }
        // Dorsal fin.
        Rectangle {
          x: parent.width * 0.42
          y: 2 * u
          width: 22 * u; height: 22 * u
          rotation: 45
          color: root.theme ? root.theme.mix(fish.hue, "#000000", 0.2) : fish.hue
          radius: 3 * u
        }
        Rectangle {
          x: 18 * u
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 18 * u; height: 46 * u
          radius: height / 2
          gradient: Gradient {
            GradientStop { position: 0.0; color: root.theme ? root.theme.mix(fish.hue, "#ffffff", 0.3) : fish.hue }
            GradientStop { position: 1.0; color: root.theme ? root.theme.mix(fish.hue, "#000000", 0.35) : fish.hue }
          }
          border.color: fish.selHere ? root.brass : "transparent"
          border.width: 1.5
          Rectangle {
            x: parent.width - 20 * u; y: parent.height * 0.3
            width: 9 * u; height: 9 * u; radius: 4.5 * u
            color: "#ffffff"
            Rectangle { anchors.centerIn: parent; anchors.horizontalCenterOffset: 1.5 * root.u; width: 4 * root.u; height: 4 * root.u; radius: 2 * root.u; color: "#101010" }
          }
          // Gill line.
          Rectangle { x: parent.width - 34 * u; y: parent.height * 0.2; width: 2; height: parent.height * 0.6; radius: 1; color: Qt.rgba(0, 0, 0, 0.18) }
        }
      }
      // The icon rides the fish's flank, never mirrored.
      RowIcon {
        visible: !root.hack
        x: parent.width * 0.42 - size / 2
        anchors.verticalCenter: parent.verticalCenter
        size: 26 * u
        kind: fish.kind
        glyph: fish.icon
        glyphFont: fish.iconFont
        appIcon: fish.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: fish.onPage
        fallback: fish.label.charAt(0).toUpperCase()
        color: root.theme ? root.theme.ink(fish.hue) : "#fff"
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: if (!fish.selHere) root.selectRequested(fish.index)
        onClicked: root.activated(fish.index)
      }
    }
  }

  // Brass plate under the spotlight.
  Rectangle {
    visible: !!root.current
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.spotY + 80 * u
    z: 40
    width: Math.min(460 * u, Math.max(plateName.implicitWidth, plateDetail.implicitWidth) + 50 * u)
    height: 62 * u
    radius: root.hack ? 0 : 6 * u
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.brass, "#ffffff", 0.2) : root.brass) }
      GradientStop { position: 1.0; color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.brass, "#000000", 0.3) : root.brass) }
    }
    border.color: root.hack ? root.hackLine : (root.theme ? root.theme.mix(root.brass, "#000000", 0.5) : "#5a4010")
    Column {
      anchors.centerIn: parent
      width: parent.width - 30 * u
      spacing: 2 * u
      Text {
        id: plateName
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? (root.hack ? "pkt#" + root.fakeHex(root.selectedIndex, 4) + "  " + root.current.label.toLowerCase() : root.current.label) : ""
        color: root.hack ? root.hackInk : (root.theme ? root.theme.mix(root.brass, "#000000", 0.7) : "#2a1a00")
        font.family: root.hack ? root.mono : "serif"; font.pixelSize: (root.hack ? 15 : 18) * u; font.weight: Font.Bold
      }
      Text {
        id: plateDetail
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? (root.hack ? "proto " + (root.isBranch(root.current.kind) ? "tunnel" : "tcp") + "  len=" + (64 + parseInt(root.fakeHex(root.selectedIndex, 3), 16) % 1400) + (root.current.detail ? "  # " + root.current.detail : "") : (root.current.detail || (root.isBranch(root.current.kind) ? "another tank ›" : ""))) : ""
        color: root.hack ? root.hackDim : (root.theme ? root.theme.mix(root.brass, "#000000", 0.5) : "#4a3010")
        font.family: root.hack ? root.mono : "serif"; font.pixelSize: 11 * u; font.italic: !root.hack
      }
    }
  }

  Column {
    x: 60 * u; y: 40 * u
    spacing: 6 * u
    z: 50
    Text {
      textFormat: Text.PlainText
      text: root.hack ? "capture // " + root.title.toLowerCase() : root.title
      color: root.ink
      font.family: root.face1; font.pixelSize: (root.hack ? 18 : 26) * u; font.weight: Font.DemiBold
    }
    QueryText {
      width: 420 * u
      height: 18 * u
      query: root.query
      placeholder: root.hack ? "$ tcpdump -i any " + root.title.toLowerCase() : "type to call a fish…"
      color: root.foreground
      placeholderColor: root.dim
      caretColor: root.theme ? root.theme.cyan : root.accent
      fontFamily: root.fontFamily
      pixelSize: 13 * u
      live: root.live
    }
  }
  PageDots {
    anchors.right: parent.right; anchors.rightMargin: 60 * u
    y: 52 * u
    z: 50
    page: root.page
    pages: root.pages
    color: root.dim
    activeColor: root.theme ? root.theme.cyan : root.accent
    dot: 6 * u
    fontFamily: root.fontFamily
  }
  Text {
    visible: root.count === 0
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: root.emptyText()
    color: root.dim
    font.family: root.fontFamily; font.pixelSize: 16 * u
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 22 * u
    z: 50
    text: root.hack ? "[j/k] next packet  [h/l] next capture  [enter] send  [bksp] cd ..  [esc] exit" : "↑↓ / ^j ^k = next fish  ·  ←→ / ^h ^l = next shoal  ·  ↵ = release  ·  ⌫ = back  ·  esc = leave the tank"
    color: root.dim
    font.family: root.fontFamily; font.pixelSize: 11 * u; font.letterSpacing: 1
  }
}
