import QtQuick
import qs.Commons

// Orrery: a small solar system. The menu's name burns in the sun; rows are
// planets on three tilted orbits that keep turning, faster on the inside.
// The selected planet's orbit slows almost to a stop so it can be read, gets
// a halo and a tag; submenus wear a ring. Launching sets off a nova.
SkinBase {
  id: root

  launchDelay: 480
  pageSize: 27
  radial: true

  readonly property var caps: [6, 9, 12]
  readonly property real cx: width / 2
  readonly property real cy: height / 2 + 24 * u
  // The radar is round, so it has to fit the screen's height on its own.
  readonly property real base: root.hack ? Math.min(width * 0.17, (height / 2 - 110 * u) / (2.24 * 1.06 * 0.9)) : Math.min(width * 0.19, height * 0.34)
  readonly property var rx: [base, base * 1.62, base * 2.24]
  // orrery-hack (radar) looks straight down: the orbits become range rings.
  readonly property real tilt: root.hack ? 0.9 : 0.36

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55))
  readonly property color space: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, "#000000", 0.6) : "#04040a")
  readonly property color ink: root.foreground
  readonly property color hi: root.hack ? root.hackInk : root.accent
  readonly property string face1: root.hack ? root.mono : root.fontFamily
  // Radar sweep angle (hack only), radians.
  property real sweep: 0
  NumberAnimation on sweep { from: 0; to: 2 * Math.PI; duration: 4000; loops: Animation.Infinite; running: root.live && root.hack }
  // How lit a blip at angle a is: bright just behind the sweep, fading after.
  function afterglow(a) {
    var d = ((root.sweep - a) % (2 * Math.PI) + 2 * Math.PI) % (2 * Math.PI)
    return Math.max(0.25, 1 - d / (2 * Math.PI) * 1.4)
  }
  function polar(slot) {
    var b = root.body(slot)
    var dx = b.x - root.cx, dy = (b.y - root.cy) / root.tilt
    var deg = Math.round((Math.atan2(dy, dx) * 180 / Math.PI + 450) % 360)
    return "r=" + (root.orbitOf(slot) + 1) + " θ=" + String(deg).padStart(3, "0") + "°"
  }
  readonly property color sunCore: root.theme ? root.theme.mix(root.theme.yellow, "#ffffff", 0.35) : "#fff1c0"
  readonly property color sunEdge: root.theme ? root.theme.orange : "#ff9e3d"

  // All three orbit phases in one property, so a tick is one change
  // notification for the planets rather than three.
  property var phases: [0, 1.3, 2.1]
  property real nova: 0
  property real novaX: 0
  property real novaY: 0

  readonly property var parked: ({ x: 0, y: 0, depth: 0, orbit: 0 })
  readonly property int selSlot: Math.max(0, root.selectedIndex - root.pageStart)
  readonly property int selOrbit: root.orbitOf(root.selSlot)

  function orbitOf(slot) { return slot < 6 ? 0 : (slot < 15 ? 1 : 2) }
  function orbitStart(o) { return o === 0 ? 0 : (o === 1 ? 6 : 15) }
  function orbitCount(o) { return Math.max(0, Math.min(root.caps[o], root.pageCount - root.orbitStart(o))) }
  function phaseOf(o) { return root.phases[o] + root.ringPhase * (o + 1) * 0.6 }

  function body(slot) {
    var o = root.orbitOf(slot)
    var j = slot - root.orbitStart(o)
    var n = Math.max(1, root.orbitCount(o))
    var th = root.phaseOf(o) + 2 * Math.PI * j / n
    var r = root.rx[o]
    return { x: root.cx + r * Math.cos(th), y: root.cy + r * root.tilt * Math.sin(th), depth: Math.sin(th), orbit: o }
  }

  function navigate(dx, dy) {
    root.ringStep(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    var b = root.body(index - root.pageStart)
    root.novaX = b.x
    root.novaY = b.y
    novaAnim.restart()
  }
  NumberAnimation { id: novaAnim; target: root; property: "nova"; from: 0; to: 1; duration: 520; easing.type: Easing.OutCubic }
  onWoke: root.nova = 0

  Timer {
    interval: 33; repeat: true; running: root.live
    onTriggered: {
      var hold = root.cursorActive ? root.selOrbit : -1
      root.phases = [root.phases[0] + 0.0062 * (hold === 0 ? 0.1 : 1),
                     root.phases[1] + 0.0039 * (hold === 1 ? 0.1 : 1),
                     root.phases[2] + 0.0026 * (hold === 2 ? 0.1 : 1)]
    }
  }

  Rectangle { anchors.fill: parent; color: root.space; opacity: Math.min(0.98, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Stars and a faint milky band; static, repainted only on resize/theme.
  Canvas {
    visible: !root.hack
    anchors.fill: parent
    property color tint: root.foreground
    onTintChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      ctx.save()
      ctx.translate(width / 2, height / 2)
      ctx.rotate(-0.35)
      var band = ctx.createLinearGradient(0, -height * 0.25, 0, height * 0.25)
      band.addColorStop(0, th.rgba(th.magenta, 0))
      band.addColorStop(0.5, th.rgba(th.mix(th.magenta, th.blue, 0.5), 0.07))
      band.addColorStop(1, th.rgba(th.blue, 0))
      ctx.fillStyle = band
      ctx.fillRect(-width, -height * 0.25, width * 2, height * 0.5)
      ctx.restore()
      for (var i = 0; i < 260; i++) {
        var s = rnd(i * 3 + 2)
        ctx.fillStyle = th.rgba(root.foreground, 0.12 + s * 0.5)
        var r = s > 0.93 ? 1.6 : 0.9
        ctx.fillRect(rnd(i * 3) * width, rnd(i * 3 + 1) * height, r, r)
      }
    }
  }

  // Orbits; the selected one in the accent.
  Canvas {
    id: orbits
    anchors.fill: parent
    property var key: [root.selOrbit, root.pageCount, root.accent, root.cursorActive, root.hack]
    onKeyChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      for (var o = 0; o < 3; o++) {
        if (root.orbitCount(o) === 0) continue
        var hot = o === root.selOrbit && root.cursorActive
        ctx.strokeStyle = hot ? th.rgba(root.hi, 0.55) : th.rgba(root.ink, root.hack ? 0.22 : 0.12)
        ctx.lineWidth = hot ? 1.6 : 1
        // A polyline rather than ellipse(): the dashed ellipse() version left
        // the outer orbits undrawn.
        ctx.beginPath()
        for (var k = 0; k <= 96; k++) {
          var th2 = k / 96 * 2 * Math.PI
          var px = root.cx + root.rx[o] * Math.cos(th2), py = root.cy + root.rx[o] * root.tilt * Math.sin(th2)
          if (k === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
        }
        ctx.stroke()
      }
      if (root.hack) {
        // Crosshair and bearing ticks.
        ctx.strokeStyle = th.rgba(root.ink, 0.18)
        ctx.lineWidth = 1
        var R2 = root.rx[2] * 1.06
        ctx.beginPath()
        ctx.moveTo(root.cx - R2, root.cy); ctx.lineTo(root.cx + R2, root.cy)
        ctx.moveTo(root.cx, root.cy - R2 * root.tilt); ctx.lineTo(root.cx, root.cy + R2 * root.tilt)
        ctx.stroke()
        ctx.font = Math.round(10 * root.u) + "px monospace"
        ctx.fillStyle = th.rgba(root.ink, 0.45)
        for (var b = 0; b < 36; b++) {
          var ang = b / 36 * 2 * Math.PI
          var ox = root.cx + Math.cos(ang) * R2, oy = root.cy + Math.sin(ang) * R2 * root.tilt
          var ix = root.cx + Math.cos(ang) * (R2 - (b % 3 ? 5 : 12) * root.u), iy = root.cy + Math.sin(ang) * (R2 - (b % 3 ? 5 : 12) * root.u) * root.tilt
          ctx.beginPath(); ctx.moveTo(ix, iy); ctx.lineTo(ox, oy); ctx.stroke()
          if (b % 3 === 0) ctx.fillText(String((b * 10 + 90) % 360).padStart(3, "0"), ox + Math.cos(ang) * 16 * root.u - 10 * root.u, oy + Math.sin(ang) * 14 * root.u + 4)
        }
      }
    }
  }

  // Radar sweep (hack): the wedge is painted once, pointing along +x, and
  // only rotated — a per-frame repaint of 24 arcs was wasted work.
  Item {
    visible: root.hack
    readonly property real r2: root.rx[2] * 1.06
    x: root.cx - r2; y: root.cy - r2
    width: r2 * 2; height: r2 * 2
    transform: Scale { origin.x: root.rx[2] * 1.06; origin.y: root.rx[2] * 1.06; yScale: root.tilt }
    Canvas {
      id: sweepCanvas
      anchors.fill: parent
      rotation: root.sweep * 180 / Math.PI
      property var key: [root.hack, root.foreground, width]
      onKeyChanged: if (root.hack) requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var th = root.theme
        if (!th) return
        var R2 = width / 2
        if (R2 <= 0) return
        ctx.translate(R2, R2)
        for (var k = 0; k < 24; k++) {
          var a0 = -k * 0.03
          ctx.fillStyle = th.rgba(root.ink, 0.14 * (1 - k / 24))
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.arc(0, 0, R2, a0 - 0.03, a0, false)
          ctx.closePath()
          ctx.fill()
        }
        ctx.strokeStyle = th.rgba(root.hi, 0.85)
        ctx.lineWidth = 1.5
        ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(R2, 0); ctx.stroke()
      }
    }
  }

  // The sun.
  Item {
    id: sun
    x: root.cx - width / 2
    y: root.cy - height / 2
    width: (root.hack ? 60 : 150) * u; height: width
    z: 40
    Rectangle {
      visible: !root.hack
      anchors.centerIn: parent
      width: parent.width * 1.9; height: width; radius: width / 2
      color: Util.alpha(root.sunEdge, 0.08)
      SequentialAnimation on scale {
        loops: Animation.Infinite
        running: root.live
        NumberAnimation { from: 0.92; to: 1.06; duration: 2200; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.06; to: 0.92; duration: 2200; easing.type: Easing.InOutSine }
      }
    }
    Rectangle {
      visible: !root.hack
      anchors.centerIn: parent
      width: parent.width * 1.3; height: width; radius: width / 2
      color: Util.alpha(root.sunEdge, 0.18)
    }
    Rectangle {
      visible: !root.hack
      anchors.fill: parent
      radius: width / 2
      gradient: Gradient {
        GradientStop { position: 0.0; color: root.sunCore }
        GradientStop { position: 1.0; color: root.sunEdge }
      }
    }
    Text {
      anchors.centerIn: parent
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.hack ? "[" + root.title.toLowerCase() + "]" : root.title
      width: root.hack ? 200 * u : parent.width - 20 * u
      color: root.hack ? root.hackInk : (root.theme ? root.theme.mix(root.sunEdge, "#000000", 0.6) : "#3a1a00")
      font.family: root.face1; font.pixelSize: 17 * u; font.weight: Font.Bold
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: planet

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: planet.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      // Only planets on the page read the phases (body() does), so the
      // hundred-odd off-page rows of a long menu sit out every tick.
      readonly property var b: planet.onPage ? root.body(planet.slot) : root.parked
      readonly property bool selHere: root.cursorActive && planet.index === root.selectedIndex
      readonly property color hue: root.hues[planet.index % root.hues.length] || root.accent
      readonly property real d: root.hack ? 12 * u : [54, 48, 42][planet.b.orbit] * u
      readonly property real glow: root.hack && planet.onPage ? root.afterglow(Math.atan2((planet.b.y - root.cy) / root.tilt, planet.b.x - root.cx)) : 1

      visible: planet.onPage
      width: planet.d; height: planet.d
      x: b.x - width / 2
      y: b.y - height / 2
      z: b.depth > 0 ? 60 + b.depth * 20 : 20 + b.depth * 10
      scale: root.hack ? (planet.selHere ? 1.4 : 1) : (0.72 + 0.28 * (b.depth + 1) / 2) * (planet.selHere ? 1.35 : 1)
      Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
      opacity: root.hack ? (planet.selHere ? 1 : planet.glow) : 0.55 + 0.45 * (b.depth + 1) / 2

      // Radar blip (hack): a square for submenus, a dot for the rest.
      Rectangle {
        visible: root.hack
        anchors.fill: parent
        radius: root.isBranch(planet.kind) ? 0 : width / 2
        color: root.hackInk
      }
      Text {
        visible: root.hack
        x: parent.width + 6 * root.u
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: planet.label.toLowerCase() + (planet.selHere ? "  " + root.polar(planet.slot) : "")
        color: planet.selHere ? root.hackInk : root.hackText
        font.family: root.mono; font.pixelSize: (planet.selHere ? 13 : 10) * root.u
      }

      // Ring for submenus, tilted like the orbits.
      Rectangle {
        visible: !root.hack && root.isBranch(planet.kind)
        anchors.centerIn: parent
        width: parent.width * 1.9; height: parent.height * 0.5
        radius: height / 2
        rotation: -16
        color: "transparent"
        border.color: Util.alpha(planet.hue, 0.75)
        border.width: 2.5
      }
      Rectangle {
        visible: !root.hack
        anchors.fill: parent
        radius: width / 2
        gradient: Gradient {
          GradientStop { position: 0.0; color: root.theme ? root.theme.mix(planet.hue, "#ffffff", 0.25) : planet.hue }
          GradientStop { position: 1.0; color: root.theme ? root.theme.mix(planet.hue, "#000000", 0.55) : planet.hue }
        }
      }
      // Night side, away from the sun.
      Rectangle {
        visible: !root.hack
        anchors.fill: parent
        radius: width / 2
        rotation: Math.atan2(planet.b.y - root.cy, planet.b.x - root.cx) * 180 / Math.PI - 90
        gradient: Gradient {
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 0.55; color: "transparent" }
          GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.55) }
        }
      }
      RowIcon {
        visible: !root.hack
        anchors.centerIn: parent
        size: planet.d * 0.56
        kind: planet.kind
        glyph: planet.icon
        glyphFont: planet.iconFont
        appIcon: planet.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: planet.onPage
        fallback: planet.label.charAt(0).toUpperCase()
        color: root.theme ? root.theme.ink(planet.hue) : "#fff"
      }
      Rectangle {
        anchors.centerIn: parent
        visible: planet.selHere
        width: parent.width + 16 * u; height: width; radius: root.hack ? 0 : width / 2
        color: "transparent"
        border.color: root.hi
        border.width: 1.5
        RotationAnimation on rotation { from: 0; to: 360; duration: 9000; loops: Animation.Infinite; running: planet.selHere && root.live }
        Rectangle { visible: !root.hack; x: parent.width / 2 - 3; y: -3; width: 6; height: 6; radius: 3; color: root.accent }
      }
      Text {
        visible: !root.hack && !planet.selHere && planet.b.depth > -0.1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom; anchors.topMargin: 3 * u
        width: 110 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: planet.label
        color: root.dim
        font.family: root.face1; font.pixelSize: 10 * u
      }
      MouseArea {
        anchors.fill: parent
        anchors.margins: -6 * u
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hoverSelect(planet.index, mapToItem(root, mouseX, mouseY))
        onPositionChanged: root.hoverSelect(planet.index, mapToItem(root, mouseX, mouseY))
        onClicked: root.activated(planet.index)
      }
    }
  }

  // Tag on the selected planet.
  Item {
    id: tag
    readonly property var b: root.current ? root.body(root.selSlot) : { x: root.cx, y: root.cy, depth: 0, orbit: 0 }
    readonly property bool onRight: tag.b.x < root.cx
    visible: !root.hack && !!root.current && root.cursorActive && !root.launching
    z: 90
    x: tag.b.x + (tag.onRight ? 46 * u : -46 * u - tagBox.width)
    y: tag.b.y - 70 * u
    Rectangle {
      x: tag.onRight ? -46 * u : tagBox.width
      y: 70 * u
      width: 46 * u; height: 1
      color: Util.alpha(root.accent, 0.7)
      transformOrigin: tag.onRight ? Item.Left : Item.Right
      rotation: tag.onRight ? -55 : 55
    }
    Rectangle {
      id: tagBox
      width: Math.min(300 * u, tagText.implicitWidth + 24 * u)
      height: 30 * u
      radius: 4 * u
      color: Util.alpha(root.space, 0.85)
      border.color: Util.alpha(root.accent, 0.6)
      Text {
        id: tagText
        anchors.centerIn: parent
        width: parent.width - 20 * u
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label : ""
        color: root.ink
        font.family: root.face1; font.pixelSize: 14 * u; font.weight: Font.DemiBold
      }
    }
  }

  // Nova.
  Rectangle {
    visible: root.nova > 0 && root.nova < 1
    x: root.novaX - width / 2
    y: root.novaY - height / 2
    width: (40 + root.nova * 700) * u; height: width; radius: width / 2
    z: 95
    color: "transparent"
    border.color: root.hack ? root.hackInk : root.sunCore
    border.width: 4 * (1 - root.nova) + 1
    opacity: 1 - root.nova
  }
  Rectangle {
    anchors.fill: parent
    z: 96
    color: root.hack ? root.hackInk : root.sunCore
    opacity: root.nova > 0 ? 0.28 * (1 - root.nova) : 0
  }

  // Readout.
  Column {
    x: 50 * u
    anchors.bottom: parent.bottom; anchors.bottomMargin: 56 * u
    spacing: 6 * u
    z: 90
    QueryText {
      width: 380 * u
      height: 18 * u
      query: root.query
      placeholder: root.hack ? "> track …" : "search the system…"
      color: root.ink
      placeholderColor: root.dim
      caretColor: root.hi
      fontFamily: root.mono
      pixelSize: 13 * u
      live: root.live
    }
    Text {
      textFormat: Text.PlainText
      width: 420 * u
      elide: Text.ElideRight
      text: root.current ? (root.hack ? "contact: " + root.current.label.toLowerCase() : root.current.label) : root.emptyText()
      color: root.ink
      font.family: root.face1; font.pixelSize: 26 * u; font.weight: Font.DemiBold
    }
    Text {
      textFormat: Text.PlainText
      width: 420 * u
      elide: Text.ElideRight
      text: root.current && root.hack ? root.polar(root.selSlot) + "  id 0x" + root.fakeHex(root.selectedIndex, 4) + (root.current.detail ? "  " + root.current.detail : "")
        : root.current ? ["inner", "middle", "outer"][root.selOrbit] + " orbit · body " + (root.selSlot - root.orbitStart(root.selOrbit) + 1)
        + (root.current.detail ? " · " + root.current.detail : "") : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 11 * u; font.letterSpacing: 1
    }
  }

  PageDots {
    anchors.right: parent.right; anchors.rightMargin: 50 * u
    anchors.bottom: parent.bottom; anchors.bottomMargin: 60 * u
    z: 90
    page: root.page
    pages: root.pages
    color: root.dim
    activeColor: root.hi
    dot: 6 * u
    fontFamily: root.mono
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 22 * u
    z: 90
    text: root.hack ? "[j/k] next contact  [h/l] next sector  [enter] engage  [bksp] cd ..  [esc] exit" : "↑↓ / ^j ^k = next body  ·  ←→ / ^h ^l = next system  ·  ↵ = launch  ·  ⌫ = back  ·  esc = close"
    color: root.dim
    font.family: root.face1; font.pixelSize: 11 * u; font.letterSpacing: 2
  }
}
