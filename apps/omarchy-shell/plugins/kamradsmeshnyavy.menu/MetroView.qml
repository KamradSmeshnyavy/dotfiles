import QtQuick
import qs.Commons

// Metro: the menu as a transit map. Rows are stations on one line that snakes
// across the screen in the theme accent; submenus are interchanges with a
// stub of their own line. A train runs along the track to whichever station
// is selected, and leaves when you launch. Long menus split into zones.
SkinBase {
  id: root

  launchDelay: 600

  readonly property real marginX: 150 * u
  readonly property real topY: 250 * u
  readonly property int cols: Math.max(4, Math.min(9, Math.floor((width - marginX * 2) / (170 * u)) + 1))
  readonly property int lanes: Math.max(2, Math.min(5, Math.floor((height - topY - 150 * u) / (150 * u)) + 1))
  readonly property real sx: (width - marginX * 2) / Math.max(1, cols - 1)
  readonly property real sy: lanes > 1 ? Math.min(170 * u, (height - topY - 170 * u) / (lanes - 1)) : 0
  pageSize: cols * lanes

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  // metro-hack (netmap) draws through these: a network map, nodes for
  // stations, a packet for the train.
  readonly property color line: root.hack ? root.hackInk : root.accent
  readonly property color paper: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.ink, root.theme.light ? 0 : 0.03) : "#15161b")
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.ink, 0.55))
  readonly property color board: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, "#000000", 0.55) : "#08090b")
  readonly property color amber: root.hack ? root.hackInk : (root.theme ? root.theme.yellow : "#f6c177")
  readonly property color ink: root.foreground
  readonly property string face1: root.hack ? root.mono : root.fontFamily
  function host(i) { return "10." + (i >> 8 & 255) + "." + (parseInt(root.fakeHex(i, 2), 16)) + "." + (i % 254 + 1) }
  function rtt(i) { return (2 + parseInt(root.fakeHex(i * 3 + 1, 2), 16) % 90) + "ms" }

  // The train's position along the track, in stations from the zone start.
  property real trainT: Math.max(0, root.selectedIndex - root.pageStart)
  Behavior on trainT { NumberAnimation { id: trainRun; duration: 560; easing.type: Easing.InOutCubic } }
  property real depart: 0

  function station(slot) {
    var r = Math.floor(slot / root.cols)
    var c = slot % root.cols
    var col = r % 2 === 0 ? c : root.cols - 1 - c
    return { x: root.marginX + col * root.sx, y: root.topY + r * root.sy, r: r, col: col }
  }

  // A point on the track t stations from the zone start: straight between
  // stations on a lane, a half-loop where the line turns to the next lane.
  function posAt(t) {
    var last = Math.max(0, root.pageCount - 1)
    var tt = Math.max(0, Math.min(last + 1.4, t))
    var i = Math.floor(tt), f = tt - i
    if (i >= last) {
      var e = root.station(last)
      var dir = Math.floor(last / root.cols) % 2 === 0 ? 1 : -1
      return { x: e.x + dir * (tt - last) * root.sx, y: e.y }
    }
    var a = root.station(i), b = root.station(i + 1)
    if (a.r === b.r) return { x: a.x + (b.x - a.x) * f, y: a.y }
    var side = a.r % 2 === 0 ? 1 : -1
    var rad = root.sy / 2
    var phi = -Math.PI / 2 + f * Math.PI
    return { x: a.x + side * Math.cos(phi) * rad, y: a.y + rad + Math.sin(phi) * rad }
  }

  function navigate(dx, dy) {
    if (root.count === 0) return
    var slot = root.selectedIndex - root.pageStart
    var s = root.station(slot)
    var target
    if (dx !== 0) {
      var col = s.col + dx
      if (col >= 0 && col < root.cols) target = s.r * root.cols + (s.r % 2 === 0 ? col : root.cols - 1 - col)
      else target = slot + (s.r % 2 === 0 ? dx : -dx)
    } else {
      var r = s.r + dy
      target = r * root.cols + (r % 2 === 0 ? s.col : root.cols - 1 - s.col)
    }
    root.clampTo(root.pageStart + target)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    departAnim.restart()
  }
  NumberAnimation { id: departAnim; target: root; property: "depart"; from: 0; to: 1; duration: 600; easing.type: Easing.InCubic }
  onWoke: root.depart = 0

  Rectangle { anchors.fill: parent; color: root.paper; opacity: Math.min(0.97, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Map: faint grid, a river, the line and its termini.
  Canvas {
    id: map
    anchors.fill: parent
    property var key: [root.page, root.pageCount, root.cols, root.lanes, root.line, root.paper, root.hack]
    onKeyChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      var th = root.theme
      if (!th) return
      var u = root.u
      if (root.hack) {
        ctx.fillStyle = th.rgba(root.ink, 0.12)
        for (var dx = 0; dx < width; dx += 24 * u)
          for (var dy = 0; dy < height; dy += 24 * u) ctx.fillRect(dx, dy, 1, 1)
      } else {
        ctx.strokeStyle = th.rgba(root.ink, 0.035)
        ctx.lineWidth = 1
        for (var gx = 0; gx < width; gx += 48 * u) { ctx.beginPath(); ctx.moveTo(gx, 0); ctx.lineTo(gx, height); ctx.stroke() }
        for (var gy = 0; gy < height; gy += 48 * u) { ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(width, gy); ctx.stroke() }
      }

      ctx.strokeStyle = th.rgba(th.blue, root.hack ? 0 : 0.16)
      ctx.lineWidth = 46 * u
      ctx.lineCap = "round"
      ctx.beginPath()
      for (var rx = -40; rx <= width + 40; rx += 20) {
        var ry = height * 0.62 + Math.sin(rx / width * 5.2) * height * 0.14 + Math.sin(rx / width * 13) * 18 * u
        if (rx === -40) ctx.moveTo(rx, ry); else ctx.lineTo(rx, ry)
      }
      ctx.stroke()

      if (root.pageCount === 0) return
      var lineCol = th.rgba(root.line, 1)
      ctx.strokeStyle = lineCol
      ctx.lineWidth = (root.hack ? 1.5 : 10) * u
      if (root.hack) ctx.setLineDash([6, 4])
      ctx.lineJoin = "round"
      ctx.lineCap = "butt"
      ctx.beginPath()
      var steps = Math.max(1, (root.pageCount - 1) * 12)
      for (var k = 0; k <= steps; k++) {
        var p = root.posAt(k / 12)
        if (k === 0) ctx.moveTo(p.x, p.y); else ctx.lineTo(p.x, p.y)
      }
      ctx.stroke()
      ctx.setLineDash([])
      if (root.hack) return
      // Termini: a bar across each end of the line.
      var ends = [root.station(0), root.station(root.pageCount - 1)]
      ctx.lineWidth = 6 * u
      for (var e = 0; e < 2; e++) {
        ctx.beginPath()
        ctx.moveTo(ends[e].x + (e === 0 ? -24 : 0) * u, ends[e].y - 14 * u)
        ctx.lineTo(ends[e].x + (e === 0 ? -24 : 0) * u, ends[e].y + 14 * u)
        ctx.stroke()
      }
      ctx.beginPath()
      ctx.lineWidth = 10 * u
      ctx.moveTo(ends[0].x - 24 * u, ends[0].y)
      ctx.lineTo(ends[0].x, ends[0].y)
      ctx.stroke()
    }
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: stop

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: stop.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property var pos: stop.onPage ? root.station(stop.slot) : { x: 0, y: 0, r: 0, col: 0 }
      readonly property bool selHere: root.cursorActive && stop.index === root.selectedIndex
      readonly property bool interchange: root.isBranch(stop.kind)
      readonly property real d: stop.interchange ? 30 * u : 22 * u

      visible: stop.onPage
      x: pos.x - width / 2
      y: pos.y - height / 2
      width: 44 * u; height: 44 * u
      z: stop.selHere ? 20 : 10

      // Interchange stub: a short spur of the submenu's own line.
      Rectangle {
        visible: stop.interchange
        x: parent.width / 2
        y: parent.height / 2 - height / 2
        width: 34 * u; height: (root.hack ? 1.5 : 7) * u
        color: root.hack ? root.hackDim : (root.hues[stop.index % root.hues.length] || root.accent)
        transformOrigin: Item.Left
        rotation: 45
      }
      Rectangle {
        anchors.centerIn: parent
        width: root.hack ? stop.d * 0.7 : stop.d; height: width; radius: root.hack ? 0 : width / 2
        color: root.hack && stop.selHere ? root.hackInk : root.paper
        border.color: stop.selHere ? root.ink : root.line
        border.width: (root.hack ? 1.5 : 4) * u
        Rectangle {
          visible: stop.interchange
          anchors.centerIn: parent
          width: parent.width - (root.hack ? 8 : 12) * u; height: width; radius: root.hack ? 0 : width / 2
          color: "transparent"
          border.color: root.line
          border.width: 2 * u
        }
      }
      // Selection pulse.
      Rectangle {
        anchors.centerIn: parent
        visible: stop.selHere
        width: stop.d + 14 * u; height: width; radius: root.hack ? 0 : width / 2
        color: "transparent"
        border.color: root.ink
        border.width: 2
        SequentialAnimation on scale {
          running: stop.selHere && root.live
          loops: Animation.Infinite
          NumberAnimation { from: 1; to: 1.45; duration: 900; easing.type: Easing.OutCubic }
          NumberAnimation { from: 1.45; to: 1; duration: 0 }
        }
        SequentialAnimation on opacity {
          running: stop.selHere && root.live
          loops: Animation.Infinite
          NumberAnimation { from: 0.9; to: 0; duration: 900 }
          NumberAnimation { from: 0; to: 0.9; duration: 0 }
        }
      }
      // Name, set at an angle above the track like on a printed map.
      Row {
        x: parent.width / 2 + 6 * u
        y: parent.height / 2 - stop.d / 2 - 10 * u - height
        transformOrigin: Item.BottomLeft
        rotation: root.hack ? -24 : -32
        spacing: 6 * u
        RowIcon {
          anchors.verticalCenter: parent.verticalCenter
          size: (stop.selHere ? 22 : 16) * u
          kind: stop.kind
          glyph: stop.icon
          glyphFont: stop.iconFont
          appIcon: stop.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: stop.onPage
          fallback: stop.label.charAt(0).toUpperCase()
          color: stop.selHere ? root.line : root.ink
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          width: Math.min(implicitWidth, 170 * root.u)
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.hack ? stop.label.toLowerCase() + (stop.selHere ? "  " + root.host(stop.index) : "") : stop.label
          color: stop.selHere ? root.ink : Util.alpha(root.ink, 0.78)
          font.family: root.face1
          font.pixelSize: (stop.selHere ? 15 : 12) * root.u
          font.weight: stop.selHere ? Font.Bold : Font.Medium
        }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.selectRequested(stop.index)
        onClicked: root.activated(stop.index)
      }
    }
  }

  // The train.
  Item {
    id: train
    readonly property var p: root.posAt(root.trainT + root.depart * 1.4)
    readonly property var q: root.posAt(root.trainT + root.depart * 1.4 + 0.04)
    visible: root.pageCount > 0
    x: p.x - width / 2
    y: p.y - height / 2
    width: (root.hack ? 14 : 52) * u; height: (root.hack ? 14 : 20) * u
    z: 30
    opacity: 1 - root.depart
    rotation: Math.atan2(q.y - p.y, q.x - p.x) * 180 / Math.PI
    Rectangle {
      anchors.fill: parent
      radius: root.hack ? 0 : height / 2
      color: root.ink
      border.color: root.line
      border.width: 2
      Row {
        visible: !root.hack
        anchors.centerIn: parent
        spacing: 4 * root.u
        Repeater {
          model: 4
          Rectangle { width: 7 * root.u; height: 6 * root.u; radius: 1.5; color: Util.alpha(root.paper, 0.85) }
        }
      }
      Rectangle { visible: !root.hack; anchors.right: parent.right; anchors.rightMargin: 3; anchors.verticalCenter: parent.verticalCenter; width: 4 * root.u; height: 4 * root.u; radius: 2; color: root.amber }
    }
  }

  // Line badge, name and the departure board.
  Row {
    x: 60 * u; y: 46 * u
    spacing: 18 * u
    Rectangle {
      width: 64 * u; height: 64 * u; radius: root.hack ? 0 : 32 * u
      color: root.hack ? "transparent" : root.line
      border.color: root.line
      border.width: root.hack ? 1 : 0
      Text {
        anchors.centerIn: parent
        text: root.hack ? "if" + root.page : "M" + (root.page + 1)
        color: root.hack ? root.hackInk : (root.theme ? root.theme.ink(root.line) : "#000")
        font.family: root.face1; font.pixelSize: 24 * u; font.weight: Font.Black
      }
    }
    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6 * u
      Text {
        textFormat: Text.PlainText
        text: root.hack ? "netmap // " + root.title.toLowerCase() : root.title + " Line"
        color: root.ink
        font.family: root.face1; font.pixelSize: 26 * u; font.weight: Font.Bold
      }
      QueryText {
        width: 360 * u
        height: 18 * u
        query: root.query
        placeholder: root.hack ? "$ nmap -sn " + (root.subtitle.length > 0 ? root.subtitle.toLowerCase() : "10.0.0.0/24") : (root.subtitle.length > 0 ? root.subtitle : "type to find a station")
        color: root.ink
        placeholderColor: root.dim
        caretColor: root.line
        fontFamily: root.fontFamily
        pixelSize: 13 * u
        live: root.live
      }
    }
  }

  Rectangle {
    id: boardBox
    anchors.right: parent.right; anchors.rightMargin: 60 * u
    y: 44 * u
    width: Math.min(520 * u, root.width * 0.4); height: 72 * u
    radius: root.hack ? 0 : 8 * u
    color: root.board
    border.color: Util.alpha(root.ink, 0.12)
    Column {
      anchors.left: parent.left; anchors.leftMargin: 18 * u
      anchors.right: parent.right; anchors.rightMargin: 18 * u
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4 * u
      Text {
        text: root.hack
          ? (root.launching ? "SYN → SYN/ACK → ACK" : "$ traceroute " + (root.current ? root.host(root.selectedIndex) : "-"))
          : (root.launching ? "● DOORS CLOSING" : (root.current && root.isBranch(root.current.kind) ? "NEXT STATION · CHANGE HERE" : "NEXT STATION"))
        color: root.launching ? (root.theme ? root.theme.red : "#f00") : root.dim
        font.family: root.mono; font.pixelSize: 10 * u; font.letterSpacing: 3; font.weight: Font.Bold
        SequentialAnimation on opacity {
          running: root.launching
          loops: Animation.Infinite
          NumberAnimation { to: 0.2; duration: 120 }
          NumberAnimation { to: 1; duration: 120 }
        }
      }
      Text {
        id: nextName
        width: parent.width
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current
          ? (root.hack ? root.current.label.toLowerCase() + "  " + (root.selectedIndex + 1) + " hops  " + root.rtt(root.selectedIndex) : root.current.label.toUpperCase())
          : (root.query.length > 0 ? (root.hack ? "host unreachable" : "NO SERVICE") : "—")
        color: root.amber
        font.family: root.mono; font.pixelSize: 22 * u; font.weight: Font.Bold; font.letterSpacing: 2
        onTextChanged: boardFlick.restart()
        SequentialAnimation {
          id: boardFlick
          NumberAnimation { target: nextName; property: "opacity"; to: 0.15; duration: 60 }
          NumberAnimation { target: nextName; property: "opacity"; to: 1; duration: 60 }
          NumberAnimation { target: nextName; property: "opacity"; to: 0.4; duration: 50 }
          NumberAnimation { target: nextName; property: "opacity"; to: 1; duration: 80 }
        }
      }
    }
  }

  PageDots {
    anchors.right: boardBox.right
    anchors.top: boardBox.bottom; anchors.topMargin: 12 * u
    page: root.page
    pages: root.pages
    color: root.dim
    activeColor: root.line
    dot: 6 * u
    fontFamily: root.mono
  }

  Text {
    visible: root.count === 0
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: root.emptyText()
    color: root.dim
    font.family: root.face1; font.pixelSize: 16 * u
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 26 * u
    text: root.hack ? "[arrows] hop  [^h ^l] subnet  [enter] connect  [bksp] cd ..  [esc] exit" : "arrows / ^j ^k = ride the line  ·  ^h ^l / PgUp PgDn = zone  ·  ↵ = board  ·  ⌫ = back  ·  esc = exit"
    color: root.dim
    font.family: root.face1; font.pixelSize: 11 * u; font.letterSpacing: 2
  }
}
