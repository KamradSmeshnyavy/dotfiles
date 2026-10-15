import QtQuick
import qs.Commons

// Lanterns: paper lanterns hanging in a night sky over still water, each one
// a row, bobbing and swaying on its own rhythm with its glow reflected below.
// The selected lantern burns brighter and shows its name on a ribbon;
// launching lets it go — it rises fast and flares out.
SkinBase {
  id: root

  launchDelay: 520

  readonly property real horizon: height * 0.76
  readonly property int cols: Math.max(3, Math.min(8, Math.floor((width - 300 * u) / (170 * u)) + 1))
  readonly property int lanesY: Math.max(2, Math.min(4, Math.floor((horizon - 300 * u) / (175 * u)) + 1))
  readonly property real gx: (width - 300 * u) / Math.max(1, cols - 1)
  readonly property real gy: (horizon - 340 * u) / Math.max(1, lanesY - 1)
  pageSize: cols * lanesY

  readonly property var warm: root.theme ? [root.theme.orange, root.theme.yellow, root.theme.red, root.theme.magenta, root.accent] : ["#ff9e3d", "#f6c177", "#eb6f92"]
  // lanterns-hack (procs): the lanterns are drifting process boxes, the
  // night sky is a blank tty.
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55))
  readonly property color night: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.theme.blue, 0.08) : "#0b1020")
  readonly property color deep: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, "#000000", 0.6) : "#03050a")
  readonly property color ink: root.foreground
  readonly property string face1: root.hack ? root.mono : root.fontFamily
  function pid(i) { return 1000 + parseInt(root.fakeHex(i, 3), 16) % 31000 }

  property real t: 0
  property var embers: []
  property real release: 0

  function home(slot) {
    var r = Math.floor(slot / root.cols), c = slot % root.cols
    return { x: 150 * root.u + c * root.gx, y: 250 * root.u + r * root.gy + (c % 2 ? root.gy * 0.32 : 0) }
  }

  // Nearest lantern in the direction pressed, like a cursor on a map.
  function navigate(dx, dy) {
    if (root.count === 0) return
    var from = root.home(root.selectedIndex - root.pageStart)
    var best = -1, bestScore = Infinity
    for (var s = 0; s < root.pageCount; s++) {
      if (s === root.selectedIndex - root.pageStart) continue
      var p = root.home(s)
      var vx = p.x - from.x, vy = p.y - from.y
      var along = vx * dx + vy * dy
      if (along <= 1) continue
      var score = along + Math.abs(vx * dy - vy * dx) * 2.2
      if (score < bestScore) { bestScore = score; best = s }
    }
    if (best >= 0) root.selectRequested(root.pageStart + best)
    else if (!root.pageStep(dx + dy > 0 ? 1 : -1)) root.ringStep(dx + dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    releaseAnim.restart()
  }
  NumberAnimation { id: releaseAnim; target: root; property: "release"; from: 0; to: 1; duration: 520; easing.type: Easing.InCubic }
  onWoke: root.release = 0

  Timer {
    interval: 33; repeat: true; running: root.live
    onTriggered: {
      root.t += 0.033
      if (root.embers.length < 40 && Math.random() < 0.35)
        root.embers.push({ x: Math.random() * root.width, y: root.horizon + Math.random() * 30, v: 0.4 + Math.random() * 1.1, w: Math.random() * 6.28, life: 1 })
      sky.requestPaint()
    }
  }

  Rectangle {
    anchors.fill: parent
    opacity: Math.min(0.98, root.backdrop)
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.deep }
      GradientStop { position: 0.7; color: root.night }
      GradientStop { position: 0.76; color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.night, root.theme.orange, 0.08) : "#20180f") }
      GradientStop { position: 1.0; color: root.deep }
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

  // Stars, moon, water, reflections and embers.
  Canvas {
    id: sky
    anchors.fill: parent
    function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var u = root.u, H = root.horizon
      if (root.hack) {
        ctx.fillStyle = th.rgba(root.ink, 0.10)
        for (var gx = 0; gx < width; gx += 28 * u)
          for (var gy = 0; gy < height; gy += 28 * u) ctx.fillRect(gx, gy, 1, 1)
        for (var he = root.embers.length - 1; he >= 0; he--) {
          var hm = root.embers[he]
          hm.y -= hm.v; hm.life -= 0.006
          if (hm.life <= 0 || hm.y < 0) { root.embers.splice(he, 1); continue }
          ctx.fillStyle = th.rgba(root.ink, hm.life * 0.35)
          ctx.fillText(".", hm.x, hm.y)
        }
        return
      }
      for (var i = 0; i < 140; i++) {
        var tw = 0.3 + 0.7 * Math.abs(Math.sin(root.t * (0.6 + rnd(i * 7) * 1.4) + i))
        ctx.fillStyle = th.rgba(root.foreground, 0.4 * tw * rnd(i * 3 + 2))
        ctx.fillRect(rnd(i * 3) * width, rnd(i * 3 + 1) * H * 0.9, 1.4, 1.4)
      }
      var mx = width * 0.86, my = H * 0.16
      var mg = ctx.createRadialGradient(mx, my, 0, mx, my, 160 * u)
      mg.addColorStop(0, th.rgba(th.bright, 0.25))
      mg.addColorStop(1, th.rgba(th.bright, 0))
      ctx.fillStyle = mg
      ctx.fillRect(mx - 160 * u, my - 160 * u, 320 * u, 320 * u)
      ctx.fillStyle = th.rgba(th.mix(th.bright, th.yellow, 0.15), 0.95)
      ctx.beginPath(); ctx.arc(mx, my, 38 * u, 0, 6.2832); ctx.fill()
      ctx.fillStyle = th.rgba(root.night, 0.9)
      ctx.beginPath(); ctx.arc(mx + 14 * u, my - 8 * u, 34 * u, 0, 6.2832); ctx.fill()

      // Reflections: one wavering streak per lantern on the page.
      for (var s = 0; s < root.pageCount; s++) {
        var p = root.home(s)
        var idx = root.pageStart + s
        var hot = idx === root.selectedIndex && root.cursorActive
        var col = root.warm[idx % root.warm.length]
        for (var k = 0; k < 6; k++) {
          var ry = H + 12 * u + k * 14 * u
          var wob = Math.sin(root.t * 2 + k * 1.3 + s) * (6 + k * 2) * u
          ctx.fillStyle = th.rgba(col, (hot ? 0.3 : 0.12) * (1 - k / 6))
          ctx.fillRect(p.x - (18 - k * 2) * u + wob, ry, (36 - k * 4) * u, 4 * u)
        }
      }
      ctx.strokeStyle = th.rgba(root.foreground, 0.06)
      ctx.lineWidth = 1
      for (var w = 0; w < 8; w++) {
        var wy = H + 8 * u + w * w * 4 * u
        ctx.beginPath()
        for (var x = 0; x <= width; x += 24) {
          var yy = wy + Math.sin(x / 70 + root.t * 1.5 + w) * 2
          if (x === 0) ctx.moveTo(x, yy); else ctx.lineTo(x, yy)
        }
        ctx.stroke()
      }
      for (var e = root.embers.length - 1; e >= 0; e--) {
        var em = root.embers[e]
        em.y -= em.v; em.w += 0.05; em.life -= 0.006
        if (em.life <= 0 || em.y < 0) { root.embers.splice(e, 1); continue }
        ctx.fillStyle = th.rgba(e % 2 ? th.orange : th.yellow, em.life * 0.7)
        ctx.fillRect(em.x + Math.sin(em.w) * 10 * u, em.y, 2, 2)
      }
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: lantern

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: lantern.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property var p: lantern.onPage ? root.home(lantern.slot) : { x: 0, y: 0 }
      readonly property bool selHere: root.cursorActive && lantern.index === root.selectedIndex
      readonly property bool released: root.launching && root.launchIndex === lantern.index
      readonly property color glowCol: root.warm[lantern.index % root.warm.length] || root.accent
      readonly property real seed: lantern.index * 1.7

      visible: lantern.onPage
      width: (root.hack ? 150 : 78) * u; height: (root.hack ? 58 : 98) * u
      x: p.x - width / 2 + Math.sin(root.t * 0.5 + seed) * 6 * u
      y: p.y - height / 2 + Math.sin(root.t * 1.1 + seed) * 7 * u - (lantern.released ? root.release * root.height * 0.7 : 0)
      rotation: root.hack ? 0 : Math.sin(root.t * 0.9 + seed) * (lantern.selHere ? 6 : 3)
      transformOrigin: Item.Top
      scale: (lantern.selHere ? 1.18 : 1) * (lantern.released ? 1 + root.release * 0.5 : 1)
      Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
      opacity: lantern.released ? 1 - root.release : 1
      z: lantern.selHere ? 20 : 10

      // String.
      Rectangle { visible: !root.hack; anchors.horizontalCenter: parent.horizontalCenter; y: -40 * u; width: 1; height: 40 * u; color: Util.alpha(root.foreground, 0.2) }
      // Glow.
      Rectangle {
        visible: !root.hack
        anchors.centerIn: body
        width: body.width * (lantern.selHere ? 3.2 : 2.2); height: width; radius: width / 2
        opacity: lantern.selHere ? 0.5 : 0.25
        gradient: Gradient {
          GradientStop { position: 0.0; color: Util.alpha(lantern.glowCol, 0) }
          GradientStop { position: 0.5; color: Util.alpha(lantern.glowCol, 0.55) }
          GradientStop { position: 1.0; color: Util.alpha(lantern.glowCol, 0) }
        }
        SequentialAnimation on opacity {
          running: root.live
          loops: Animation.Infinite
          NumberAnimation { to: lantern.selHere ? 0.6 : 0.3; duration: 700 + (lantern.index % 5) * 130; easing.type: Easing.InOutSine }
          NumberAnimation { to: lantern.selHere ? 0.42 : 0.18; duration: 900 + (lantern.index % 3) * 170; easing.type: Easing.InOutSine }
        }
      }
      Rectangle {
        visible: !root.hack
        anchors.horizontalCenter: parent.horizontalCenter
        width: 40 * u; height: 8 * u; radius: 2 * u
        color: root.theme ? root.theme.mix(root.deep, lantern.glowCol, 0.2) : "#222"
      }
      Rectangle {
        id: body
        visible: !root.hack
        anchors.horizontalCenter: parent.horizontalCenter
        y: 7 * u
        width: parent.width; height: parent.height - 16 * u
        radius: width * 0.42
        gradient: Gradient {
          GradientStop { position: 0.0; color: root.theme ? root.theme.mix(lantern.glowCol, "#000000", 0.25) : lantern.glowCol }
          GradientStop { position: 0.5; color: root.theme ? root.theme.mix(lantern.glowCol, "#ffffff", lantern.selHere ? 0.5 : 0.25) : lantern.glowCol }
          GradientStop { position: 1.0; color: root.theme ? root.theme.mix(lantern.glowCol, "#000000", 0.3) : lantern.glowCol }
        }
        // Paper ribs.
        Repeater {
          model: 3
          Rectangle {
            required property int index
            x: body.width * (0.25 + index * 0.25) - 0.5
            y: 4 * root.u
            width: 1; height: body.height - 8 * root.u
            color: Qt.rgba(0, 0, 0, 0.12)
          }
        }
        RowIcon {
          anchors.centerIn: parent
          size: 34 * u
          opacity: 0.85
          kind: lantern.kind
          glyph: lantern.icon
          glyphFont: lantern.iconFont
          appIcon: lantern.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: lantern.onPage
          fallback: lantern.label.charAt(0).toUpperCase()
          color: root.theme ? root.theme.mix(lantern.glowCol, "#000000", 0.6) : "#000"
        }
      }
      Rectangle {
        visible: !root.hack
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 30 * u; height: 9 * u; radius: 2 * u
        color: root.theme ? root.theme.mix(root.deep, lantern.glowCol, 0.2) : "#222"
        Rectangle { anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.bottom; width: 2; height: 14 * root.u; color: Util.alpha(lantern.glowCol, 0.7) }
      }
      // lanterns-hack: a process box with its pid, name and a CPU meter.
      Rectangle {
        visible: root.hack
        anchors.fill: parent
        color: lantern.selHere ? Util.alpha(root.hackInk, 0.08) : root.hackBg
        border.color: lantern.selHere ? root.hackInk : root.hackLine
        border.width: 1
        Text {
          x: 8 * root.u; y: 6 * root.u
          text: "[" + root.pid(lantern.index) + "]"
          color: root.hackDim
          font.family: root.mono; font.pixelSize: 10 * root.u
        }
        Text {
          anchors.right: parent.right; anchors.rightMargin: 8 * root.u; y: 6 * root.u
          text: root.isBranch(lantern.kind) ? "S" : (lantern.selHere ? "R" : "S")
          color: lantern.selHere ? root.hackInk : root.hackDim
          font.family: root.mono; font.pixelSize: 10 * root.u
        }
        RowIcon {
          x: 8 * root.u; y: 24 * root.u
          size: 18 * root.u
          opacity: 0.85
          kind: lantern.kind
          glyph: lantern.icon
          glyphFont: lantern.iconFont
          appIcon: lantern.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: root.hack && lantern.onPage
          fallback: lantern.label.charAt(0).toUpperCase()
          color: root.hackInk
        }
        Text {
          x: 32 * root.u; y: 24 * root.u
          width: parent.width - 40 * root.u
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: lantern.label.toLowerCase()
          color: lantern.selHere ? root.hackInk : Util.alpha(root.hackText, 0.8)
          font.family: root.mono; font.pixelSize: 12 * root.u; font.weight: lantern.selHere ? Font.Bold : Font.Normal
        }
        Rectangle {
          x: 8 * root.u; anchors.bottom: parent.bottom; anchors.bottomMargin: 6 * root.u
          height: 2 * root.u
          width: (parent.width - 16 * root.u) * (0.08 + (lantern.selHere ? 0.55 : 0.12) * (0.5 + 0.5 * Math.sin(root.t * (1.3 + (lantern.index % 5) * 0.4) + lantern.index)))
          color: lantern.selHere ? root.hackInk : root.hackDim
        }
      }
      // Ribbon with the name.
      Rectangle {
        visible: !root.hack && lantern.selHere && !lantern.released
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom; anchors.topMargin: 22 * u
        width: Math.min(260 * u, ribbonText.implicitWidth + 26 * u)
        height: 26 * u
        radius: 3 * u
        color: Util.alpha(root.deep, 0.85)
        border.color: Util.alpha(lantern.glowCol, 0.8)
        Text {
          id: ribbonText
          anchors.centerIn: parent
          width: parent.width - 20 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: lantern.label
          color: root.foreground
          font.family: root.fontFamily; font.pixelSize: 13 * u; font.weight: Font.DemiBold
        }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(lantern.index)
        onClicked: root.activated(lantern.index)
      }
    }
  }

  // Flare as a lantern goes.
  Rectangle {
    anchors.fill: parent
    z: 50
    color: root.hack ? root.hackInk : (root.theme ? root.theme.yellow : "#f6c177")
    opacity: (root.hack ? 0.4 : 1) * (root.release > 0.6 ? (1 - root.release) * 0.6 : root.release * 0.25)
  }

  Column {
    x: 60 * u; y: 40 * u
    spacing: 6 * u
    z: 60
    Text {
      textFormat: Text.PlainText
      text: root.hack ? "$ ps -ef | grep " + root.title.toLowerCase() : root.title
      color: root.ink
      font.family: root.face1; font.pixelSize: (root.hack ? 18 : 26) * u; font.weight: Font.DemiBold
    }
    QueryText {
      width: 420 * u
      height: 18 * u
      query: root.query
      placeholder: root.hack ? (root.launching ? "kill -CONT " + root.pid(root.selectedIndex) : "> pgrep …") : (root.current && root.current.detail ? root.current.detail : "type a wish…")
      color: root.foreground
      placeholderColor: root.dim
      caretColor: root.warm[0]
      fontFamily: root.fontFamily
      pixelSize: 13 * u
      live: root.live
    }
  }
  PageDots {
    anchors.right: parent.right; anchors.rightMargin: 60 * u
    y: 52 * u
    z: 60
    page: root.page
    pages: root.pages
    color: root.dim
    activeColor: root.warm[0]
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
    anchors.bottom: parent.bottom; anchors.bottomMargin: 24 * u
    z: 60
    text: root.hack ? "[arrows] select  [^h ^l] next node  [enter] run  [bksp] cd ..  [esc] exit" : "arrows / ^j ^k = drift between lanterns  ·  ^h ^l / PgUp PgDn = next sky  ·  ↵ = let it go  ·  ⌫ = back  ·  esc = dawn"
    color: root.dim
    font.family: root.fontFamily; font.pixelSize: 11 * u; font.letterSpacing: 1
  }
}
