import QtQuick
import QtQuick.Shapes
import qs.Commons

// "Stargate" from bjarneo/omarchy-quickapps: a 39-segment stone ring with
// etched glyphs, nine chevron locks (the one facing the selection glows), an
// event horizon that ripples and kawhooshes on every change of destination.
// The stone is the theme background raised towards its brown, the chevrons
// burn in its orange, the horizon is its blue and cyan.
SkinBase {
  id: root

  launchDelay: 420

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))
  readonly property int slotSel: Math.max(0, root.selectedIndex - root.pageStart)

  readonly property color stoneDark: root.theme ? root.theme.mix(root.background, root.theme.brown, 0.18) : "#1d1812"
  readonly property color stoneMid: root.theme ? root.theme.mix(root.background, root.theme.mix(root.theme.brown, root.foreground, 0.3), 0.38) : "#3a3128"
  readonly property color stoneLight: root.theme ? root.theme.mix(root.stoneMid, root.foreground, 0.35) : "#6f5f48"
  readonly property color glyphInk: root.theme ? root.theme.mix(root.background, "#000000", 0.4) : "#1a1410"
  readonly property color chevronOff: root.theme ? root.theme.mix(root.stoneDark, root.theme.orange, 0.25) : "#5a3a2a"
  readonly property color chevronOn: root.theme ? root.theme.orange : "#ff5a2a"
  readonly property color horizon: root.theme ? root.theme.mix(root.theme.cyan, "#ffffff", 0.3) : "#9bcdff"
  readonly property color horizonMid: root.theme ? root.theme.blue : "#3a7fc9"
  readonly property color horizonDeep: root.theme ? root.theme.mix(root.theme.blue, "#000000", 0.75) : "#0b2447"
  readonly property string serif: "serif"

  readonly property var glyphs: ["✦", "☉", "☿", "♀", "♁", "♂", "♃", "♄", "♅", "♆", "⚳", "☄", "✶", "✷", "✸", "✹", "✺", "❂", "❄", "❉", "❋", "✱", "✲", "✳", "✴", "✵", "✿", "❀", "❁", "✤", "✥", "✪", "☼", "☽", "☾", "✦", "✧", "✩", "✫"]

  property real splashPhase: 0
  onSelectedIndexChanged: splashAnim.restart()
  NumberAnimation { id: splashAnim; target: root; property: "splashPhase"; from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    splashAnim.restart()
  }

  Rectangle { anchors.fill: parent; color: root.theme ? root.theme.mix(root.background, "#000000", 0.6) : "#070a0e"; opacity: Math.min(0.97, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Seven-chevron lock status.
  Row {
    anchors.top: parent.top; anchors.topMargin: 40 * u
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 16 * u
    Repeater {
      model: 7
      delegate: Item {
        id: lock
        required property int index
        width: 28 * u; height: 18 * u
        readonly property bool lit: index <= ((root.selectedIndex + 1) % 7)
        Shape {
          anchors.fill: parent
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            strokeColor: lock.lit ? root.chevronOn : root.chevronOff
            strokeWidth: 1.5
            fillColor: lock.lit ? Util.alpha(root.chevronOn, 0.5) : Util.alpha(root.chevronOff, 0.3)
            startX: 0; startY: 0
            PathLine { x: 28 * root.u; y: 0 }
            PathLine { x: 14 * root.u; y: 18 * root.u }
            PathLine { x: 0; y: 0 }
          }
        }
      }
    }
  }
  Text {
    anchors.top: parent.top; anchors.topMargin: 66 * u
    anchors.horizontalCenter: parent.horizontalCenter
    textFormat: Text.PlainText
    text: (root.query.length > 0 ? "ADDRESS  “" + root.query.toUpperCase() + "”  ·  " : "CHEVRONS LOCKED  ·  ")
      + (root.count ? String(root.selectedIndex + 1).padStart(2, "0") : "--") + " / " + (root.count ? String(root.count).padStart(2, "0") : "--")
    color: root.stoneLight
    font.family: root.serif; font.pixelSize: 10 * u; font.letterSpacing: 5; font.weight: Font.Bold
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 820 * u; height: 820 * u

    readonly property real outerR: 380 * root.u
    readonly property real innerR: 300 * root.u
    readonly property real glyphR: 340 * root.u
    readonly property real chevronR: 388 * root.u

    Rectangle {
      anchors.centerIn: parent
      width: stage.outerR * 2 + 6; height: width; radius: width / 2
      color: root.glyphInk
    }

    Canvas {
      anchors.fill: parent
      property var key: [root.stoneMid, root.stoneLight]
      onKeyChanged: requestPaint()
      onWidthChanged: requestPaint()
      function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var th = root.theme
        if (!th) return
        ctx.translate(width / 2, height / 2)
        ctx.beginPath()
        ctx.arc(0, 0, stage.outerR, 0, Math.PI * 2)
        ctx.arc(0, 0, stage.innerR, 0, Math.PI * 2, true)
        ctx.fillStyle = th.rgba(root.stoneMid, 1)
        ctx.fill()
        var N = 39
        ctx.strokeStyle = th.rgba(root.glyphInk, 0.85)
        ctx.lineWidth = 1.4
        for (var i = 0; i < N; ++i) {
          var a = (i / N) * Math.PI * 2 - Math.PI / 2
          ctx.beginPath()
          ctx.moveTo(Math.cos(a) * stage.innerR, Math.sin(a) * stage.innerR)
          ctx.lineTo(Math.cos(a) * stage.outerR, Math.sin(a) * stage.outerR)
          ctx.stroke()
        }
        ctx.strokeStyle = th.rgba(root.stoneLight, 1)
        ctx.lineWidth = 1.2
        ctx.beginPath(); ctx.arc(0, 0, stage.innerR + 1, 0, Math.PI * 2); ctx.stroke()
        ctx.beginPath(); ctx.arc(0, 0, stage.outerR - 1, 0, Math.PI * 2); ctx.stroke()
        for (var s = 0; s < 800; ++s) {
          var sa = rnd(s * 3) * Math.PI * 2
          var r = stage.innerR + rnd(s * 3 + 1) * (stage.outerR - stage.innerR)
          ctx.fillStyle = th.rgba(root.glyphInk, rnd(s * 3 + 2) * 0.25)
          ctx.fillRect(Math.cos(sa) * r, Math.sin(sa) * r, 1.6, 1.6)
        }
      }
    }

    Repeater {
      model: 39
      delegate: Text {
        required property int index
        readonly property real a: (index / 39) * Math.PI * 2 - Math.PI / 2
        text: root.glyphs[index % root.glyphs.length]
        color: root.glyphInk
        font.family: root.serif; font.pixelSize: 18 * root.u; font.weight: Font.Bold
        x: stage.width / 2 - width / 2 + Math.cos(a) * stage.glyphR
        y: stage.height / 2 - height / 2 + Math.sin(a) * stage.glyphR
        rotation: index / 39 * 360
      }
    }

    // Nine chevron locks; the one facing the selection glows.
    Repeater {
      model: 9
      delegate: Item {
        id: chev
        required property int index
        readonly property real a: ((index / 9) * 360 - 90) * Math.PI / 180
        readonly property bool selected: {
          if (!root.pageCount || !root.cursorActive) return false
          var chevAng = (index / 9) * 360
          var sel = ((root.slotSel / root.pageCount) * 360 + 360) % 360
          var diff = Math.min(Math.abs(chevAng - sel), 360 - Math.abs(chevAng - sel))
          return diff < (180 / 9)
        }
        width: 36 * root.u; height: 26 * root.u
        x: stage.width / 2 - width / 2 + Math.cos(a) * stage.chevronR
        y: stage.height / 2 - height / 2 + Math.sin(a) * stage.chevronR
        rotation: (index / 9) * 360
        Shape {
          anchors.fill: parent
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            strokeColor: chev.selected ? root.theme ? root.theme.mix(root.chevronOn, "#ffffff", 0.45) : "#ffb088" : root.glyphInk
            strokeWidth: 1.8
            fillColor: chev.selected ? root.chevronOn : root.theme ? root.theme.mix(root.glyphInk, root.chevronOff, 0.4) : "#1f120a"
            startX: 0; startY: 0
            PathLine { x: 36 * root.u; y: 0 }
            PathLine { x: 30 * root.u; y: 18 * root.u }
            PathLine { x: 18 * root.u; y: 26 * root.u }
            PathLine { x: 6 * root.u; y: 18 * root.u }
            PathLine { x: 0; y: 0 }
          }
        }
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top; anchors.topMargin: 6 * root.u
          width: 16 * root.u; height: 6 * root.u; radius: 3 * root.u
          color: chev.selected ? (root.theme ? root.theme.mix(root.theme.yellow, "#ffffff", 0.6) : "#fff1c0") : root.chevronOff
        }
      }
    }

    // Event horizon.
    Rectangle {
      id: pool
      anchors.centerIn: parent
      width: stage.innerR * 2 - 8; height: width
      radius: width / 2
      color: root.horizonDeep
      clip: true

      Canvas {
        anchors.fill: parent
        property var key: [root.horizon, root.horizonMid, root.horizonDeep]
        onKeyChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          var th = root.theme
          if (!th) return
          var g = ctx.createRadialGradient(width / 2, height / 2, 30, width / 2, height / 2, width / 2)
          g.addColorStop(0, th.rgba(th.mix(root.horizon, "#ffffff", 0.4), 1))
          g.addColorStop(0.4, th.rgba(root.horizonMid, 1))
          g.addColorStop(1, th.rgba(root.horizonDeep, 1))
          ctx.fillStyle = g
          ctx.beginPath(); ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2); ctx.fill()
        }
      }
      Canvas {
        anchors.fill: parent
        property real phase: 0
        NumberAnimation on phase { from: 0; to: Math.PI * 2; duration: 6000; loops: Animation.Infinite; running: root.live }
        onPhaseChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.translate(width / 2, height / 2)
          for (var i = 0; i < 6; ++i) {
            ctx.strokeStyle = "rgba(255,255,255," + (0.22 - i * 0.03) + ")"
            ctx.lineWidth = 1.2
            ctx.beginPath()
            ctx.arc(0, 0, (40 + i * 36) * root.u + Math.sin(phase + i * 0.8) * 10, 0, Math.PI * 2)
            ctx.stroke()
          }
        }
      }
      Rectangle {
        anchors.centerIn: parent
        readonly property real maxR: pool.width * 0.55
        width: 60 + root.splashPhase * (maxR * 2 - 60)
        height: width
        radius: width / 2
        color: root.theme ? root.theme.mix(root.horizon, "#ffffff", 0.5) : Qt.rgba(0.85, 0.95, 1, 1)
        opacity: (1 - root.splashPhase) * (root.launching ? 0.95 : 0.6)
      }
    }

    Column {
      anchors.centerIn: parent
      spacing: 6 * u
      width: 360 * u
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "DESTINATION"
        color: Util.alpha(root.horizon, 0.7)
        font.family: root.serif; font.pixelSize: 10 * u; font.letterSpacing: 6; font.weight: Font.Bold
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label : "—"
        color: "#ffffff"
        style: Text.Raised; styleColor: root.horizonDeep
        font.family: root.serif; font.pixelSize: 32 * u; font.letterSpacing: 8; font.weight: Font.Bold
      }
      Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 120 * u; height: 1; color: root.horizon }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.detail : root.emptyText()
        color: Util.alpha(root.horizon, 0.85)
        font.family: root.mono; font.pixelSize: 11 * u; font.letterSpacing: 2
      }
      Item { width: 1; height: 4 * u }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.pages > 1 ? "address book " + (root.page + 1) + " of " + root.pages + " · enter to engage" : "press enter to engage"
        color: Util.alpha(root.horizon, 0.55)
        font.family: root.serif; font.pixelSize: 10 * u; font.letterSpacing: 4; font.italic: true
      }
    }

    Repeater {
      model: root.rowModel

      delegate: Item {
        id: tile

        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label

        readonly property int slot: tile.index - root.pageStart
        readonly property bool onPage: slot >= 0 && slot < root.pageCount
        readonly property bool focusedTile: root.cursorActive && tile.index === root.selectedIndex
        readonly property real angle: root.angleFor(Math.max(0, tile.slot))

        visible: tile.onPage
        width: 76 * u; height: 76 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * (stage.innerR - 50 * u)
        y: stage.height / 2 - height / 2 + Math.sin(angle) * (stage.innerR - 50 * u)
        Behavior on x { NumberAnimation { duration: 360; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 360; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.2 : 1.0
        Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }

        Rectangle {
          anchors.centerIn: parent
          width: 60 * u; height: 60 * u; radius: 30 * u
          color: tile.focusedTile ? (root.theme ? Util.alpha(root.theme.mix(root.theme.yellow, "#ffffff", 0.7), 0.95) : Qt.rgba(1, 0.95, 0.8, 0.95)) : Qt.rgba(0, 0, 0, 0.55)
          border.color: tile.focusedTile ? (root.theme ? root.theme.mix(root.theme.yellow, "#ffffff", 0.6) : "#fff1c0") : Util.alpha(root.horizon, 0.45)
          border.width: tile.focusedTile ? 2 : 1
          Behavior on color { ColorAnimation { duration: 260 } }
        }
        RowIcon {
          anchors.centerIn: parent
          size: 38 * u
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: root.glyphs[tile.index % root.glyphs.length] || "✦"
          color: tile.focusedTile ? root.horizonDeep : Util.alpha(root.horizon, 0.85)
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.bottom; anchors.topMargin: -6 * u
          width: 110 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label
          color: tile.focusedTile ? "#ffffff" : Util.alpha(root.horizon, 0.6)
          font.family: root.serif; font.pixelSize: 9 * u; font.letterSpacing: 2; font.weight: Font.Bold
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(tile.index)
          onClicked: root.activated(tile.index)
        }
      }
    }
  }
}
