import QtQuick
import qs.Commons

// "The Red Room" from omlauch's kill room.qml: a kill list of tags nailed to
// a stained wall, blood drips from the ceiling, a heartbeat vignette, stray
// whispers and a crosshair for a cursor. The blood is the theme's red (deep
// and bright variants are mixed from it), the bone is its foreground.
SkinBase {
  id: root

  launchDelay: 560

  readonly property real pitchX: 150 * u
  readonly property real pitchY: 118 * u
  readonly property int cols: Math.max(4, Math.min(8, Math.floor((width - 80 * u) / pitchX)))
  readonly property int visibleRows: Math.max(1, Math.floor((height - 150 * u - 120 * u) / pitchY))
  readonly property int perPage: root.cols * root.visibleRows
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.perPage)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.perPage))
  readonly property int pageStart: root.page * root.perPage
  readonly property real ox: (width - (cols * pitchX - 14 * u)) / 2
  readonly property real oy: 150 * u

  readonly property color blood: root.theme ? root.theme.red : "#c40000"
  readonly property color bright: root.theme ? root.theme.mix(root.blood, "#ffffff", 0.18) : "#ff1a1a"
  readonly property color darkBlood: root.theme ? root.theme.mix(root.blood, root.background, 0.4) : "#8a0303"
  readonly property color bone: root.foreground
  readonly property color dim: root.theme ? root.theme.mix(root.theme.muted, root.blood, 0.2) : "#6b5252"
  readonly property color wall: root.theme ? root.theme.mix(root.background, "#000000", 0.6) : "#050203"
  readonly property color tagFill: root.theme ? root.theme.mix(root.wall, root.blood, 0.06) : "#100808"
  readonly property color tagLine: root.theme ? root.theme.mix(root.wall, root.blood, 0.3) : "#3a1010"

  property int frame: 0
  property var parts: []
  property var drips: []
  property real lungeT: 0
  property string whisper: ""
  property real whisperT: 0
  property real whisperX: 0
  property real whisperY: 0
  readonly property var whispers: ["behind you", "he sees you", "don't blink", "run.", "it's too late", "why did you open this", "one more"]

  function rnd(i, s) { var x = Math.sin(i * 127.1 + s * 311.7) * 43758.5453; return x - Math.floor(x) }

  function tagCenter(index) {
    var slot = index - root.pageStart
    return { x: root.ox + (slot % root.cols) * root.pitchX + 68 * u,
             y: root.oy + Math.floor(slot / root.cols) * root.pitchY + 52 * u }
  }

  function navigate(dx, dy) {
    if (dx !== 0) root.clampTo(root.selectedIndex + dx)
    else root.clampTo(root.selectedIndex + dy * root.cols)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    root.lungeT = Date.now()
    var c = root.tagCenter(index)
    for (var k = 0; k < 22; k++) {
      var a = Math.random() * 6.283
      var sp = 1.5 + Math.random() * 5
      root.parts.push({ x: c.x, y: c.y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp + 1.5,
                        t0: Date.now(), life: 500 + Math.random() * 500, sz: 2 + Math.floor(Math.random() * 5) })
    }
  }

  onWoke: { root.parts = []; root.drips = [] }

  Timer {
    interval: 80; repeat: true; running: root.live
    onTriggered: {
      root.frame++
      if (root.drips.length < 14 && Math.random() < 0.15)
        root.drips.push({ x: Math.random() * root.width, len: 0, max: 40 + Math.random() * 140, v: 0.5 + Math.random() * 1.2 })
      for (var i = 0; i < root.drips.length; i++)
        if (root.drips[i].len < root.drips[i].max) root.drips[i].len += root.drips[i].v
      if (root.frame % 90 === 0 && Math.random() < 0.5) {
        root.whisper = root.whispers[Math.floor(Math.random() * root.whispers.length)]
        root.whisperX = 100 + Math.random() * (root.width - 300)
        root.whisperY = 120 + Math.random() * (root.height - 300)
        root.whisperT = Date.now()
      }
      fx.requestPaint()
    }
  }

  // Walls: gradient, old stains, scratches.
  Canvas {
    anchors.fill: parent
    opacity: Math.max(0.6, root.backdrop)
    property var key: [root.wall, root.blood, root.bone]
    onKeyChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var g = ctx.createLinearGradient(0, 0, 0, height)
      g.addColorStop(0, th.rgba(th.mix(root.wall, root.blood, 0.04), 1))
      g.addColorStop(0.6, th.rgba(root.wall, 1))
      g.addColorStop(1, th.rgba(th.mix(root.wall, "#000000", 0.5), 1))
      ctx.fillStyle = g
      ctx.fillRect(0, 0, width, height)
      for (var i = 0; i < 7; i++) {
        var x = root.rnd(i, 1) * width, y = root.rnd(i, 2) * height
        var r = 40 + root.rnd(i, 3) * 120
        var sg = ctx.createRadialGradient(x, y, 0, x, y, r)
        sg.addColorStop(0, th.rgba(root.darkBlood, 0.12))
        sg.addColorStop(1, th.rgba(root.darkBlood, 0))
        ctx.fillStyle = sg
        ctx.fillRect(x - r, y - r, r * 2, r * 2)
      }
      ctx.strokeStyle = th.rgba(root.bone, 0.05)
      ctx.lineWidth = 1
      for (var j = 0; j < 12; j++) {
        var sx = root.rnd(j, 4) * width, sy = root.rnd(j, 5) * height
        ctx.beginPath()
        ctx.moveTo(sx, sy)
        ctx.lineTo(sx + (root.rnd(j, 6) - 0.5) * 90, sy + (root.rnd(j, 7) - 0.5) * 40)
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

  // The crosshair replaces the pointer everywhere in the room.
  HoverHandler {
    id: hover
    cursorShape: Qt.BlankCursor
    onPointChanged: fx.requestPaint()
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: tag

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: tag.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.perPage
      readonly property bool selHere: root.cursorActive && tag.index === root.selectedIndex
      readonly property bool killed: root.launching && root.launchIndex === tag.index
      property bool entered: false

      visible: tag.onPage
      x: root.ox + (Math.max(0, slot) % root.cols) * root.pitchX
      y: root.oy + Math.floor(Math.max(0, slot) / root.cols) * root.pitchY
      width: 136 * u; height: 104 * u
      rotation: (root.rnd(tag.index, 9) - 0.5) * 7
      scale: entered ? (selHere ? 1.08 : 1) * (killed ? 0.9 : 1) : 0.6
      opacity: entered ? (killed ? 0.25 : 1) : 0
      Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 220 } }
      Timer {
        id: enterTimer
        interval: root.burst ? 30 * Math.min(Math.max(0, tag.slot), 24) : 0
        running: true
        onTriggered: tag.entered = true
      }
      Connections {
        target: root
        function onWoke() { tag.entered = false; enterTimer.restart() }
      }

      Rectangle {
        anchors.fill: parent
        color: root.tagFill
        border.color: tag.selHere ? root.bright : root.tagLine
        border.width: tag.selHere ? 2 : 1
      }
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 4 * u
        width: 6 * u; height: 6 * u
        radius: 3 * u
        color: Util.alpha(root.bone, 0.35)
      }
      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 16 * u
        size: 44 * u
        opacity: 0.9
        kind: tag.kind
        glyph: tag.icon
        glyphFont: tag.iconFont
        appIcon: tag.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: tag.onPage
        fallback: tag.label.charAt(0).toUpperCase()
        color: tag.selHere ? root.bright : root.darkBlood
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 68 * u
        width: 124 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: tag.label
        color: tag.selHere ? root.bone : Util.alpha(root.bone, 0.62)
        font.family: root.mono
        font.pixelSize: 10 * u
        font.bold: tag.selHere
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 84 * u
        text: (root.isBranch(tag.kind) ? "LIST " : "VICTIM ") + String(tag.index + 1).padStart(2, "0")
        color: root.dim
        font.family: root.mono
        font.pixelSize: 8 * u
      }
      Rectangle {
        visible: tag.selHere
        anchors.centerIn: parent
        width: 96 * u; height: 96 * u
        radius: 48 * u
        color: "transparent"
        border.color: Util.alpha(root.bright, 0.8)
        border.width: 2
        rotation: root.frame * 2
      }
      Text {
        visible: tag.killed
        anchors.centerIn: parent
        text: "ELIMINATED"
        color: root.bright
        font.family: root.mono
        font.pixelSize: 16 * u
        font.bold: true
        rotation: -14
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.BlankCursor
        onEntered: root.selectRequested(tag.index)
        onClicked: root.activated(tag.index)
      }
    }
  }

  // Fog, drips, slash and splatter, heartbeat, flicker, whispers, crosshair.
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

      for (var i = 0; i < 3; i++) {
        var fxp = ((t / (9000 + i * 3000)) % 1.4 - 0.2) * W + i * W * 0.3
        var fy = H * (0.75 + i * 0.08)
        var g = ctx.createRadialGradient(fxp, fy, 0, fxp, fy, 260)
        g.addColorStop(0, th.rgba(root.bone, 0.05))
        g.addColorStop(1, th.rgba(root.bone, 0))
        ctx.fillStyle = g
        ctx.fillRect(fxp - 260, fy - 260, 520, 520)
      }

      for (var d = 0; d < root.drips.length; d++) {
        var dr = root.drips[d]
        ctx.strokeStyle = th.rgba(root.darkBlood, 0.7)
        ctx.lineWidth = 2
        ctx.beginPath(); ctx.moveTo(dr.x, 0); ctx.lineTo(dr.x, dr.len); ctx.stroke()
        ctx.beginPath(); ctx.arc(dr.x, dr.len + 2, 2.5, 0, 6.2832)
        ctx.fillStyle = th.rgba(root.blood, 0.8)
        ctx.fill()
      }

      if (root.launching && root.launchIndex >= 0) {
        var c = root.tagCenter(root.launchIndex)
        var pr = Math.min(1, (t - root.lungeT) / 560)
        ctx.save()
        ctx.globalAlpha = 1 - pr
        ctx.translate(c.x, c.y)
        ctx.strokeStyle = th.rgba(th.mix(root.bone, "#ffffff", 0.5), 1)
        ctx.lineWidth = 3
        ctx.shadowColor = th.rgba(root.bright, 1)
        ctx.shadowBlur = 14
        var L = 30 + pr * 90
        ctx.beginPath(); ctx.moveTo(-L, -L * 0.6); ctx.lineTo(L, L * 0.6); ctx.stroke()
        ctx.beginPath(); ctx.moveTo(-L, L * 0.7); ctx.lineTo(L * 0.9, -L * 0.5); ctx.stroke()
        ctx.restore()
      }
      for (var p = root.parts.length - 1; p >= 0; p--) {
        var pt = root.parts[p]
        var age = t - pt.t0
        if (age > pt.life) { root.parts.splice(p, 1); continue }
        pt.x += pt.vx; pt.y += pt.vy
        pt.vy += 0.1
        ctx.fillStyle = th.rgba(root.blood, 1 - age / pt.life)
        ctx.fillRect(pt.x, pt.y, pt.sz, pt.sz)
      }

      var ph = t % 1200
      var i1 = Math.max(0, 1 - Math.abs(ph - 100) / 120)
      var i2 = Math.max(0, 1 - Math.abs(ph - 420) / 140) * 0.6
      var vig = 0.22 + 0.30 * (i1 + i2)
      var vg = ctx.createRadialGradient(W / 2, H / 2, H * 0.3, W / 2, H / 2, H * 0.9)
      vg.addColorStop(0, "rgba(0,0,0,0)")
      vg.addColorStop(1, th.rgba(root.darkBlood, vig))
      ctx.fillStyle = vg
      ctx.fillRect(0, 0, W, H)

      if (Math.random() < 0.04) {
        ctx.fillStyle = th.rgba(root.bone, 0.03)
        ctx.fillRect(0, 0, W, H)
      }

      if (t - root.whisperT < 400 && root.whisper !== "") {
        ctx.font = "italic " + Math.round(15 * root.u) + "px monospace"
        ctx.fillStyle = th.rgba(root.bone, 0.25)
        ctx.fillText(root.whisper, root.whisperX, root.whisperY)
      }

      if (hover.hovered) {
        ctx.save()
        ctx.translate(hover.point.position.x, hover.point.position.y)
        ctx.rotate(t / 2000)
        ctx.strokeStyle = th.rgba(root.bright, 0.9)
        ctx.lineWidth = 1.4
        ctx.beginPath(); ctx.arc(0, 0, 10, 0, 6.2832); ctx.stroke()
        ctx.beginPath()
        ctx.moveTo(-16, 0); ctx.lineTo(-6, 0); ctx.moveTo(6, 0); ctx.lineTo(16, 0)
        ctx.moveTo(0, -16); ctx.lineTo(0, -6); ctx.moveTo(0, 6); ctx.lineTo(0, 16)
        ctx.stroke()
        ctx.beginPath(); ctx.arc(0, 0, 1.6, 0, 6.2832)
        ctx.fillStyle = th.rgba(root.bright, 1)
        ctx.fill()
        ctx.restore()
      }
    }
  }

  // HUD.
  Text {
    x: 30 * u; y: 26 * u
    textFormat: Text.PlainText
    text: "KILL LIST // " + root.title.toUpperCase() + " // " + root.count + " NAMES" + (root.pages > 1 ? " // PAGE " + (root.page + 1) + "/" + root.pages : "")
    color: root.darkBlood
    font.family: root.mono; font.pixelSize: 13 * u; font.bold: true
    z: 600
  }
  Text {
    x: 30 * u; y: 46 * u
    textFormat: Text.PlainText
    text: "MARK: " + (root.current ? root.current.label.toUpperCase() : "—")
    color: root.bone
    font.family: root.mono; font.pixelSize: 10 * u
    z: 600
  }
  Text {
    anchors.right: parent.right
    anchors.rightMargin: 40 * u
    y: 26 * u
    text: "● REC"
    color: root.bright
    font.family: root.mono; font.pixelSize: 13 * u; font.bold: true
    visible: Math.floor(root.frame / 8) % 2 === 0
    z: 600
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 40 * u
    text: "T H E   RED  R O O M"
    color: root.blood
    font.family: root.mono; font.pixelSize: 26 * u; font.bold: true
    z: 600
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 74 * u
    text: "every app dies tonight"
    color: root.dim
    font.family: root.mono; font.pixelSize: 10 * u; font.italic: true
    z: 600
  }

  Text {
    visible: root.count === 0
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: root.query.length > 0 ? "no one here answers to “" + root.query + "”" : "the room is empty"
    color: root.bone
    font.family: root.mono
    font.pixelSize: 16 * u
    z: 600
  }

  // Search = the ledger.
  Rectangle {
    x: root.width / 2 - 200 * u; y: root.height - 92 * u
    width: 400 * u; height: 42 * u
    color: root.tagFill
    border.color: root.query.length > 0 ? root.blood : root.tagLine
    border.width: 1
    z: 600
    Text { x: 14 * u; anchors.verticalCenter: parent.verticalCenter; text: "✗"; color: root.bright; font.pixelSize: 15 * u }
    QueryText {
      x: 38 * u; anchors.verticalCenter: parent.verticalCenter
      width: 340 * u
      query: root.query
      placeholder: "mark your next victim…"
      color: root.bone
      placeholderColor: root.dim
      caretColor: root.bright
      fontFamily: root.mono
      pixelSize: 13 * u
      live: root.live
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 34 * u
    text: "HOVER = MARK · CLICK / ↵ = KILL · WHEEL / ARROWS = NEXT VICTIM · ⌫ = BACK · ESC = ESCAPE THE ROOM"
    color: root.dim
    font.family: root.mono; font.pixelSize: 10 * u
    opacity: 0.9
    z: 600
  }
}
