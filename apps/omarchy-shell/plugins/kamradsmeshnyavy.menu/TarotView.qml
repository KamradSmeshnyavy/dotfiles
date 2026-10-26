import QtQuick
import qs.Commons

// Tarot: the rows are a hand of cards fanned on a dark cloth between two
// candles. The selected card rises out of the fan and turns face up — its
// arcanum numeral, its sigil (the row's icon) and its name — while the rest
// show their backs in the row's own hue. Launching burns the card away.
SkinBase {
  id: root

  launchDelay: 560

  // deck.bin deals every card face up, so the fan opens wide enough
  // (~134u per card) that neighbours don't cover each other's sigil and name.
  readonly property int fanReach: root.hack ? 5 : 6
  readonly property real cardW: 128 * u
  readonly property real cardH: 204 * u
  readonly property real pivotX: width / 2
  readonly property real pivotY: height + 460 * u
  readonly property real fanR: 700 * u
  readonly property real spread: root.hack ? 11 : 6.5

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  // tarot-hack (deck.bin) draws everything through these: wireframe cards,
  // hex ids, no candles.
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55))
  readonly property color gilt: root.hack ? root.hackInk : (root.theme ? root.theme.mix(root.theme.yellow, root.foreground, 0.2) : "#d8b46a")
  readonly property color cloth: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.theme.magenta, 0.1) : "#1b1222")
  readonly property color parchment: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.foreground, root.theme.light ? 0.04 : 0.88) : "#efe6d2")
  readonly property color ink: root.hack ? root.hackText : (root.theme ? root.theme.mix(root.background, "#000000", root.theme.light ? 0 : 0.3) : "#1a1410")
  readonly property color text: root.foreground
  readonly property string serif: root.hack ? root.mono : "serif"

  property real burn: 0
  property real t: 0
  property var embers: []

  function roman(n) {
    if (n <= 0) return "0"
    var map = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]
    var out = ""
    for (var i = 0; i < map.length; i++) while (n >= map[i][0]) { out += map[i][1]; n -= map[i][0] }
    return out
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    burnAnim.restart()
    var cx = root.width / 2, cy = root.height * 0.42
    for (var i = 0; i < 46; i++) {
      root.embers.push({ x: cx + (Math.random() - 0.5) * root.cardW * 1.4, y: cy + (Math.random() - 0.5) * root.cardH * 1.4,
                         vx: (Math.random() - 0.5) * 1.6, vy: -1 - Math.random() * 2.6, t0: Date.now(), life: 500 + Math.random() * 600 })
    }
  }

  NumberAnimation { id: burnAnim; target: root; property: "burn"; from: 0; to: 1; duration: 540; easing.type: Easing.InQuad }
  onWoke: { root.burn = 0; root.embers = [] }

  Timer {
    interval: 40; repeat: true; running: root.live
    onTriggered: {
      root.t += 0.04
      // The candles are their own items now, so the effects layer only has
      // work while a burned card's sparks are flying (and one frame to
      // clear them).
      if (root.embers.length > 0 || fx.dirty) fx.requestPaint()
    }
  }

  // Cloth, with a pool of candlelight in the middle.
  Rectangle {
    anchors.fill: parent
    opacity: Math.min(0.97, root.backdrop)
    color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.cloth, "#000000", 0.45) : "#0b0710")
    Rectangle {
      visible: !root.hack
      anchors.centerIn: parent
      anchors.verticalCenterOffset: parent.height * 0.1
      width: parent.width * 1.1; height: parent.height * 1.3
      radius: width / 2
      opacity: 0.9
      gradient: Gradient {
        GradientStop { position: 0.0; color: Util.alpha(root.cloth, 0) }
        GradientStop { position: 0.5; color: root.cloth }
        GradientStop { position: 1.0; color: Util.alpha(root.cloth, 0) }
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

  // Candles. Glow and flame are painted once and flicker by scale and
  // opacity; only the thin wisp of smoke repaints, and only its own strip.
  // A full-screen Canvas redrawn 25 times a second cost more than every
  // other skin.
  Repeater {
    model: root.hack ? 0 : 2
    Item {
      id: candle
      required property int index
      readonly property real u: root.u
      readonly property color flameCol: root.theme ? root.theme.mix(root.theme.yellow, root.theme.orange, 0.4) : "#f6a04d"
      x: (index === 0 ? root.width * 0.12 : root.width * 0.88)
      y: root.height * 0.78
      z: 1

      Canvas {
        id: glowCanvas
        width: 560 * candle.u; height: width
        x: -width / 2; y: -70 * candle.u - height / 2
        property color c: candle.flameCol
        onCChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          var g = ctx.createRadialGradient(width / 2, height / 2, 0, width / 2, height / 2, width / 2)
          g.addColorStop(0, Qt.rgba(c.r, c.g, c.b, 0.22))
          g.addColorStop(1, Qt.rgba(c.r, c.g, c.b, 0))
          ctx.fillStyle = g
          ctx.fillRect(0, 0, width, height)
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.live
          NumberAnimation { to: 0.82; duration: 140 + candle.index * 60; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 210 + candle.index * 40; easing.type: Easing.InOutSine }
          NumberAnimation { to: 0.9; duration: 90; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.0; duration: 260; easing.type: Easing.InOutSine }
        }
      }
      // Wax and its shaded side.
      Rectangle { x: -16 * candle.u; y: -60 * candle.u; width: 32 * candle.u; height: 120 * candle.u; color: root.theme ? Util.alpha(root.theme.mix(root.parchment, root.theme.yellow, 0.1), 0.92) : "#eee" }
      Rectangle { x: 8 * candle.u; y: -60 * candle.u; width: 8 * candle.u; height: 120 * candle.u; color: Util.alpha(root.ink, 0.25) }
      Rectangle { x: -1; y: -70 * candle.u; width: 2; height: 10 * candle.u; color: Util.alpha(root.ink, 0.9) }
      Canvas {
        id: flame
        width: 30 * candle.u; height: 46 * candle.u
        x: -width / 2; y: -74 * candle.u - 36 * candle.u
        property color c: candle.flameCol
        onCChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          var cx = width / 2, base = 36 * candle.u
          var fg = ctx.createRadialGradient(cx, base - 6 * candle.u, 0, cx, base - 6 * candle.u, 22 * candle.u)
          fg.addColorStop(0, "rgba(255,255,240,0.95)")
          fg.addColorStop(0.35, Qt.rgba(c.r, c.g, c.b, 0.9))
          fg.addColorStop(1, Qt.rgba(c.r, c.g, c.b, 0))
          ctx.fillStyle = fg
          ctx.beginPath()
          ctx.moveTo(cx, base - 34 * candle.u)
          ctx.quadraticCurveTo(cx + 12 * candle.u, base - 6 * candle.u, cx, base + 6 * candle.u)
          ctx.quadraticCurveTo(cx - 12 * candle.u, base - 6 * candle.u, cx, base - 34 * candle.u)
          ctx.fill()
        }
        transform: Scale {
          id: flicker
          origin.x: flame.width / 2; origin.y: 36 * candle.u
          SequentialAnimation on yScale {
            loops: Animation.Infinite
            running: root.live
            NumberAnimation { to: 1.12; duration: 110 + candle.index * 30; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.94; duration: 160; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.05; duration: 90 + candle.index * 50; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 140; easing.type: Easing.InOutSine }
          }
        }
        SequentialAnimation on rotation {
          loops: Animation.Infinite
          running: root.live
          NumberAnimation { to: 3; duration: 420 + candle.index * 80; easing.type: Easing.InOutSine }
          NumberAnimation { to: -3; duration: 520; easing.type: Easing.InOutSine }
        }
      }
      // Smoke: a narrow strip, repainted at 12 fps.
      Canvas {
        id: smoke
        width: 80 * candle.u; height: 220 * candle.u
        x: -width / 2; y: -110 * candle.u - height + 16 * candle.u
        property real t: 0
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          if (!root.theme) return
          ctx.strokeStyle = root.theme.rgba(root.foreground, 0.05)
          ctx.lineWidth = 2
          ctx.beginPath()
          for (var s = 0; s < 12; s++) {
            var sy = height - s * 16 * candle.u
            var sx = width / 2 + Math.sin(t * 1.4 + s * 0.6 + candle.index) * (4 + s * 1.6) * candle.u
            if (s === 0) ctx.moveTo(sx, sy); else ctx.lineTo(sx, sy)
          }
          ctx.stroke()
        }
        Timer { interval: 83; repeat: true; running: root.live; onTriggered: { smoke.t += 0.083; smoke.requestPaint() } }
      }
    }
  }

  // Embers of a burned card.
  // deck.bin: a hexdump of the deck behind the cards. Painted once into a
  // texture a block taller than the screen, then only slid upwards and
  // wrapped — repainting ~120 lines of text every frame is what made it lag.
  Item {
    anchors.fill: parent
    visible: root.hack
    clip: true
    Canvas {
      id: dump
      readonly property real lineH: 18 * root.u
      readonly property int block: 32
      width: parent.width
      height: parent.height + lineH * block
      property var key: [root.gilt, root.hack, parent.width, parent.height]
      onKeyChanged: if (root.hack) requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var th = root.theme
        if (!th) return
        ctx.font = Math.round(12 * root.u) + "px monospace"
        ctx.fillStyle = th.rgba(root.gilt, 0.07)
        for (var ln = 0; ln * lineH < height; ln++) {
          // Rows repeat every `block` lines so the wrap is seamless.
          var addr = (ln % block) * 16
          var row = addr.toString(16).padStart(8, "0") + ":"
          for (var bb = 0; bb < 16; bb++) row += " " + root.fakeHex(addr + bb, 2)
          ctx.fillText(row, 40 * root.u, ln * lineH + lineH)
          ctx.fillText(row, width * 0.62, ln * lineH + lineH)
        }
      }
      NumberAnimation on y {
        from: 0; to: -dump.lineH * dump.block
        duration: 96000
        loops: Animation.Infinite
        running: root.live && root.hack
      }
    }
  }

  Canvas {
    id: fx
    anchors.fill: parent
    z: 1
    property bool dirty: false
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      dirty = root.embers.length > 0
      var th = root.theme
      if (!th) return
      var u = root.u
      var now = Date.now()
      for (var i = root.embers.length - 1; i >= 0; i--) {
        var e = root.embers[i]
        var age = now - e.t0
        if (age > e.life) { root.embers.splice(i, 1); continue }
        e.x += e.vx; e.y += e.vy; e.vy *= 0.985
        ctx.fillStyle = th.rgba(root.hack ? root.gilt : (i % 3 ? th.orange : th.yellow), 1 - age / e.life)
        ctx.fillRect(e.x, e.y, 2.5, 2.5)
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    y: 34 * u
    spacing: 6 * u
    z: 50
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.hack ? "$ xxd " + root.title.toLowerCase() + ".deck.bin" : "✦  " + root.title.toUpperCase().split("").join(" ") + "  ✦"
      color: root.gilt
      font.family: root.serif; font.pixelSize: 22 * u; font.weight: Font.Bold
    }
    QueryText {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 420 * u
      height: 20 * u
      alignment: Text.AlignHCenter
      query: root.query
      placeholder: root.hack ? "> grep -a …" : "ask the cards…"
      color: root.text
      placeholderColor: root.dim
      caretColor: root.gilt
      fontFamily: root.serif
      pixelSize: 14 * u
      live: root.live
    }
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
      required property string detail

      readonly property int k: card.index - root.selectedIndex
      readonly property bool inHand: Math.abs(card.k) <= root.fanReach
      readonly property bool chosen: card.k === 0 && root.cursorActive
      readonly property color hue: root.hues[card.index % root.hues.length] || root.accent
      readonly property real angleDeg: card.k * root.spread
      readonly property real a: card.angleDeg * Math.PI / 180
      // Face up only while chosen (always in deck.bin, dimmed when not
      // chosen); the flip runs through edge-on.
      readonly property bool faded: root.hack && !card.chosen
      property real flip: card.chosen || root.hack ? 0 : 180
      Behavior on flip { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
      property real lift: card.chosen ? 1 : 0
      Behavior on lift { NumberAnimation { duration: 360; easing.type: Easing.OutBack } }

      visible: card.inHand || Math.abs(card.k) === root.fanReach + 1
      width: root.cardW
      height: root.cardH
      x: card.lift > 0.001
        ? (root.pivotX + Math.sin(card.a) * root.fanR) * (1 - card.lift) + root.width / 2 * card.lift - width / 2
        : root.pivotX + Math.sin(card.a) * root.fanR - width / 2
      y: (root.pivotY - Math.cos(card.a) * root.fanR - height / 2) * (1 - card.lift) + (root.height * 0.42 - height / 2) * card.lift
      z: card.chosen ? 40 : 20 - Math.abs(card.k)
      Behavior on x { enabled: !card.chosen; NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      Behavior on y { enabled: !card.chosen; NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      rotation: card.angleDeg * (1 - card.lift)
      Behavior on rotation { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      scale: 1 + 0.5 * card.lift + (card.chosen && root.launching ? 0.08 : 0)
      opacity: (Math.abs(card.k) > root.fanReach ? 0 : 1) * (card.chosen ? 1 - root.burn : 1)
      Behavior on opacity { NumberAnimation { duration: 200 } }

      transform: Rotation {
        origin.x: card.width / 2; origin.y: card.height / 2
        axis { x: 0; y: 1; z: 0 }
        angle: card.flip
      }

      // Back.
      Rectangle {
        anchors.fill: parent
        visible: card.flip > 90
        radius: root.hack ? 0 : 10 * u
        color: root.hack ? root.hackBg : (root.theme ? root.theme.mix(card.hue, "#000000", 0.55) : "#301830")
        border.color: root.hack ? root.hackLine : root.gilt
        border.width: root.hack ? 1 : 2
        Rectangle {
          visible: !root.hack
          anchors.fill: parent; anchors.margins: 8 * u
          radius: 6 * u
          color: "transparent"
          border.color: Util.alpha(root.gilt, 0.6)
        }
        Repeater {
          model: root.hack ? 0 : 3
          Rectangle {
            required property int index
            anchors.centerIn: parent
            width: (70 - index * 18) * root.u; height: width
            rotation: 45
            color: "transparent"
            border.color: Util.alpha(index === 1 ? card.hue : root.gilt, 0.8)
            border.width: 1.5
          }
        }
        Text {
          visible: !root.hack
          anchors.centerIn: parent
          text: "✶"
          color: root.gilt
          font.pixelSize: 22 * u
        }
      }

      // Face.
      Rectangle {
        anchors.fill: parent
        visible: card.flip <= 90
        radius: root.hack ? 0 : 10 * u
        color: root.parchment
        border.color: card.faded ? root.hackLine : root.gilt
        border.width: root.hack ? 1 : 2

        Rectangle {
          visible: !root.hack
          anchors.fill: parent; anchors.margins: 7 * u
          radius: 6 * u
          color: "transparent"
          border.color: Util.alpha(card.hue, 0.7)
          border.width: 1.5
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          y: 14 * u
          text: root.hack ? "0x" + card.index.toString(16).padStart(2, "0") : root.roman(card.index + 1)
          color: card.faded ? root.dim : root.ink
          font.family: root.serif; font.pixelSize: 15 * u; font.weight: Font.Bold; font.letterSpacing: 2
        }
        Rectangle {
          anchors.centerIn: parent
          anchors.verticalCenterOffset: -8 * u
          width: 82 * u; height: 82 * u; radius: root.hack ? 0 : 41 * u
          color: root.hack ? "transparent" : Util.alpha(card.hue, 0.18)
          border.color: root.hack ? root.hackLine : Util.alpha(card.hue, 0.8)
          border.width: 1.5
          RowIcon {
            anchors.centerIn: parent
            size: (root.hack ? 40 : 50) * u
            opacity: card.faded ? 0.6 : root.hack ? 0.85 : 1
            kind: card.kind
            glyph: card.icon
            glyphFont: card.iconFont
            appIcon: card.appIcon
            resolver: root.iconResolver
            fontFamily: root.fontFamily
            load: card.inHand
            fallback: card.label.charAt(0).toUpperCase()
            color: root.theme ? root.theme.mix(card.hue, root.ink, 0.35) : card.hue
          }
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom; anchors.bottomMargin: 16 * u
          width: parent.width - 20 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.hack ? card.label.toLowerCase() : card.label.toUpperCase()
          color: card.faded ? root.dim : root.ink
          font.family: root.serif; font.pixelSize: 10 * u; font.weight: Font.Bold; font.letterSpacing: 1.5
        }
        // deck.bin: the card glitches away block by block instead of burning.
        Repeater {
          model: root.hack && card.chosen ? 24 : 0
          Rectangle {
            required property int index
            visible: root.burn * 24 > index
            x: (parseInt(root.fakeHex(index * 7 + 1, 2), 16) / 255) * (parent.width - width)
            y: (parseInt(root.fakeHex(index * 13 + 5, 2), 16) / 255) * (parent.height - height)
            width: parent.width * (0.25 + (index % 4) * 0.12)
            height: 10 * root.u + (index % 3) * 8 * root.u
            color: index % 5 === 0 ? root.hackInk : root.hackBg
          }
        }
        // Burning edge.
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          visible: !root.hack && card.chosen && root.burn > 0
          gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: Math.max(0.01, 1 - root.burn * 1.2); color: "transparent" }
            GradientStop { position: Math.min(0.99, 1.05 - root.burn); color: root.theme ? root.theme.orange : "#ff8a3d" }
            GradientStop { position: 1.0; color: root.ink }
          }
        }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          if (card.chosen) root.activated(card.index)
          else root.selectRequested(card.index)
        }
        onEntered: if (!card.chosen && Math.abs(card.k) <= 2) root.hoverSelect(card.index, mapToItem(root, mouseX, mouseY))
        onPositionChanged: if (!card.chosen && Math.abs(card.k) <= 2) root.hoverSelect(card.index, mapToItem(root, mouseX, mouseY))
      }
    }
  }

  // The reading: what the chosen card is.
  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height * 0.42 + root.cardH * 0.75 + 14 * u
    spacing: 6 * u
    z: 50
    width: 520 * u
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.hack ? "[0x" + root.selectedIndex.toString(16).padStart(2, "0") + "] " + root.current.label.toLowerCase() : root.roman(root.selectedIndex + 1) + "  ·  " + root.current.label) : root.emptyText()
      color: root.text
      font.family: root.serif; font.pixelSize: 22 * u; font.italic: !root.hack
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.current.detail || (root.isBranch(root.current.kind) ? "a door to another spread" : "")) : ""
      color: root.dim
      font.family: root.serif; font.pixelSize: 13 * u; font.italic: !root.hack
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 18 * u
    z: 50
    text: root.hack ? "[h/l] seek  [enter] exec  [bksp] cd ..  [esc] exit" : "← → / ^h ^l / wheel = draw  ·  ↵ = reveal  ·  ⌫ = back  ·  esc = close the reading"
    color: root.dim
    font.family: root.serif; font.pixelSize: 11 * u; font.italic: !root.hack; font.letterSpacing: 1
  }
}
