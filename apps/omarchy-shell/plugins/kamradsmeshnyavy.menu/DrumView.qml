import QtQuick
import qs.Commons

// Drum: the menu on a 3D picker wheel. Rows ride the face of a cylinder that
// turns towards the selection on a spring, so a long jump spins past the rows
// in between and settles with a little overshoot. A glass band marks the
// slot; the selected row's icon and description sit large on the left.
SkinBase {
  id: root

  launchDelay: 320

  readonly property real cx: width * 0.63
  readonly property real cy: height / 2
  readonly property real rowH: 56 * u
  readonly property real drumW: Math.min(560 * u, width * 0.5)
  // Angular height of one row: rowH along the face of a cylinder of radius R.
  readonly property real radius: Math.min(height * 0.36, 330 * u)
  readonly property real stepAngle: rowH / radius
  readonly property int reach: Math.ceil((Math.PI / 2) / stepAngle)

  // drum-hack swaps these for the terminal palette; everything below draws
  // through them.
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55))
  readonly property color face: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.foreground, 0.05) : "#1c1c22")
  readonly property color deep: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, "#000000", 0.45) : "#09090c")
  readonly property color ink: root.foreground
  readonly property color hi: root.hack ? root.hackInk : root.accent
  readonly property string face1: root.hack ? root.mono : root.fontFamily

  // Follows the selection on a spring: the wheel's actual angle, in rows.
  property real spin: root.selectedIndex
  Behavior on spin { SpringAnimation { spring: 3.2; damping: 0.3; epsilon: 0.002 } }
  property real flash: 0

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    flashAnim.restart()
  }

  SequentialAnimation {
    id: flashAnim
    NumberAnimation { target: root; property: "flash"; from: 0; to: 1; duration: 90 }
    NumberAnimation { target: root; property: "flash"; to: 0; duration: 260; easing.type: Easing.OutCubic }
  }

  Rectangle {
    anchors.fill: parent
    opacity: Math.min(0.97, root.backdrop)
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: root.deep }
      GradientStop { position: 0.55; color: root.hack ? root.hackBg : root.background }
      GradientStop { position: 1.0; color: root.deep }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    property real pressY: 0
    property bool dragged: false
    onPressed: function(mouse) { pressY = mouse.y; dragged = false }
    onPositionChanged: function(mouse) {
      if (!pressed) return
      var dy = mouse.y - pressY
      var steps = Math.trunc(dy / root.rowH)
      if (steps !== 0) {
        dragged = true
        root.clampTo(root.selectedIndex - steps)
        pressY += steps * root.rowH
      }
    }
    onClicked: function(mouse) {
      if (dragged) return
      if (mouse.button === Qt.RightButton) root.backRequested()
      else if (mouse.x < root.cx - root.drumW / 2 - 40 * root.u || mouse.x > root.cx + root.drumW / 2 + 40 * root.u) root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Left: the selected row, large.
  Column {
    x: Math.max(40 * u, root.width * 0.06)
    anchors.verticalCenter: parent.verticalCenter
    width: root.cx - root.drumW / 2 - x - 50 * u
    spacing: 14 * u

    QueryText {
      width: parent.width
      height: 22 * u
      query: root.query
      placeholder: root.hack ? "$ grep -i " + (root.subtitle.length > 0 ? root.subtitle.toLowerCase().replace(/\s*›\s*/g, "/") : "~") : (root.subtitle.length > 0 ? root.subtitle : root.title) + "  ·  type to search"
      color: root.ink
      placeholderColor: root.dim
      caretColor: root.hi
      fontFamily: root.face1
      pixelSize: 14 * u
      live: root.live
    }
    Rectangle { width: root.hack ? parent.width : 60 * u; height: root.hack ? 1 : 2; color: root.hack ? root.hackLine : root.accent }
    Item { width: 1; height: 20 * u }
    RowIcon {
      id: hero
      size: (root.hack ? 56 : 120) * u
      opacity: root.hack ? 0.85 * pop : pop
      kind: root.current ? root.current.kind : ""
      glyph: root.current ? root.current.icon : ""
      glyphFont: root.current ? root.current.iconFont : ""
      appIcon: root.current ? root.current.appIcon : ""
      resolver: root.iconResolver
      fontFamily: root.fontFamily
      fallback: root.current ? root.current.label.charAt(0).toUpperCase() : ""
      color: root.hi
      // Every new selection drops in from the wheel's side.
      property real pop: 1
      scale: 0.86 + 0.14 * pop
      Connections {
        target: root
        function onSelectedIndexChanged() { heroPop.restart() }
      }
      NumberAnimation { id: heroPop; target: hero; property: "pop"; from: 0.3; to: 1; duration: 320; easing.type: Easing.OutBack }
    }
    Text {
      width: parent.width
      wrapMode: Text.Wrap
      maximumLineCount: 2
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.hack ? "> " + root.current.label.toLowerCase() : root.current.label) : root.emptyText()
      color: root.ink
      font.family: root.face1; font.pixelSize: (root.hack ? 26 : 34) * u; font.weight: root.hack ? Font.Bold : Font.DemiBold
    }
    Text {
      width: parent.width
      wrapMode: Text.Wrap
      maximumLineCount: 3
      elide: Text.ElideRight
      textFormat: Text.PlainText
      visible: !root.hack
      text: root.current ? (root.current.detail || (root.isBranch(root.current.kind) ? "Opens a submenu" : "")) : ""
      color: root.dim
      font.family: root.fontFamily; font.pixelSize: 14 * u
    }
    Text {
      textFormat: Text.PlainText
      visible: !root.hack
      text: root.count > 0 ? (root.selectedIndex + 1) + " / " + root.count : ""
      color: root.dim
      font.family: root.mono; font.pixelSize: 12 * u; font.letterSpacing: 2
    }
    // drum-hack: `stat` of the selected row.
    Repeater {
      model: root.hack && root.current ? [
        ["kind", root.current.kind === "app" ? "application" : (root.isBranch(root.current.kind) ? "directory" : "executable")],
        ["inode", "0x" + root.fakeHex(root.selectedIndex, 6)],
        ["offset", "0x" + root.selectedIndex.toString(16).padStart(4, "0") + " / 0x" + root.count.toString(16).padStart(4, "0")],
        ["desc", root.current.detail || "-"]
      ] : []
      Row {
        required property var modelData
        spacing: 0
        Text { width: 90 * root.u; text: modelData[0]; color: root.dim; font.family: root.mono; font.pixelSize: 12 * root.u }
        Text { width: 300 * root.u; elide: Text.ElideRight; textFormat: Text.PlainText; text: modelData[1]; color: root.ink; font.family: root.mono; font.pixelSize: 12 * root.u }
      }
    }
  }

  // The drum's housing: a dark well with the face lit in the middle.
  Rectangle {
    x: root.cx - root.drumW / 2 - 18 * u
    y: root.cy - root.radius - 10 * u
    width: root.drumW + 36 * u
    height: root.radius * 2 + 20 * u
    radius: root.hack ? 0 : 18 * u
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.deep }
      GradientStop { position: 0.5; color: root.face }
      GradientStop { position: 1.0; color: root.deep }
    }
    border.color: root.hack ? root.hackLine : Util.alpha(root.foreground, 0.08)
  }

  // Scale ticks on both rims; they turn with the drum.
  Canvas {
    id: ticks
    x: root.cx - root.drumW / 2 - 18 * u
    y: root.cy - root.radius
    width: root.drumW + 36 * u
    height: root.radius * 2
    property real phase: root.spin
    property bool mode: root.hack
    onModeChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      if (!root.theme) return
      var R = root.radius
      var frac = root.spin - Math.floor(root.spin)
      for (var k = -root.reach * 2; k <= root.reach * 2; k++) {
        var th = (k - frac) * root.stepAngle / 2
        if (Math.abs(th) >= Math.PI / 2) continue
        var y = R + R * Math.sin(th)
        var a = Math.cos(th)
        ctx.fillStyle = root.theme.rgba(root.ink, 0.35 * a * a)
        var long = ((k + Math.floor(root.spin) * 2) % 2 + 2) % 2 === 0
        var w = (long ? 10 : 5) * root.u
        ctx.fillRect(4 * root.u, y - 0.75, w * a, 1.5)
        ctx.fillRect(width - 4 * root.u - w * a, y - 0.75, w * a, 1.5)
      }
    }
  }

  // Glass band at the slot.
  Rectangle {
    x: root.cx - root.drumW / 2 - 6 * u
    y: root.cy - root.rowH / 2
    width: root.drumW + 12 * u
    height: root.rowH
    radius: root.hack ? 0 : 10 * u
    // drum-hack inverts the band on launch, like a selected terminal line.
    color: Util.alpha(root.hi, root.hack ? 0.10 + 0.8 * root.flash : 0.12 + 0.35 * root.flash)
    border.color: Util.alpha(root.hi, 0.55 + 0.45 * root.flash)
    border.width: 1
    z: 5
    Rectangle { visible: !root.hack; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 1; height: parent.height * 0.45; radius: parent.radius; color: Util.alpha("#ffffff", 0.05) }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: row

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label
      required property string detail

      readonly property real k: row.index - root.spin
      readonly property real theta: k * root.stepAngle
      readonly property bool onFace: Math.abs(row.theta) < Math.PI / 2 - 0.02
      readonly property real facing: Math.max(0, Math.cos(row.theta))
      readonly property bool selHere: root.cursorActive && row.index === root.selectedIndex

      visible: row.onFace
      width: root.drumW
      height: root.rowH
      x: root.cx - width / 2
      y: root.cy - height / 2 + root.radius * Math.sin(row.theta)
      z: 10 + Math.round(row.facing * 10)
      opacity: Math.pow(row.facing, 1.6)
      transform: [
        Scale { origin.x: row.width / 2; origin.y: row.height / 2; yScale: Math.max(0.05, row.facing); xScale: 0.9 + 0.1 * row.facing },
        Rotation { origin.x: row.width / 2; origin.y: row.height / 2; axis { x: 1; y: 0; z: 0 } angle: -row.theta * 180 / Math.PI * 0.35 }
      ]

      Text {
        visible: root.hack
        x: 16 * u
        anchors.verticalCenter: parent.verticalCenter
        text: (row.selHere ? "> " : "  ") + "0x" + row.index.toString(16).padStart(2, "0")
        color: row.selHere ? root.hi : root.dim
        font.family: root.mono; font.pixelSize: 13 * u
      }
      RowIcon {
        x: (root.hack ? 98 : 18) * u
        anchors.verticalCenter: parent.verticalCenter
        size: (root.hack ? 20 : 30) * u
        opacity: root.hack ? 0.85 : 1
        kind: row.kind
        glyph: row.icon
        glyphFont: row.iconFont
        appIcon: row.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: row.onFace
        fallback: row.label.charAt(0).toUpperCase()
        color: row.selHere ? root.hi : root.ink
      }
      Text {
        x: (root.hack ? 132 : 64) * u
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 64 * u - trail.width - 24 * u
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.hack ? row.label.toLowerCase() : row.label
        color: row.selHere ? root.ink : Util.alpha(root.ink, 0.75)
        font.family: root.face1
        font.pixelSize: (root.hack ? (row.selHere ? 17 : 15) : (row.selHere ? 20 : 17)) * u
        font.weight: row.selHere ? Font.DemiBold : Font.Normal
      }
      Text {
        id: trail
        anchors.right: parent.right; anchors.rightMargin: 18 * u
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, parent.width * 0.3)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        textFormat: Text.PlainText
        text: root.hack ? (root.isBranch(row.kind) ? "dir/" : (row.kind === "app" ? "bin" : "sh")) : (root.isBranch(row.kind) ? "›" : (row.selHere ? "↵" : ""))
        color: row.selHere ? root.hi : root.dim
        font.family: root.face1; font.pixelSize: (root.hack ? 12 : 18) * u
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: row.facing > 0.55
        onClicked: {
          if (row.selHere) root.activated(row.index)
          else root.selectRequested(row.index)
        }
      }
    }
  }

  // Fade the drum's top and bottom into the housing.
  Rectangle {
    x: root.cx - root.drumW / 2 - 18 * u
    y: root.cy - root.radius - 10 * u
    width: root.drumW + 36 * u; height: root.radius * 0.32
    z: 30
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.deep }
      GradientStop { position: 1.0; color: Util.alpha(root.deep, 0) }
    }
  }
  Rectangle {
    x: root.cx - root.drumW / 2 - 18 * u
    y: root.cy + root.radius + 10 * u - height
    width: root.drumW + 36 * u; height: root.radius * 0.32
    z: 30
    gradient: Gradient {
      GradientStop { position: 0.0; color: Util.alpha(root.deep, 0) }
      GradientStop { position: 1.0; color: root.deep }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 30 * u
    text: root.hack ? "[j/k] seek  [enter] exec  [bksp] cd ..  [esc] exit" : "↑↓ / ^j ^k / wheel / drag = spin  ·  ↵ = pick  ·  ⌫ = back  ·  esc = close"
    color: root.dim
    font.family: root.face1; font.pixelSize: 11 * u; font.letterSpacing: 2
  }
}
