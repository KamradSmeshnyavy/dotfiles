import QtQuick
import qs.Commons

// Every menu drawn as a star map: one star per row, placed on a golden-angle
// spiral so density stays even at any row count, and linked to its nearest
// neighbours so the field reads as a constellation rather than a scatter plot.
Item {
  id: root

  property var rowModel: null
  property var iconResolver: null
  property int selectedIndex: 0
  property bool cursorActive: true
  property string title: ""
  property string subtitle: ""
  property string query: ""
  property color foreground: "white"
  property color accent: "white"
  property string fontFamily: "sans-serif"
  // A menu change earns the full fly-out from the centre; a keystroke while
  // filtering only re-settles, or the field would explode on every letter.
  property bool burst: true
  property real backdrop: 0.94

  readonly property int count: root.rowModel ? root.rowModel.count : 0
  // Past this many stars the names collide more than they help, so only the
  // star under the cursor keeps its label.
  readonly property bool labelsVisible: root.count <= 64
  // A crowded sky needs thinner everything, or the links turn into scribble
  // and the stars into a texture.
  readonly property bool dense: root.count > 80
  readonly property real starSize: root.dense ? Style.space(36) : Style.space(46)

  signal activated(int index)
  signal selectRequested(int index)

  property var points: []
  property var edges: []
  property var specks: []
  property real drift: 0
  readonly property int paintPhase: Math.round(root.drift * 80)

  function layout() {
    var count = root.count
    var w = Math.max(1, field.width)
    var h = Math.max(1, field.height)
    var golden = Math.PI * (3 - Math.sqrt(5))
    var pts = []
    // A handful of rows should cluster near the middle rather than fling
    // themselves onto the rim of an otherwise empty sky.
    var spread = Math.min(1, Math.sqrt(count / 14))

    for (var i = 0; i < count; i++) {
      var radius = count > 1 ? Math.sqrt(i / (count - 1)) * spread : 0
      var theta = i * golden
      pts.push({
        x: w / 2 + (w / 2 * 0.88) * radius * Math.cos(theta),
        y: h / 2 + (h / 2 * 0.84) * radius * Math.sin(theta)
      })
    }

    root.points = pts
    root.edges = root.buildEdges(pts, root.dense ? 1 : 2)
    root.specks = root.buildSpecks(w, h)
    sky.requestPaint()
  }

  // Each star reaches for its two closest neighbours; shared links are drawn
  // once. That yields the sparse, slightly irregular web a star chart has.
  function buildEdges(pts, links) {
    var out = []
    var seen = ({})

    for (var a = 0; a < pts.length; a++) {
      var first = -1, firstDist = Infinity
      var second = -1, secondDist = Infinity

      for (var b = 0; b < pts.length; b++) {
        if (a === b) continue
        var dx = pts[a].x - pts[b].x
        var dy = pts[a].y - pts[b].y
        var dist = dx * dx + dy * dy
        if (dist < firstDist) {
          secondDist = firstDist; second = first
          firstDist = dist; first = b
        } else if (dist < secondDist) {
          secondDist = dist; second = b
        }
      }

      var neighbours = links > 1 ? [first, second] : [first]
      for (var k = 0; k < neighbours.length; k++) {
        var other = neighbours[k]
        if (other < 0) continue
        var key = a < other ? (a + "-" + other) : (other + "-" + a)
        if (seen[key]) continue
        seen[key] = true
        out.push([a, other])
      }
    }
    return out
  }

  // Decorative background stars. Seeded so the sky is the same every time the
  // launcher opens instead of reshuffling under the rows.
  function buildSpecks(w, h) {
    var out = []
    var seed = 20260924
    function random() {
      seed = (seed * 1103515245 + 12345) % 2147483648
      return seed / 2147483648
    }
    for (var i = 0; i < 150; i++) {
      out.push({
        x: random() * w,
        y: random() * h,
        r: 0.5 + random() * 1.3,
        a: 0.08 + random() * 0.26,
        phase: random() * 6.283
      })
    }
    return out
  }

  function driftedX(index) {
    var point = root.points[index]
    if (!point) return 0
    return point.x + Math.sin(root.drift * 2 + index * 0.7) * Style.space(3)
  }

  function driftedY(index) {
    var point = root.points[index]
    if (!point) return 0
    return point.y + Math.cos(root.drift * 2 + index * 1.3) * Style.space(3)
  }

  // Arrow keys move to the nearest star in that direction, which is the only
  // reading of "up" that makes sense in a 2D field. Nothing that way wraps to
  // the far side instead of dead-ending.
  function navigate(dx, dy) {
    if (root.count === 0) return
    var from = root.points[root.selectedIndex] || root.points[0]
    if (!from) return

    var best = -1
    var bestScore = Infinity
    var wrap = -1
    var wrapScore = -Infinity

    for (var i = 0; i < root.points.length; i++) {
      if (i === root.selectedIndex) continue
      var vx = root.points[i].x - from.x
      var vy = root.points[i].y - from.y
      var along = vx * dx + vy * dy
      var across = Math.abs(vx * dy - vy * dx)

      if (along > 1) {
        var score = along + across * 2.4
        if (score < bestScore) { bestScore = score; best = i }
      } else if (-along > wrapScore) {
        wrapScore = -along
        wrap = i
      }
    }

    var target = best >= 0 ? best : wrap
    if (target >= 0) root.selectRequested(target)
  }

  onWidthChanged: layout()
  onHeightChanged: layout()
  onCountChanged: layout()
  onPaintPhaseChanged: sky.requestPaint()
  Component.onCompleted: layout()

  NumberAnimation on drift {
    from: 0
    to: Math.PI * 2
    duration: 38000
    loops: Animation.Infinite
    running: root.visible
  }

  Column {
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: Style.space(18)
    spacing: Style.space(2)

    Text {
      textFormat: Text.PlainText
      text: root.query.length > 0 ? root.query : root.title
      color: root.foreground
      opacity: root.query.length > 0 ? 1 : 0.85
      font.family: root.fontFamily
      font.pixelSize: Style.font.displayLarge
      font.weight: Font.Light
      elide: Text.ElideRight
      width: parent.width
    }

    Text {
      textFormat: Text.PlainText
      text: root.query.length > 0
        ? (root.count + (root.count === 1 ? " match" : " matches"))
        : root.subtitle
      color: root.foreground
      opacity: 0.4
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
      width: parent.width
    }
  }

  Text {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: Style.space(14)
    textFormat: Text.PlainText
    text: "↑ ↓ ← →  move     ⏎  open     ⌫  back     esc  close"
    color: root.foreground
    opacity: 0.22
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  Item {
    id: field

    anchors.fill: parent
    anchors.topMargin: Style.space(86)
    anchors.bottomMargin: Style.space(46)
    anchors.leftMargin: Style.space(40)
    anchors.rightMargin: Style.space(40)

    // The whole sky leans a little towards the pointer. Just enough parallax
    // to feel like depth, not enough to make anything hard to click.
    property real parallaxX: 0
    property real parallaxY: 0
    transform: Translate {
      x: field.parallaxX
      y: field.parallaxY
      Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutQuad } }
      Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutQuad } }
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      onPositionChanged: function(mouse) {
        field.parallaxX = (mouse.x - field.width / 2) * 0.016
        field.parallaxY = (mouse.y - field.height / 2) * 0.016
      }
      onExited: { field.parallaxX = 0; field.parallaxY = 0 }
    }

    Canvas {
      id: sky
      anchors.fill: parent

      onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        for (var s = 0; s < root.specks.length; s++) {
          var speck = root.specks[s]
          var twinkle = 0.65 + 0.35 * Math.sin(root.drift * 6 + speck.phase)
          ctx.fillStyle = Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, speck.a * twinkle)
          ctx.beginPath()
          ctx.arc(speck.x, speck.y, speck.r, 0, Math.PI * 2)
          ctx.fill()
        }

        ctx.lineWidth = 1
        for (var i = 0; i < root.edges.length; i++) {
          var edge = root.edges[i]
          if (!root.points[edge[0]] || !root.points[edge[1]]) continue

          var lit = root.cursorActive && (edge[0] === root.selectedIndex || edge[1] === root.selectedIndex)
          ctx.strokeStyle = lit
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.7)
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, root.dense ? 0.07 : 0.16)
          ctx.beginPath()
          ctx.moveTo(root.driftedX(edge[0]), root.driftedY(edge[0]))
          ctx.lineTo(root.driftedX(edge[1]), root.driftedY(edge[1]))
          ctx.stroke()
        }
      }
    }

    Repeater {
      model: root.rowModel

      delegate: Item {
        id: star

        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label
        required property string detail

        readonly property bool isApp: star.kind === "app"
        readonly property bool opensMore: star.kind === "menu" || star.kind === "link"
        readonly property bool isActive: root.cursorActive && star.index === root.selectedIndex
        readonly property real targetX: root.driftedX(star.index)
        readonly property real targetY: root.driftedY(star.index)
        // 0 while the star is still at the centre of the burst, 1 once it has
        // arrived. Everything else about the entrance hangs off this.
        property real appear: 0

        x: (field.width / 2) + (targetX - field.width / 2) * star.appear - width / 2
        y: (field.height / 2) + (targetY - field.height / 2) * star.appear - height / 2
        width: root.starSize
        height: root.starSize
        z: star.isActive ? 3 : 1
        opacity: star.appear
        scale: 0.6 + 0.4 * star.appear

        SequentialAnimation {
          running: true
          PauseAnimation { duration: root.burst ? Math.max(0, Math.min(star.index * 7, 320)) : 0 }
          NumberAnimation {
            target: star
            property: "appear"
            from: root.burst ? 0 : 0.82
            to: 1
            duration: root.burst ? 460 : 190
            easing.type: Easing.OutCubic
          }
        }

        // Submenus wear an orbit: the ring says there is more behind this star.
        Rectangle {
          anchors.centerIn: parent
          width: parent.width * 0.92
          height: width
          radius: width / 2
          visible: star.opensMore
          color: "transparent"
          border.width: Math.max(1, Style.space(1))
          border.color: Util.alpha(root.foreground, star.isActive ? 0.5 : 0.22)
          opacity: star.isActive ? 1 : 0.9
        }

        Rectangle {
          id: halo
          anchors.centerIn: parent
          width: parent.width * 1.04
          height: width
          radius: width / 2
          color: Util.alpha(root.accent, 0.5)
          border.width: star.isActive ? Math.max(1, Style.space(2)) : 0
          border.color: Util.alpha(root.foreground, 0.75)
          opacity: star.isActive ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 160 } }

          SequentialAnimation on scale {
            running: star.isActive
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 1.12; duration: 1100; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.12; to: 1; duration: 1100; easing.type: Easing.InOutSine }
          }
        }

        Image {
          anchors.centerIn: parent
          visible: star.isApp
          width: root.starSize * (star.isActive ? 0.72 : 0.62)
          height: width
          fillMode: Image.PreserveAspectFit
          // Decode at physical pixels or PNG icons come out upscaled on HiDPI.
          sourceSize.width: width * Screen.devicePixelRatio
          sourceSize.height: height * Screen.devicePixelRatio
          source: star.isApp && root.iconResolver ? root.iconResolver(star.appIcon) : ""
          asynchronous: true
          opacity: star.isActive ? 1 : 0.9
          Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        Text {
          anchors.centerIn: parent
          visible: !star.isApp
          text: star.icon
          color: star.isActive ? root.foreground : Util.alpha(root.foreground, 0.88)
          font.family: star.iconFont.length > 0 ? star.iconFont : root.fontFamily
          font.pixelSize: Math.round(root.starSize * (star.isActive ? 0.58 : 0.5))
          Behavior on font.pixelSize { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        Text {
          textFormat: Text.PlainText
          anchors.top: parent.bottom
          anchors.topMargin: Style.space(-2)
          anchors.horizontalCenter: parent.horizontalCenter
          width: root.count <= 26 ? Style.space(180) : Style.space(104)
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          text: star.label
          visible: star.isActive || root.labelsVisible
          color: root.foreground
          opacity: star.isActive ? 1 : 0.46
          font.family: root.fontFamily
          font.pixelSize: root.count <= 26 ? Style.font.body : Style.font.bodySmall
          font.weight: star.isActive ? Font.Medium : Font.Normal
          Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Text {
          textFormat: Text.PlainText
          anchors.top: parent.bottom
          anchors.topMargin: Style.space(12)
          anchors.horizontalCenter: parent.horizontalCenter
          width: Style.space(150)
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          text: star.detail
          visible: star.isActive && star.detail.length > 0
          color: root.foreground
          opacity: 0.45
          font.family: root.fontFamily
          font.pixelSize: Style.font.bodySmall
        }

        MouseArea {
          anchors.centerIn: parent
          width: root.starSize * 1.2
          height: root.starSize * 1.2
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(star.index)
          onClicked: root.activated(star.index)
        }
      }
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: Style.space(8)
    visible: root.count === 0

    Text {
      text: "󰀽"
      color: root.foreground
      opacity: 0.55
      font.family: root.fontFamily
      font.pixelSize: Style.font.displayLarge
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(320)
    }

    Text {
      textFormat: Text.PlainText
      text: root.query ? "No stars match “" + root.query + "”" : "Nothing here yet"
      color: root.foreground
      opacity: 0.65
      font.family: root.fontFamily
      font.pixelSize: Style.font.title
      horizontalAlignment: Text.AlignHCenter
      width: Style.space(320)
    }
  }
}
