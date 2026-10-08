import QtQuick
import qs.Commons

// "Pixel Arcade" from omlauch's game.qml: cartridges on a pixel starfield,
// a ticking 1UP score, INSERT COIN, CRT scanlines and a pixel explosion on
// launch. The four arcade neons cycle through the theme's yellow, magenta,
// cyan and green.
SkinBase {
  id: root

  launchDelay: 520

  readonly property real pitchX: 146 * u
  readonly property real pitchY: 110 * u
  readonly property int cols: Math.max(4, Math.min(8, Math.floor((width - 80 * u) / pitchX)))
  readonly property int visibleRows: Math.max(1, Math.floor((height - 150 * u - 70 * u) / pitchY))
  readonly property int perPage: root.cols * root.visibleRows
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.perPage)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.perPage))
  readonly property int pageStart: root.page * root.perPage
  readonly property real ox: (width - (cols * pitchX - 14 * u)) / 2
  readonly property real oy: 150 * u

  readonly property color cYellow: root.theme ? root.theme.yellow : "#ffd700"
  readonly property color cMagenta: root.theme ? root.theme.magenta : "#ff00ff"
  readonly property color cCyan: root.theme ? root.theme.cyan : "#00ffff"
  readonly property color cGreen: root.theme ? root.theme.green : "#00ff00"
  readonly property color cRed: root.theme ? root.theme.red : "#ff3355"
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.5) : "#05060f"
  readonly property color cart: root.theme ? root.theme.mix(root.background, root.foreground, 0.04) : "#0d1022"
  readonly property var arcadePal: [cYellow, cMagenta, cCyan, cGreen]
  property int frame: 0
  property int score: 0
  readonly property color cycle: arcadePal[Math.floor(frame / 10) % 4]
  property var parts: []
  property real lungeT: 0

  function navigate(dx, dy) {
    if (dx !== 0) root.clampTo(root.selectedIndex + dx)
    else root.clampTo(root.selectedIndex + dy * root.cols)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    root.lungeT = Date.now()
    var slot = index - root.pageStart
    var tx = root.ox + (slot % root.cols) * root.pitchX + 66 * u
    var ty = root.oy + Math.floor(slot / root.cols) * root.pitchY + 48 * u
    for (var k = 0; k < 22; k++) {
      var a = Math.random() * 6.283
      var sp = 2 + Math.random() * 5
      root.parts.push({ x: tx, y: ty, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp - 1,
                        t0: Date.now(), life: 400 + Math.random() * 400,
                        sz: 3 + Math.floor(Math.random() * 5), col: Math.floor(Math.random() * 4) })
    }
  }

  onWoke: { root.score = 0; root.parts = [] }

  Timer {
    interval: 80; repeat: true; running: root.live
    onTriggered: { root.frame++; root.score += 10; fx.requestPaint() }
  }
  Timer { interval: 500; repeat: true; running: root.live; onTriggered: root.score += 100 }

  Rectangle { anchors.fill: parent; color: root.deep; opacity: Math.max(0.6, root.backdrop) }

  Canvas {
    anchors.fill: parent
    property var pal: root.theme ? [root.theme.rgba(root.cYellow, 0.5), root.theme.rgba(root.cCyan, 0.4), root.theme.rgba(root.foreground, 0.35)] : ["rgba(255,215,0,0.5)", "rgba(0,255,255,0.4)", "rgba(248,248,255,0.35)"]
    onPalChanged: requestPaint()
    onWidthChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      for (var i = 0; i < 90; i++) {
        var x = ((Math.sin(i * 127.1) * 43758.5 % 1) + 1) % 1 * width
        var y = ((Math.sin(i * 311.7) * 43758.5 % 1) + 1) % 1 * height
        var s = 1 + (i % 3)
        ctx.fillStyle = i % 7 === 0 ? pal[0] : (i % 5 === 0 ? pal[1] : pal[2])
        ctx.fillRect(Math.floor(x / 3) * 3, Math.floor(y / 3) * 3, s, s)
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

  // HUD.
  Text {
    x: 30 * u; y: 24 * u
    text: "1UP\n" + String(root.score).padStart(6, "0")
    color: root.foreground
    font.family: root.mono
    font.pixelSize: 14 * u
    font.bold: true
    lineHeight: 1.3
    z: 60
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 24 * u
    textFormat: Text.PlainText
    text: "★ " + root.title.toUpperCase() + " ARCADE ★"
    color: root.cycle
    font.family: root.mono
    font.pixelSize: 22 * u
    font.bold: true
    z: 60
  }
  Text {
    anchors.right: parent.right
    anchors.rightMargin: 40 * u
    y: 24 * u
    text: "HI-SCORE\n999999"
    color: root.cRed
    font.family: root.mono
    font.pixelSize: 14 * u
    font.bold: true
    lineHeight: 1.3
    z: 60
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 62 * u
    text: root.pages > 1 ? "INSERT COIN · STAGE " + (root.page + 1) + "/" + root.pages : "INSERT COIN"
    color: root.cYellow
    font.family: root.mono
    font.pixelSize: 12 * u
    visible: Math.floor(root.frame / 8) % 2 === 0
    z: 60
  }

  // Search = coin slot.
  Rectangle {
    x: root.width / 2 - 200 * u; y: 92 * u
    width: 400 * u; height: 40 * u
    color: root.cart
    border.color: root.query.length > 0 ? root.cycle : root.theme ? root.theme.mix(root.cart, root.foreground, 0.18) : "#2a3050"
    border.width: 3
    z: 60
    Text {
      x: 14 * u; anchors.verticalCenter: parent.verticalCenter
      text: "»"
      color: root.cCyan
      font.family: root.mono
      font.pixelSize: 16 * u
    }
    QueryText {
      x: 38 * u; anchors.verticalCenter: parent.verticalCenter
      width: 340 * u
      query: root.query
      placeholder: "type to filter cartridges…"
      color: root.foreground
      placeholderColor: root.dim
      caretColor: root.cycle
      fontFamily: root.mono
      pixelSize: 14 * u
      live: root.live
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: tileItem

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: tileItem.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.perPage
      readonly property bool selHere: root.cursorActive && tileItem.index === root.selectedIndex
      readonly property bool launchingHere: root.launching && root.launchIndex === tileItem.index
      property bool entered: false

      visible: tileItem.onPage
      x: root.ox + (Math.max(0, slot) % root.cols) * root.pitchX
      y: root.oy + Math.floor(Math.max(0, slot) / root.cols) * root.pitchY
      width: 132 * u; height: 96 * u
      scale: entered ? (selHere ? 1.06 : 1) * (launchingHere ? 0.85 : 1) : 0.6
      opacity: entered ? (launchingHere ? 0 : 1) : 0
      Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 220 } }
      Timer {
        id: enterTimer
        interval: root.burst ? 30 * Math.min(Math.max(0, tileItem.slot), 24) : 0
        running: true
        onTriggered: tileItem.entered = true
      }
      Connections {
        target: root
        function onWoke() { tileItem.entered = false; enterTimer.restart() }
      }

      Rectangle {
        anchors.fill: parent
        color: root.cart
        border.color: tileItem.selHere ? root.cycle : (root.theme ? root.theme.mix(root.cart, root.foreground, 0.14) : "#232a4a")
        border.width: 3
      }
      // Chunky pixel corners.
      Rectangle { x: -3; y: -3; width: 6; height: 6; color: root.deep }
      Rectangle { x: parent.width - 3; y: -3; width: 6; height: 6; color: root.deep }
      Rectangle { x: -3; y: parent.height - 3; width: 6; height: 6; color: root.deep }
      Rectangle { x: parent.width - 3; y: parent.height - 3; width: 6; height: 6; color: root.deep }

      Text {
        visible: tileItem.selHere
        x: 6 * u + (Math.floor(root.frame / 8) % 2) * 3
        y: 6 * u
        text: "▶"
        color: root.cYellow
        font.family: root.mono
        font.pixelSize: 14 * u
      }

      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 14 * u
        size: 40 * u
        kind: tileItem.kind
        glyph: tileItem.icon
        glyphFont: tileItem.iconFont
        appIcon: tileItem.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: tileItem.onPage
        fallback: tileItem.label.charAt(0).toUpperCase()
        color: tileItem.selHere ? root.cycle : root.cCyan
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 64 * u
        width: 120 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.isBranch(tileItem.kind) ? tileItem.label + " ›" : tileItem.label
        color: tileItem.selHere ? root.foreground : Util.alpha(root.foreground, 0.65)
        font.family: root.mono
        font.pixelSize: 10 * u
        font.bold: tileItem.selHere
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(tileItem.index)
        onClicked: root.activated(tileItem.index)
      }
    }
  }

  Text {
    visible: root.count === 0
    anchors.centerIn: parent
    text: "GAME OVER — NO CARTRIDGES FOUND"
    color: root.cRed
    font.family: root.mono
    font.pixelSize: 18 * u
    font.bold: true
    z: 60
  }

  // Pixel explosions, GAME START and the rolling CRT band.
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
      var pal = [th.rgba(root.cYellow, 1), th.rgba(root.cMagenta, 1), th.rgba(root.cCyan, 1), th.rgba(root.cGreen, 1)]
      for (var i = root.parts.length - 1; i >= 0; i--) {
        var p = root.parts[i]
        var age = t - p.t0
        if (age > p.life) { root.parts.splice(i, 1); continue }
        p.x += p.vx; p.y += p.vy
        p.vy += 0.12
        ctx.globalAlpha = 1 - age / p.life
        ctx.fillStyle = pal[p.col]
        ctx.fillRect(Math.floor(p.x / 3) * 3, Math.floor(p.y / 3) * 3, p.sz, p.sz)
      }
      ctx.globalAlpha = 1
      if (root.launching) {
        var pr = Math.min(1, (t - root.lungeT) / 520)
        if (pr < 0.7) {
          ctx.font = "bold " + Math.round(34 * root.u) + "px monospace"
          ctx.textAlign = "center"
          ctx.fillStyle = pr < 0.35 ? pal[0] : pal[1]
          ctx.fillText("GAME START!", width / 2, height / 2)
        }
      }
      var by = (t / 22) % (height + 160) - 80
      var g = ctx.createLinearGradient(0, by - 40, 0, by + 40)
      g.addColorStop(0, th.rgba(root.foreground, 0))
      g.addColorStop(0.5, th.rgba(root.foreground, 0.03))
      g.addColorStop(1, th.rgba(root.foreground, 0))
      ctx.fillStyle = g
      ctx.fillRect(0, by - 40, width, 80)
    }
  }

  // CRT scanlines and vignette.
  Canvas {
    anchors.fill: parent
    z: 600
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = "rgba(0,0,0,0.16)"
      for (var y = 0; y < height; y += 3) ctx.fillRect(0, y, width, 1)
      var g = ctx.createRadialGradient(width / 2, height / 2, height * 0.35, width / 2, height / 2, height * 0.95)
      g.addColorStop(0, "rgba(0,0,0,0)")
      g.addColorStop(1, "rgba(0,0,0,0.55)")
      ctx.fillStyle = g
      ctx.fillRect(0, 0, width, height)
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 30 * u
    text: "ARROWS/WHEEL = MOVE CURSOR · CLICK/↵ = START GAME · ⌫ = BACK · ESC = QUIT TO CONTINUE"
    color: root.dim
    font.family: root.mono
    font.pixelSize: 11 * u
    opacity: 0.9
    z: 601
  }
}
