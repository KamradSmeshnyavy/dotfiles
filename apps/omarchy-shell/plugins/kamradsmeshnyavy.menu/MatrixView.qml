import QtQuick
import Quickshell
import qs.Commons

// Matrix: digital rain in the theme's green, and the menu decoding itself
// out of it. Each row's name arrives as noise and resolves letter by letter,
// and does it again when the cursor lands on it. Launching floods the rain.
SkinBase {
  id: root

  launchDelay: 480

  // matrix-hack and matrix-term take the Terminal palette instead of the
  // green rain; matrix-term keeps everything else as designed.
  readonly property bool termPalette: root.hack || root.variant === "term"
  readonly property color rain: root.termPalette ? root.hackInk : (root.theme ? root.theme.green : "#41f38c")
  readonly property color glow: root.termPalette ? root.hackText : (root.theme ? root.theme.mix(root.rain, "#ffffff", 0.55) : "#c8ffd8")
  readonly property color dark: root.termPalette ? root.hackBg : (root.theme ? root.theme.mix(root.background, "#000000", 0.72) : "#010603")
  readonly property color dim: root.termPalette ? root.hackDim : (root.theme ? root.theme.mix(root.rain, root.dark, 0.55) : "#1c6b3a")
  // matrix-hack (shell): a plain prompt, sparse binary columns instead of
  // the rain, inverted selection.
  readonly property string glyphs: root.hack ? "01" : "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789:=*+-<>¦|"
  readonly property string host: (Quickshell.env("USER") || "user") + "@omarchy"
  readonly property real cell: 20 * u
  readonly property real rowH: 46 * u

  property var drops: []
  property real flood: 0

  function noise(n) {
    var out = ""
    for (var i = 0; i < n; i++) out += root.glyphs.charAt(Math.floor(Math.random() * root.glyphs.length))
    return out
  }

  function seed() {
    var cols = Math.ceil(root.width / root.cell)
    var d = []
    for (var i = 0; i < cols; i++) d.push({ y: Math.random() * root.height / root.cell - 6, v: 0.3 + Math.random() * 0.7 })
    root.drops = d
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    floodAnim.restart()
  }
  NumberAnimation { id: floodAnim; target: root; property: "flood"; from: 0; to: 1; duration: 480; easing.type: Easing.InQuad }
  onWoke: { root.flood = 0; rainCanvas.wipe = true }
  onWidthChanged: seed()
  Component.onCompleted: seed()

  Rectangle { anchors.fill: parent; color: root.dark; opacity: Math.min(0.97, root.backdrop) }

  // The rain keeps its own trails: each frame veils the last one a little
  // instead of clearing it.
  Canvas {
    id: rainCanvas
    anchors.fill: parent
    property bool wipe: true
    onPaint: {
      var ctx = getContext("2d")
      var th = root.theme
      if (!th) return
      if (wipe) { ctx.reset(); wipe = false }
      if (root.drops.length < Math.ceil(width / root.cell)) root.seed()
      ctx.fillStyle = th.rgba(root.dark, 0.16 + 0.1 * (1 - root.flood))
      ctx.globalCompositeOperation = "source-over"
      ctx.fillRect(0, 0, width, height)
      ctx.font = Math.round(root.cell * 0.9) + "px monospace"
      ctx.textAlign = "center"
      var speed = 1 + root.flood * 4
      for (var i = 0; i < root.drops.length; i++) {
        if (root.hack && i % 7 !== 0) continue
        var d = root.drops[i]
        var x = i * root.cell + root.cell / 2
        var y = d.y * root.cell
        ctx.fillStyle = th.rgba(root.glow, root.hack ? 0.35 : 0.95)
        ctx.fillText(root.glyphs.charAt(Math.floor(Math.random() * root.glyphs.length)), x, y)
        ctx.fillStyle = th.rgba(root.rain, root.hack ? 0.18 : 0.75)
        ctx.fillText(root.glyphs.charAt(Math.floor(Math.random() * root.glyphs.length)), x, y - root.cell)
        d.y += d.v * speed
        if (y > height + root.cell * 4 && Math.random() > 0.96 - root.flood) { d.y = Math.random() * -8; d.v = 0.3 + Math.random() * 0.7 }
      }
      if (root.flood > 0) {
        ctx.fillStyle = th.rgba(root.rain, 0.25 * root.flood)
        ctx.fillRect(0, 0, width, height)
      }
    }
  }
  Timer { interval: 50; repeat: true; running: root.live; onTriggered: rainCanvas.requestPaint() }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // The terminal pane the names decode into.
  Rectangle {
    id: pane
    anchors.centerIn: parent
    width: Math.min(760 * u, root.width * 0.62)
    height: Math.min(root.height * 0.78, 740 * u)
    color: root.hack ? "transparent" : Util.alpha(root.dark, 0.82)
    border.color: Util.alpha(root.rain, 0.35)
    border.width: root.hack ? 0 : 1

    Column {
      x: 28 * u; y: 22 * u
      width: parent.width - 56 * u
      spacing: 6 * u
      Text {
        textFormat: Text.PlainText
        text: root.hack ? "last login: " + Qt.formatDateTime(new Date(), "ddd MMM d hh:mm") + " on tty1" : "wake up, " + (Quickshell.env("USER") || "neo") + "…"
        color: root.rain
        font.family: root.mono; font.pixelSize: 13 * u
      }
      Row {
        spacing: 0
        Text { text: (root.hack ? root.host + ":~/" : "> ") + (root.subtitle.length > 0 ? root.subtitle.toLowerCase().replace(/\s*›\s*/g, "/") + (root.hack ? "$ " : " ") : (root.hack ? "$ " : "")) ; color: root.hack ? root.rain : root.dim; font.family: root.mono; font.pixelSize: 15 * u }
        QueryText {
          width: pane.width - 200 * u
          height: 20 * u
          query: root.query
          placeholder: root.hack ? "ls" : "follow the white rabbit"
          color: root.glow
          placeholderColor: root.dim
          caretColor: root.rain
          fontFamily: root.mono
          pixelSize: 15 * u
          live: root.live
        }
      }
      Rectangle { visible: !root.hack; width: parent.width; height: 1; color: Util.alpha(root.rain, 0.3) }
    }

    ListView {
      id: list
      x: 28 * u
      y: 110 * u
      width: parent.width - 56 * u
      height: parent.height - y - 54 * u
      clip: true
      interactive: false
      model: root.rowModel
      currentIndex: root.selectedIndex
      highlightMoveDuration: 160
      highlightRangeMode: ListView.ApplyRange
      preferredHighlightBegin: height / 2 - root.rowH / 2
      preferredHighlightEnd: height / 2 + root.rowH / 2

      delegate: Item {
        id: row

        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label
        required property string detail

        readonly property bool selHere: root.cursorActive && row.index === root.selectedIndex
        property int revealed: 0
        property string shown: row.label

        width: list.width
        height: root.rowH

        function decode() {
          row.revealed = 0
          decoder.restart()
        }
        Component.onCompleted: decode()
        onSelHereChanged: if (row.selHere) decode()
        onLabelChanged: decode()

        Timer {
          id: decoder
          interval: 28
          repeat: true
          onTriggered: {
            row.revealed += 1
            var n = row.label.length
            row.shown = row.label.substring(0, row.revealed) + root.noise(Math.max(0, n - row.revealed))
            if (row.revealed >= n) { row.shown = row.label; stop() }
          }
        }

        Rectangle {
          anchors.fill: parent
          visible: row.selHere
          color: Util.alpha(root.rain, root.hack ? 0.9 : 0.12)
          border.color: Util.alpha(root.rain, 0.5)
          border.width: root.hack ? 0 : 1
        }
        Text {
          id: mark
          x: 12 * u
          anchors.verticalCenter: parent.verticalCenter
          text: root.hack ? (root.isBranch(row.kind) ? "d" : "-") : (row.selHere ? "▶" : (root.isBranch(row.kind) ? "+" : "·"))
          color: row.selHere ? (root.hack ? root.hackInverse : root.glow) : root.dim
          font.family: root.mono; font.pixelSize: 14 * u
        }
        RowIcon {
          x: 40 * u
          anchors.verticalCenter: parent.verticalCenter
          size: (root.hack ? 18 : 24) * u
          opacity: root.hack ? 0.85 : (row.selHere ? 1 : 0.55)
          kind: row.kind
          glyph: row.icon
          glyphFont: row.iconFont
          appIcon: row.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          fallback: row.label.charAt(0).toUpperCase()
          color: row.selHere ? root.glow : root.rain
        }
        Text {
          x: 80 * u
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - x - detailText.width - 20 * u
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.hack ? (root.isBranch(row.kind) ? "rwxr-xr-x  " : "rwxr--r--  ") + row.shown.toLowerCase() + (root.isBranch(row.kind) ? "/" : "") : row.shown
          color: row.selHere ? (root.hack ? root.hackInverse : root.glow) : (root.hack ? root.hackText : root.rain)
          style: row.selHere && !root.hack ? Text.Outline : Text.Normal
          styleColor: Util.alpha(root.rain, 0.35)
          font.family: root.mono; font.pixelSize: (root.hack ? 15 : (row.selHere ? 19 : 16)) * u; font.weight: row.selHere ? Font.Bold : Font.Normal
        }
        Text {
          id: detailText
          anchors.right: parent.right; anchors.rightMargin: 14 * u
          anchors.verticalCenter: parent.verticalCenter
          width: Math.min(implicitWidth, parent.width * 0.32)
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignRight
          textFormat: Text.PlainText
          text: row.selHere ? (root.hack ? (row.detail ? "# " + row.detail : "") : (row.detail || (root.isBranch(row.kind) ? "jack in ›" : ""))) : ""
          color: row.selHere && root.hack ? root.hackInverse : root.dim
          font.family: root.mono; font.pixelSize: 11 * u
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(row.index)
          onClicked: root.activated(row.index)
        }
      }
    }

    Text {
      visible: root.count === 0
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: root.query.length > 0 ? "there is no “" + root.query + "”" : "there is no spoon"
      color: root.rain
      font.family: root.mono; font.pixelSize: 16 * u
    }

    Text {
      anchors.left: parent.left; anchors.leftMargin: 28 * u
      anchors.bottom: parent.bottom; anchors.bottomMargin: 18 * u
      textFormat: Text.PlainText
      text: root.count > 0 ? "[" + String(root.selectedIndex + 1).padStart(3, "0") + "/" + String(root.count).padStart(3, "0") + "]  ↑↓ ^j ^k trace · ↵ jack in · ⌫ back · esc unplug" : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 11 * u
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.flood > 0.15
    text: root.hack ? "$ exec " + (root.current ? root.current.label.toLowerCase().replace(/ /g, "-") : "") : "FOLLOW THE WHITE RABBIT"
    color: root.glow
    opacity: Math.min(1, root.flood * 2)
    font.family: root.mono; font.pixelSize: 34 * u; font.weight: Font.Bold; font.letterSpacing: 6
  }
}
