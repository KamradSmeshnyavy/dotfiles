import QtQuick
import qs.Commons

// "Stark OS" from omlauch's iron man.qml: an arc reactor in the middle, rows
// as holo-chips orbiting it on two tilted rings, a zoom card over the locked
// chip, a target-analysis readout and a repulsor beam on launch. The HUD glow
// is the theme accent, the lock highlight is its yellow, warnings its red.
SkinBase {
  id: root

  launchDelay: 500

  readonly property real cx: width / 2
  readonly property real cy: height / 2
  readonly property real ring1: Math.min(width, height) * 0.36
  readonly property real ring2: ring1 + 110 * u
  // Two rings hold this many chips before they start to overlap; longer
  // menus orbit a page at a time.
  readonly property int perPage: 46
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.perPage)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.perPage))
  readonly property int pageStart: root.page * root.perPage
  readonly property int pageCount: Math.max(0, Math.min(root.perPage, root.count - root.pageStart))

  readonly property color hud: root.accent
  readonly property color ice: root.theme ? root.theme.bright : root.foreground
  readonly property color gold: root.theme ? root.theme.yellow : "#ffb347"
  readonly property color warn: root.theme ? root.theme.red : "#ff4757"
  readonly property color dim: root.theme ? root.theme.mix(root.theme.muted, root.hud, 0.25) : "#4a7a9a"
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.5) : "#04101d"
  readonly property color panel: root.theme ? root.theme.mix(root.deep, root.hud, 0.08) : "#0a1e30"
  readonly property color panelLine: root.theme ? root.theme.mix(root.deep, root.hud, 0.4) : "#2a5a7a"

  property real rot: 0
  property int frame: 0
  property bool bootDone: false
  property int bootStep: 0
  property real lungeT: 0
  property real beamX: 0
  property real beamY: 0
  property string telem1: "0x0000"
  property string telem2: "0x0000"

  function slotAngle(slot) {
    var n = root.pageCount
    var cap1 = Math.min(n, 16)
    if (slot < cap1) return { a: (slot / cap1) * 6.283 - 1.5708, ring: root.ring1 }
    var j = slot - cap1, m = n - cap1
    return { a: (j / Math.max(1, m)) * 6.283 - 1.5708 + 0.2, ring: root.ring2 }
  }

  function chipPos(slot) {
    var d = root.slotAngle(slot)
    var a = d.a + root.rot
    return Qt.point(root.cx + Math.cos(a) * d.ring, root.cy + Math.sin(a) * d.ring * 0.78)
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    var p = root.chipPos(index - root.pageStart)
    root.beamX = p.x
    root.beamY = p.y
    root.lungeT = Date.now()
  }

  Timer {
    interval: 60; repeat: true; running: root.live
    onTriggered: {
      root.frame++
      if (root.frame % 2 === 0) {
        root.telem1 = "0x" + Math.floor(Math.random() * 65535).toString(16).toUpperCase().padStart(4, "0")
        root.telem2 = "0x" + Math.floor(Math.random() * 65535).toString(16).toUpperCase().padStart(4, "0")
      }
      reactor.requestPaint()
    }
  }
  // The boot sequence plays once per shell session: on every open it would
  // stand between the keystroke and the menu.
  Timer { interval: 250; running: true; onTriggered: root.bootStep = 1 }
  Timer { interval: 500; running: true; onTriggered: root.bootStep = 2 }
  Timer { interval: 750; running: true; onTriggered: root.bootStep = 3 }
  Timer { interval: 1000; running: true; onTriggered: root.bootDone = true }

  Rectangle { anchors.fill: parent; color: root.deep; opacity: Math.max(0.6, root.backdrop) }

  Canvas {
    anchors.fill: parent
    property color line: root.hud
    onLineChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var W = width, H = height
      var g = ctx.createRadialGradient(root.cx, root.cy, H * 0.3, root.cx, root.cy, H * 0.95)
      g.addColorStop(0, "rgba(0,0,0,0)")
      g.addColorStop(1, "rgba(0,0,0,0.6)")
      ctx.fillStyle = g
      ctx.fillRect(0, 0, W, H)
      ctx.strokeStyle = th.rgba(root.hud, 0.5)
      ctx.lineWidth = 2
      var L = 34, m = 18
      ctx.beginPath()
      ctx.moveTo(m, m + L); ctx.lineTo(m, m); ctx.lineTo(m + L, m)
      ctx.moveTo(W - m - L, m); ctx.lineTo(W - m, m); ctx.lineTo(W - m, m + L)
      ctx.moveTo(W - m, H - m - L); ctx.lineTo(W - m, H - m); ctx.lineTo(W - m - L, H - m)
      ctx.moveTo(m + L, H - m); ctx.lineTo(m, H - m); ctx.lineTo(m, H - m - L)
      ctx.stroke()
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    property real lastX: 0
    property real pressX: 0
    property bool dragged: false
    onPressed: function(mouse) { lastX = mouse.x; pressX = mouse.x; dragged = false }
    onPositionChanged: function(mouse) {
      if (!pressed) return
      if (Math.abs(mouse.x - pressX) > 6) dragged = true
      root.rot += (mouse.x - lastX) * 0.004
      lastX = mouse.x
    }
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else if (!dragged) root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Arc reactor and the repulsor beam.
  Canvas {
    id: reactor
    anchors.fill: parent
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var t = Date.now()
      var cx = root.cx, cy = root.cy
      var pulse = 0.5 + 0.5 * Math.sin(t / 450)

      ctx.save(); ctx.translate(cx, cy); ctx.rotate(t / 4000)
      ctx.setLineDash([34, 14])
      ctx.beginPath(); ctx.arc(0, 0, 118, 0, 6.2832)
      ctx.strokeStyle = th.rgba(root.hud, 0.55); ctx.lineWidth = 5; ctx.stroke()
      ctx.setLineDash([]); ctx.restore()

      ctx.save(); ctx.translate(cx, cy); ctx.rotate(-t / 2600)
      ctx.setLineDash([10, 8])
      ctx.beginPath(); ctx.arc(0, 0, 96, 0, 6.2832)
      ctx.strokeStyle = th.rgba(root.hud, 0.8); ctx.lineWidth = 2.5; ctx.stroke()
      ctx.setLineDash([]); ctx.restore()

      ctx.save(); ctx.translate(cx, cy); ctx.rotate(t / 6000)
      ctx.strokeStyle = th.rgba(root.ice, 0.5); ctx.lineWidth = 1.5
      for (var k = 0; k < 36; k++) {
        ctx.rotate(6.2832 / 36)
        ctx.beginPath(); ctx.moveTo(0, -82); ctx.lineTo(0, k % 3 === 0 ? -74 : -78); ctx.stroke()
      }
      ctx.restore()

      var g = ctx.createRadialGradient(cx, cy, 0, cx, cy, 70)
      g.addColorStop(0, th.rgba(root.ice, 0.75 + 0.2 * pulse))
      g.addColorStop(0.35, th.rgba(root.hud, 0.5))
      g.addColorStop(1, th.rgba(root.hud, 0))
      ctx.fillStyle = g
      ctx.fillRect(cx - 70, cy - 70, 140, 140)

      ctx.save(); ctx.translate(cx, cy); ctx.rotate(t / 3000)
      ctx.beginPath()
      for (var j = 0; j < 3; j++) {
        var a = j * 2.0944 - 1.5708
        if (j === 0) ctx.moveTo(Math.cos(a) * 34, Math.sin(a) * 34)
        else ctx.lineTo(Math.cos(a) * 34, Math.sin(a) * 34)
      }
      ctx.closePath()
      ctx.strokeStyle = th.rgba(root.ice, 1); ctx.lineWidth = 2.5; ctx.stroke()
      ctx.restore()

      if (root.launching) {
        var pr = Math.min(1, (t - root.lungeT) / 520)
        ctx.save()
        ctx.globalAlpha = 1 - pr
        ctx.beginPath(); ctx.moveTo(cx, cy); ctx.lineTo(root.beamX, root.beamY)
        ctx.strokeStyle = th.rgba(root.hud, 0.5); ctx.lineWidth = 10; ctx.stroke()
        ctx.strokeStyle = th.rgba(root.ice, 1); ctx.lineWidth = 3; ctx.stroke()
        ctx.beginPath(); ctx.arc(root.beamX, root.beamY, 8 + pr * 90, 0, 6.2832)
        ctx.strokeStyle = th.rgba(root.ice, 0.9 * (1 - pr)); ctx.lineWidth = 2.5; ctx.stroke()
        ctx.restore()
      }
    }
  }

  // Holo chips.
  Repeater {
    model: root.rowModel

    delegate: Item {
      id: chip

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: chip.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property bool selHere: root.cursorActive && chip.index === root.selectedIndex
      readonly property point p: chip.onPage ? root.chipPos(chip.slot) : Qt.point(root.cx, root.cy)
      readonly property real depth: chip.onPage ? (Math.sin(root.slotAngle(chip.slot).a + root.rot) + 1) / 2 : 0
      property bool entered: false

      visible: chip.onPage
      x: p.x - width / 2
      y: p.y - height / 2
      z: 100 + Math.round(depth * 60)
      width: 92 * u; height: 60 * u
      scale: (0.85 + 0.3 * depth) * (entered ? 1 : 0.5) * (selHere ? 1.25 : 1)
      opacity: entered ? (0.45 + 0.55 * depth) : 0
      Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 240 } }
      Timer {
        id: enterTimer
        interval: root.burst ? 20 * Math.min(Math.max(0, chip.slot), 30) : 0
        running: true
        onTriggered: chip.entered = true
      }
      Connections {
        target: root
        function onWoke() { chip.entered = false; enterTimer.restart() }
      }

      Rectangle {
        anchors.fill: parent
        color: chip.selHere ? root.theme ? root.theme.mix(root.panel, root.hud, 0.15) : "#1a3a52" : root.panel
        border.color: chip.selHere ? root.gold : root.panelLine
        border.width: chip.selHere ? 2 : 1
      }
      Rectangle { x: 0; y: 0; width: 8 * u; height: 2; color: root.hud }
      Rectangle { x: parent.width - 8 * u; y: parent.height - 2; width: 8 * u; height: 2; color: root.hud }

      RowIcon {
        x: 8 * u; y: 14 * u
        size: 30 * u
        kind: chip.kind
        glyph: chip.icon
        glyphFont: chip.iconFont
        appIcon: chip.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: chip.onPage
        fallback: chip.label.charAt(0).toUpperCase()
        color: chip.selHere ? root.gold : root.hud
      }
      Text {
        x: 44 * u; y: 12 * u
        width: 44 * u
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: chip.label
        color: chip.selHere ? root.ice : Util.alpha(root.ice, 0.68)
        font.family: root.mono
        font.pixelSize: 9 * u
        font.bold: chip.selHere
      }
      Text {
        x: 44 * u; y: 26 * u
        text: root.isBranch(chip.kind) ? "SUBSYS" : "PWR " + String(80 + Math.floor(chip.depth * 19))
        color: chip.selHere ? root.gold : root.dim
        font.family: root.mono
        font.pixelSize: 8 * u
      }
      Text {
        x: 4 * u; y: 48 * u
        text: String(chip.index + 1).padStart(2, "0")
        color: root.dim
        font.family: root.mono
        font.pixelSize: 8 * u
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(chip.index)
        onClicked: root.activated(chip.index)
      }
    }
  }

  // Zoom card over the locked chip.
  Item {
    readonly property point zp: root.current ? root.chipPos(root.selectedIndex - root.pageStart) : Qt.point(root.cx, root.cy)
    x: Math.max(16, Math.min(root.width - 196 * u, zp.x - 90 * u))
    y: zp.y > 300 * u ? zp.y - 216 * u : zp.y + 66 * u
    width: 180 * u; height: 150 * u
    z: 800
    visible: root.count > 0 && !root.launching && root.bootDone
    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle { anchors.fill: parent; color: root.panel; opacity: 0.95; border.color: root.gold; border.width: 2 }
    Rectangle { x: 0; y: 0; width: 14 * u; height: 3; color: root.hud }
    Rectangle { x: parent.width - 14 * u; y: parent.height - 3; width: 14 * u; height: 3; color: root.hud }
    RowIcon {
      anchors.horizontalCenter: parent.horizontalCenter
      y: 14 * u
      size: 72 * u
      kind: root.current ? root.current.kind : ""
      glyph: root.current ? root.current.icon : ""
      glyphFont: root.current ? root.current.iconFont : ""
      appIcon: root.current ? root.current.appIcon : ""
      resolver: root.iconResolver
      fontFamily: root.fontFamily
      fallback: root.current ? root.current.label.charAt(0).toUpperCase() : ""
      color: root.hud
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      y: 94 * u
      width: 170 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.label : ""
      color: root.ice
      font.family: root.mono; font.pixelSize: 13 * u; font.bold: true
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      y: 112 * u
      width: 170 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.detail : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 9 * u
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      y: 128 * u
      text: root.current && root.isBranch(root.current.kind) ? "↵ = ENGAGE" : "↵ = LAUNCH"
      color: root.gold
      font.family: root.mono; font.pixelSize: 9 * u
      visible: Math.floor(root.frame / 12) % 2 === 0
    }
  }

  // Readout panel.
  Rectangle {
    x: root.width - 250 * u; y: root.cy - 90 * u
    width: 220 * u; height: 180 * u
    color: Util.alpha(root.panel, 0.8)
    border.color: root.panelLine
    z: 300
    Text { x: 14 * u; y: 12 * u; text: "TARGET ANALYSIS"; color: root.gold; font.family: root.mono; font.pixelSize: 10 * u; font.bold: true }
    Text {
      x: 14 * u; y: 34 * u
      width: 190 * u
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.label.toUpperCase() : "—"
      color: root.ice
      font.family: root.mono; font.pixelSize: 15 * u; font.bold: true
    }
    Text {
      x: 14 * u; y: 56 * u
      width: 190 * u
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? "CLASS: " + (root.current.kind === "app" ? "APPLICATION" : root.isBranch(root.current.kind) ? "SUBSYSTEM" : "PROTOCOL") : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 9 * u
    }
    Text { x: 14 * u; y: 72 * u; text: "STATUS: FRIENDLY · CLEARED"; color: root.hud; font.family: root.mono; font.pixelSize: 9 * u }
    Text { x: 14 * u; y: 96 * u; text: "PWR CORE"; color: root.dim; font.family: root.mono; font.pixelSize: 8 * u }
    Repeater {
      model: 5
      Rectangle {
        required property int index
        x: (14 + index * 40) * u
        y: 108 * u
        width: 34 * u; height: 8 * u
        color: root.deep
        border.color: root.panelLine
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          x: 1; height: 6 * u
          radius: 2
          width: 14 * u
          color: index === 4 ? root.gold : root.hud
          SequentialAnimation on width {
            loops: Animation.Infinite
            running: root.live
            NumberAnimation { to: (10 + ((index * 53) % 22)) * u; duration: 400 + index * 120; easing.type: Easing.InOutSine }
            NumberAnimation { to: (20 + ((index * 31) % 12)) * u; duration: 350 + index * 90; easing.type: Easing.InOutSine }
          }
        }
      }
    }
    Text { x: 14 * u; y: 132 * u; text: "MEM " + root.telem1 + "  IO " + root.telem2; color: root.dim; font.family: root.mono; font.pixelSize: 8 * u }
    Text { x: 14 * u; y: 150 * u; text: "REPULSORS: ARMED"; color: root.warn; font.family: root.mono; font.pixelSize: 8 * u; visible: Math.floor(root.frame / 12) % 2 === 0 }
  }

  // HUD header.
  Text {
    x: 30 * u; y: 26 * u
    textFormat: Text.PlainText
    text: "STARK OS // " + root.title.toUpperCase()
    color: root.hud
    font.family: root.mono; font.pixelSize: 13 * u; font.bold: true
    z: 300
  }
  Text { x: 30 * u; y: 46 * u; text: "ARC REACTOR OUTPUT: 8.4 GJ · " + root.telem1; color: root.dim; font.family: root.mono; font.pixelSize: 9 * u; z: 300 }
  Text {
    anchors.right: parent.right
    anchors.rightMargin: 40 * u
    y: 26 * u
    text: root.count + " SYSTEMS" + (root.pages > 1 ? " · BANK " + (root.page + 1) + "/" + root.pages : "")
    color: root.gold
    font.family: root.mono; font.pixelSize: 12 * u; font.bold: true
    z: 300
  }
  Text {
    visible: root.count === 0
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.cy + 140 * u
    textFormat: Text.PlainText
    text: root.query.length > 0 ? "NO SYSTEM MATCHES “" + root.query.toUpperCase() + "”" : "NO SYSTEMS ONLINE"
    color: root.warn
    font.family: root.mono; font.pixelSize: 13 * u; font.bold: true
    z: 300
  }

  Rectangle {
    x: root.cx - 190 * u; y: root.height - 92 * u
    width: 380 * u; height: 42 * u
    color: Util.alpha(root.panel, 0.8)
    border.color: root.query.length > 0 ? root.hud : root.panelLine
    border.width: 1
    z: 300
    Text { x: 14 * u; anchors.verticalCenter: parent.verticalCenter; text: "»"; color: root.gold; font.family: root.mono; font.pixelSize: 15 * u }
    QueryText {
      x: 36 * u; anchors.verticalCenter: parent.verticalCenter
      width: 320 * u
      query: root.query
      placeholder: "query the mainframe…"
      color: root.ice
      placeholderColor: root.dim
      caretColor: root.hud
      fontFamily: root.mono
      pixelSize: 13 * u
      live: root.live
    }
  }

  // Boot sequence.
  Rectangle {
    anchors.fill: parent
    color: root.deep
    opacity: root.bootDone ? 0 : 1
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 350 } }
    z: 900
    Column {
      anchors.centerIn: parent
      spacing: 8 * u
      Text { anchors.horizontalCenter: parent.horizontalCenter; text: "STARK INDUSTRIES"; color: root.gold; font.family: root.mono; font.pixelSize: 24 * u; font.bold: true }
      Text { text: "> ARC REACTOR ONLINE"; color: root.hud; font.family: root.mono; font.pixelSize: 12 * u; opacity: root.bootStep >= 1 ? 1 : 0 }
      Text { text: "> CALIBRATING HUD RINGS…"; color: root.hud; font.family: root.mono; font.pixelSize: 12 * u; opacity: root.bootStep >= 2 ? 1 : 0 }
      Text { text: "> MARK VII READY. WELCOME BACK, BOSS."; color: root.ice; font.family: root.mono; font.pixelSize: 12 * u; opacity: root.bootStep >= 3 ? 1 : 0 }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 34 * u
    text: "DRAG = SPIN ORBIT · WHEEL/ARROWS = CYCLE · HOVER = LOCK · CLICK/↵ = REPULSOR LAUNCH · ⌫ = BACK · ESC = POWER DOWN"
    color: root.dim
    font.family: root.mono; font.pixelSize: 10 * u
    opacity: 0.9
    z: 300
  }
}
