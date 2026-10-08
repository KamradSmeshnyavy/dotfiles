import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell.Io
import qs.Commons

// "Ironman" from bjarneo/omarchy-quickapps: hex cogs orbiting a FUI target
// readout, concentric HUD rings with a rotating tick band, a bracket that
// swings to the selected cog, live CPU/MEM telemetry and a clock. Each cog's
// accent cycles through the theme's hues; the HUD lines are the theme
// foreground tinted towards its blue.
SkinBase {
  id: root

  launchDelay: 0

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  readonly property color glow: root.current ? (root.hues[root.selectedIndex % root.hues.length] || root.accent) : root.accent
  readonly property color hud: root.theme ? root.theme.mix(root.foreground, root.theme.blue, 0.35) : Qt.rgba(0.6, 0.72, 0.83, 1)
  readonly property color dim: root.theme ? root.theme.muted : "#4a5560"
  readonly property color pale: root.theme ? root.theme.mix(root.foreground, root.background, 0.15) : "#cfd8dc"
  readonly property color white: root.theme ? root.theme.bright : "#ffffff"
  readonly property color deep: root.theme ? root.theme.mix(root.background, "#000000", 0.55) : "#05080e"
  readonly property real cogRadius: 240 * u
  readonly property real hexSize: 108 * u

  property int cpuVal: -1
  property int memVal: -1
  property string clock: ""
  property string dateStr: ""

  function angleDegFor(slot) {
    return root.pageCount ? (360 * slot) / root.pageCount - 90 : -90
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Process {
    id: telProc
    command: ["bash", "-c",
      "read _ a b c d _ < <(grep '^cpu ' /proc/stat); sleep 0.2; read _ e f g h _ < <(grep '^cpu ' /proc/stat); "
      + "du=$(( (e+f+g) - (a+b+c) )); dt=$(( (e+f+g+h) - (a+b+c+d) )); cpu=$(( dt>0 ? du*100/dt : 0 )); "
      + "mem=$(awk '/MemTotal/{t=$2}/MemAvailable/{m=$2}END{printf \"%d\",(t-m)*100/t}' /proc/meminfo); "
      + "printf '%d|%d|%s|%s' \"$cpu\" \"$mem\" \"$(date +%H:%M:%S)\" \"$(date +%Y-%m-%d)\""]
    stdout: StdioCollector {
      onStreamFinished: {
        var p = this.text.split("|")
        if (p.length === 4) {
          root.cpuVal = parseInt(p[0]) || 0
          root.memVal = parseInt(p[1]) || 0
          root.clock = p[2]
          root.dateStr = p[3]
        }
      }
    }
  }
  Timer {
    interval: 1000; running: root.live; repeat: true; triggeredOnStart: true
    onTriggered: { telProc.running = false; telProc.running = true }
  }

  Rectangle { anchors.fill: parent; color: root.deep; opacity: Math.min(0.95, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Corner brackets.
  Repeater {
    model: 4
    delegate: Item {
      required property int index
      readonly property bool pinTop: index < 2
      readonly property bool pinLeft: index % 2 === 0
      width: 24 * u; height: 24 * u
      x: pinLeft ? 22 * u : root.width - width - 22 * u
      y: pinTop ? 22 * u : root.height - height - 22 * u
      Rectangle { width: parent.width; height: 1.5; y: parent.pinTop ? 0 : parent.height - 1.5; color: Util.alpha(root.hud, 0.55) }
      Rectangle { width: 1.5; height: parent.height; x: parent.pinLeft ? 0 : parent.width - 1.5; color: Util.alpha(root.hud, 0.55) }
    }
  }

  // Top HUD bar.
  Item {
    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
    anchors.topMargin: 28 * u; anchors.leftMargin: 60 * u; anchors.rightMargin: 60 * u
    height: 28 * u

    Row {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 14 * u
      Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 8 * u; height: 8 * u; color: root.glow; Behavior on color { ColorAnimation { duration: 220 } } }
      Text { anchors.verticalCenter: parent.verticalCenter; text: "OMARCHY"; color: root.white; font.family: root.mono; font.pixelSize: 12 * u; font.letterSpacing: 4; font.weight: Font.Bold }
      Text { anchors.verticalCenter: parent.verticalCenter; text: "//"; color: root.dim; font.family: root.mono; font.pixelSize: 12 * u }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: root.title === "Omarchy" ? "QUICK APPS" : root.title.toUpperCase()
        color: root.pale
        font.family: root.mono; font.pixelSize: 12 * u; font.letterSpacing: 4; font.weight: Font.Bold
      }
      Text {
        visible: root.query.length > 0
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: "// FILTER “" + root.query.toUpperCase() + "”"
        color: root.glow
        font.family: root.mono; font.pixelSize: 12 * u; font.letterSpacing: 2; font.weight: Font.Bold
      }
    }
    Row {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8 * u
      Text { anchors.verticalCenter: parent.verticalCenter; text: root.pages > 1 ? "BANK " + (root.page + 1) + "/" + root.pages + "  SLOT" : "SLOT"; color: root.dim; font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 2.5 }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.count ? String(root.selectedIndex + 1).padStart(2, "0") : "--"
        color: root.glow
        Behavior on color { ColorAnimation { duration: 220 } }
        font.family: root.mono; font.pixelSize: 14 * u; font.letterSpacing: 2; font.weight: Font.Bold
      }
      Text { anchors.verticalCenter: parent.verticalCenter; text: "//"; color: root.dim; font.family: root.mono; font.pixelSize: 12 * u }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.count ? String(root.count).padStart(2, "0") : "--"
        color: root.pale
        font.family: root.mono; font.pixelSize: 14 * u; font.letterSpacing: 2; font.weight: Font.Bold
      }
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 820 * u; height: 820 * u

    // HUD rings: inner hairline, dashed ring hugging the cogs, faint outer.
    Canvas {
      anchors.fill: parent
      property color line: root.hud
      onLineChanged: requestPaint()
      onWidthChanged: requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        if (!root.theme) return
        ctx.translate(width / 2, height / 2)
        var u = root.u
        ctx.lineWidth = 1
        ctx.strokeStyle = root.theme.rgba(root.hud, 0.28)
        ctx.setLineDash([])
        ctx.beginPath(); ctx.arc(0, 0, root.cogRadius - 110 * u, 0, Math.PI * 2); ctx.stroke()
        ctx.strokeStyle = root.theme.rgba(root.hud, 0.4)
        ctx.setLineDash([3, 7])
        ctx.beginPath(); ctx.arc(0, 0, root.cogRadius + 78 * u, 0, Math.PI * 2); ctx.stroke()
        ctx.strokeStyle = root.theme.rgba(root.hud, 0.16)
        ctx.setLineDash([10, 10])
        ctx.beginPath(); ctx.arc(0, 0, root.cogRadius + 148 * u, 0, Math.PI * 2); ctx.stroke()
      }
    }

    // Rotating tick band.
    Item {
      anchors.fill: parent
      RotationAnimator on rotation { from: 0; to: 360; duration: 90000; loops: Animation.Infinite; running: root.live }
      Canvas {
        anchors.fill: parent
        property color line: root.hud
        onLineChanged: requestPaint()
        onWidthChanged: requestPaint()
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          if (!root.theme) return
          ctx.translate(width / 2, height / 2)
          ctx.strokeStyle = root.theme.rgba(root.hud, 0.5)
          ctx.lineWidth = 1
          var r = root.cogRadius + 112 * root.u
          for (var i = 0; i < 72; ++i) {
            var a = (i / 72) * Math.PI * 2
            var inner = (i % 6 === 0) ? r - 9 : r - 3
            ctx.beginPath()
            ctx.moveTo(Math.cos(a) * inner, Math.sin(a) * inner)
            ctx.lineTo(Math.cos(a) * r, Math.sin(a) * r)
            ctx.stroke()
          }
        }
      }
    }

    // Bracket that swings to the selected cog.
    Canvas {
      id: scan
      anchors.fill: parent
      visible: root.count > 0 && root.cursorActive
      rotation: root.angleDegFor(Math.max(0, root.selectedIndex - root.pageStart)) + 90
      Behavior on rotation { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
      property color line: root.glow
      onLineChanged: requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        if (!root.theme) return
        ctx.translate(width / 2, height / 2)
        ctx.strokeStyle = root.theme.rgba(root.glow, 1)
        ctx.lineWidth = 2
        ctx.lineCap = "square"
        var rOuter = root.cogRadius + 100 * root.u
        ctx.beginPath(); ctx.arc(0, 0, rOuter, -Math.PI / 2 - 0.20, -Math.PI / 2 + 0.20); ctx.stroke()
        var rInner = root.cogRadius - 92 * root.u
        ctx.beginPath(); ctx.arc(0, 0, rInner, -Math.PI / 2 - 0.12, -Math.PI / 2 + 0.12); ctx.stroke()
        ctx.beginPath(); ctx.moveTo(0, -rOuter); ctx.lineTo(0, -(rOuter + 12)); ctx.stroke()
      }
    }

    // Centre cluster.
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -56 * u
      text: root.current ? "// TARGET ACQUIRED" : (root.query.length > 0 ? "// NO MATCH" : "// NO APPS LOADED")
      color: root.dim
      font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 3.5; font.weight: Font.Bold
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -24 * u
      width: 300 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.label.toUpperCase() : "STANDBY"
      color: root.glow
      Behavior on color { ColorAnimation { duration: 220 } }
      font.family: root.mono; font.pixelSize: 24 * u; font.letterSpacing: 7; font.weight: Font.Bold
    }
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 4 * u
      width: 80 * u; height: 1
      color: root.glow
      opacity: 0.7
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 24 * u
      width: 300 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current && root.current.detail ? "$ " + root.current.detail : ""
      color: root.theme ? root.theme.mix(root.pale, root.background, 0.3) : "#8a99a4"
      font.family: root.mono; font.pixelSize: 11 * u; font.letterSpacing: 1.8
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 54 * u
      text: root.current ? (root.isBranch(root.current.kind) ? "SUBSYSTEM // PRESS ENTER" : "READY // PRESS ENTER") : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 3; font.weight: Font.Bold
    }

    // Cogs.
    Repeater {
      model: root.rowModel

      delegate: Item {
        id: cog

        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label

        readonly property int slot: cog.index - root.pageStart
        readonly property bool onPage: slot >= 0 && slot < root.pageCount
        readonly property bool focusedCog: root.cursorActive && cog.index === root.selectedIndex
        readonly property color cogAccent: root.hues[cog.index % root.hues.length] || root.accent
        readonly property real angleRad: root.angleDegFor(Math.max(0, cog.slot)) * Math.PI / 180
        readonly property real hs: root.hexSize

        visible: cog.onPage
        width: hs; height: hs + 26 * u
        x: stage.width / 2 - width / 2 + Math.cos(angleRad) * root.cogRadius
        y: stage.height / 2 - hs / 2 + Math.sin(angleRad) * root.cogRadius
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        scale: cog.focusedCog ? 1.14 : 1.0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        opacity: 0
        NumberAnimation { id: entrance; target: cog; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.OutCubic }
        Timer { id: entranceTimer; interval: Math.max(0, cog.slot) * 45; running: true; onTriggered: entrance.start() }
        Connections {
          target: root
          function onWoke() { cog.opacity = 0; entranceTimer.restart() }
          function onPageChanged() { if (cog.onPage) { cog.opacity = 0; entranceTimer.restart() } }
        }

        // Halo, only on focus.
        Shape {
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          width: cog.hs; height: cog.hs
          opacity: cog.focusedCog ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 220 } }
          layer.enabled: cog.focusedCog
          layer.effect: MultiEffect { blurEnabled: true; blurMax: 48; blur: 1.0; brightness: 0.15 }
          ShapePath {
            strokeColor: cog.cogAccent; strokeWidth: 4; fillColor: "transparent"; joinStyle: ShapePath.MiterJoin
            startX: cog.hs * 0.25; startY: 0
            PathLine { x: cog.hs * 0.75; y: 0 }
            PathLine { x: cog.hs; y: cog.hs * 0.5 }
            PathLine { x: cog.hs * 0.75; y: cog.hs }
            PathLine { x: cog.hs * 0.25; y: cog.hs }
            PathLine { x: 0; y: cog.hs * 0.5 }
            PathLine { x: cog.hs * 0.25; y: 0 }
          }
        }
        Shape {
          id: frame
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          width: cog.hs; height: cog.hs
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            strokeColor: cog.focusedCog ? cog.cogAccent : Util.alpha(root.hud, 0.45)
            strokeWidth: cog.focusedCog ? 1.8 : 1.0
            fillColor: cog.focusedCog ? Util.alpha(root.white, 0.04) : Util.alpha(root.deep, 0.5)
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap
            startX: cog.hs * 0.25; startY: 0
            PathLine { x: cog.hs * 0.75; y: 0 }
            PathLine { x: cog.hs; y: cog.hs * 0.5 }
            PathLine { x: cog.hs * 0.75; y: cog.hs }
            PathLine { x: cog.hs * 0.25; y: cog.hs }
            PathLine { x: 0; y: cog.hs * 0.5 }
            PathLine { x: cog.hs * 0.25; y: 0 }
          }
        }
        RowIcon {
          anchors.centerIn: frame
          size: cog.hs * 0.46
          kind: cog.kind
          glyph: cog.icon
          glyphFont: cog.iconFont
          appIcon: cog.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: cog.onPage
          fallback: cog.label.charAt(0).toUpperCase()
          color: cog.focusedCog ? cog.cogAccent : root.pale
        }
        Repeater {
          model: cog.focusedCog ? 4 : 0
          delegate: Rectangle {
            required property int index
            width: index < 2 ? 8 * root.u : 1.5
            height: index < 2 ? 1.5 : 8 * root.u
            color: cog.cogAccent
            x: frame.x + (index === 0 ? -10 * root.u : index === 1 ? cog.hs + 2 : cog.hs * 0.5 - width / 2)
            y: frame.y + (index === 0 || index === 1 ? cog.hs * 0.5 - height / 2 : index === 2 ? -10 * root.u : cog.hs + 2)
          }
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: frame.bottom; anchors.topMargin: 8 * u
          width: 140 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: cog.label.toUpperCase()
          color: cog.focusedCog ? root.white : root.theme ? root.theme.mix(root.pale, root.background, 0.4) : "#7a8a96"
          font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 2.6; font.weight: Font.Bold
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(cog.index)
          onClicked: root.activated(cog.index)
        }
      }
    }
  }

  // Bottom HUD: telemetry, key hints, clock.
  Item {
    anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
    anchors.bottomMargin: 28 * u; anchors.leftMargin: 60 * u; anchors.rightMargin: 60 * u
    height: 56 * u

    Column {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      spacing: 8 * u
      Repeater {
        model: [["CPU", root.cpuVal, root.theme ? root.theme.green : "#06ffa5"], ["MEM", root.memVal, root.theme ? root.theme.cyan : "#8be9fd"]]
        Row {
          required property var modelData
          spacing: 10 * u
          Text { anchors.verticalCenter: parent.verticalCenter; text: modelData[0]; color: root.dim; font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 2.5; font.weight: Font.Bold }
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 100 * u; height: 3
            color: Util.alpha(root.hud, 0.15)
            Rectangle {
              width: parent.width * (Math.max(0, Math.min(modelData[1], 100)) / 100)
              height: parent.height
              color: modelData[1] > 80 ? (root.theme ? root.theme.red : "#fb7185") : modelData[2]
              Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
          }
          Text { anchors.verticalCenter: parent.verticalCenter; text: (modelData[1] < 0 ? "--" : String(modelData[1]).padStart(2, "0")) + "%"; color: root.pale; font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 1 }
        }
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: 18 * u
      Repeater {
        model: [["← →", "CYCLE"], ["↵", "LAUNCH"], ["ALT 1-9", "JUMP"], ["⌫", "BACK"], ["ESC", "EXIT"]]
        Row {
          required property var modelData
          spacing: 8 * u
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: keyGlyph.implicitWidth + 14 * u
            implicitHeight: 20 * u
            color: Util.alpha(root.deep, 0.6)
            border.color: Util.alpha(root.hud, 0.35)
            border.width: 1
            radius: 2
            Text { id: keyGlyph; anchors.centerIn: parent; text: modelData[0]; color: root.pale; font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 1; font.weight: Font.Bold }
          }
          Text { anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; color: root.dim; font.family: root.mono; font.pixelSize: 9 * u; font.letterSpacing: 2.5; font.weight: Font.Bold }
        }
      }
    }

    Column {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4 * u
      Text { anchors.right: parent.right; text: root.clock; color: root.white; font.family: root.mono; font.pixelSize: 16 * u; font.letterSpacing: 3; font.weight: Font.Bold }
      Text { anchors.right: parent.right; text: root.dateStr; color: root.dim; font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 2 }
    }
  }
}
