import QtQuick
import qs.Commons

// "Minimal Board" from omlauch's simple.qml: a dot-grid dashboard with a clock
// tile, an equaliser tile and a board of app tiles. Upstream was Tokyo Night;
// here every tile, line and bar comes from the active theme. A board holds a
// fixed number of tiles, so long menus turn into pages.
SkinBase {
  id: root

  launchDelay: 260

  readonly property real pitch: 164 * u
  readonly property real gap: 14 * u
  readonly property int cols: Math.max(4, Math.min(7, Math.floor((width - 60 * u + gap) / pitch)))
  readonly property int rows: height > 950 * u ? 5 : 4
  readonly property real ox: (width - (cols * pitch - gap)) / 2
  readonly property real oy: (height - (rows * pitch - gap)) / 2 + 8 * u
  property var slots: []
  readonly property int perPage: Math.max(1, root.slots.length - 2)
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.perPage)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.perPage))
  readonly property int pageStart: root.page * root.perPage

  readonly property color tile: root.theme ? root.theme.surface : Util.alpha(root.foreground, 0.08)
  readonly property color line: root.theme ? root.theme.mix(root.tile, root.foreground, 0.16) : Util.alpha(root.foreground, 0.2)
  readonly property color dim: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color blue: root.accent
  readonly property color cyan: root.theme ? root.theme.cyan : root.accent
  readonly property color purple: root.theme ? root.theme.magenta : root.accent
  readonly property color green: root.theme ? root.theme.green : root.accent
  readonly property var bars: root.theme
    ? [root.accent, root.theme.cyan, root.theme.magenta, root.theme.green, root.theme.yellow, root.theme.orange, root.theme.red]
    : [root.accent, root.accent, root.accent, root.accent, root.accent, root.accent, root.accent]

  property string now: ""
  property string dateStr: ""
  property bool coldStart: true

  function tickClock() {
    var d = new Date()
    root.now = Qt.formatTime(d, "HH:mm")
    root.dateStr = Qt.formatDate(d, "ddd · MMM d")
  }

  function buildSlots() {
    var cols = root.cols, rows = root.rows
    var occ = []
    for (var y = 0; y < rows; y++) {
      occ.push([])
      for (var x = 0; x < cols; x++) occ[y].push(false)
    }
    var g = []
    function place(px, py, w, h) {
      for (var yy = py; yy < py + h; yy++)
        for (var xx = px; xx < px + w; xx++) occ[yy][xx] = true
      g.push({ x: px, y: py, w: w, h: h })
    }
    place(0, 0, 2, 2)
    place(2, 0, 2, 1)
    for (var y2 = 0; y2 < rows; y2++)
      for (var x2 = 0; x2 < cols; x2++)
        if (!occ[y2][x2]) place(x2, y2, 1, 1)
    root.slots = g
  }

  // Arrows move across the board by slot position, so the 2×2 clock and the
  // wide equaliser don't throw the cursor off its column.
  function navigate(dx, dy) {
    if (root.count === 0) return
    if (dy === 0) { root.clampTo(root.selectedIndex + dx); return }
    var from = root.slots[2 + root.selectedIndex - root.pageStart]
    if (!from) return
    var best = -1, bestScore = Infinity
    for (var i = 2; i < root.slots.length; i++) {
      var s = root.slots[i]
      var idx = root.pageStart + i - 2
      if (idx >= root.count) break
      var vy = s.y - from.y
      if (vy * dy <= 0) continue
      var score = Math.abs(vy) * 10 + Math.abs(s.x - from.x)
      if (score < bestScore) { bestScore = score; best = idx }
    }
    if (best >= 0) root.selectRequested(best)
    else root.clampTo(root.selectedIndex + dy * root.perPage)
  }

  onColsChanged: buildSlots()
  onRowsChanged: buildSlots()
  Component.onCompleted: { buildSlots(); tickClock() }
  onWoke: { root.coldStart = true; coldTimer.restart(); tickClock() }
  // Drilling into a submenu deals the board again.
  onBurstChanged: if (root.burst) { root.coldStart = true; coldTimer.restart() }

  Timer { id: coldTimer; interval: 700; running: true; onTriggered: root.coldStart = false }
  Timer { interval: 1000; repeat: true; running: root.live; onTriggered: root.tickClock() }

  Rectangle {
    anchors.fill: parent
    color: root.background
    opacity: root.backdrop
  }

  Canvas {
    anchors.fill: parent
    property string dot: root.theme ? root.theme.rgba(root.foreground, 0.06) : "rgba(192,202,245,0.05)"
    onDotChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = dot
      for (var x = 20; x < width; x += 34)
        for (var y = 20; y < height; y += 34) ctx.fillRect(x, y, 1.5, 1.5)
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

  // Clock tile.
  Item {
    readonly property var sl: root.slots.length > 0 ? root.slots[0] : { x: 0, y: 0, w: 2, h: 2 }
    x: root.ox + sl.x * root.pitch
    y: root.oy + sl.y * root.pitch
    width: sl.w * root.pitch - root.gap
    height: sl.h * root.pitch - root.gap

    Rectangle { anchors.fill: parent; radius: 22 * u; color: root.tile; border.color: root.line; border.width: 1 }
    Text { x: 26 * u; y: 22 * u; text: root.now; color: root.foreground; font.family: root.fontFamily; font.pixelSize: 46 * u; font.bold: true }
    Text { x: 28 * u; y: 80 * u; text: root.dateStr; color: root.dim; font.family: root.fontFamily; font.pixelSize: 12 * u }

    // Search box, laid over the clock tile as upstream does.
    Rectangle {
      x: 26 * u
      y: 122 * u
      width: parent.width - 52 * u
      height: 42 * u
      radius: 12 * u
      color: root.background
      border.color: root.query.length > 0 ? root.blue : root.line
      QueryText {
        x: 14 * u
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 28 * u
        query: root.query
        placeholder: root.subtitle.length > 0 ? root.subtitle.toLowerCase() + "…" : "search " + root.title.toLowerCase() + "…"
        color: root.foreground
        placeholderColor: root.dim
        caretColor: root.blue
        fontFamily: root.fontFamily
        pixelSize: 13 * u
        live: root.live
      }
    }

    Text {
      x: 28 * u; y: parent.height - 46 * u
      text: root.count + " tiles on the board" + (root.pages > 1 ? " · page " + (root.page + 1) + "/" + root.pages : "")
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: 10 * u
    }
    Rectangle { x: 26 * u; y: parent.height - 26 * u; width: 60 * u; height: 4 * u; radius: 2 * u; color: root.blue }
    Rectangle { x: 92 * u; y: parent.height - 26 * u; width: 24 * u; height: 4 * u; radius: 2 * u; color: root.purple }
    Rectangle { x: 122 * u; y: parent.height - 26 * u; width: 12 * u; height: 4 * u; radius: 2 * u; color: root.green }
  }

  // Equaliser tile.
  Item {
    readonly property var sl: root.slots.length > 1 ? root.slots[1] : { x: 2, y: 0, w: 2, h: 1 }
    x: root.ox + sl.x * root.pitch
    y: root.oy + sl.y * root.pitch
    width: sl.w * root.pitch - root.gap
    height: sl.h * root.pitch - root.gap

    Rectangle { anchors.fill: parent; radius: 22 * u; color: root.tile; border.color: root.line; border.width: 1 }
    Text {
      x: 20 * u; y: 16 * u
      width: parent.width - 40 * u
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.title.toUpperCase()
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: 10 * u
    }
    Item {
      x: 20 * u; y: 46 * u
      width: parent.width - 40 * u; height: parent.height - 66 * u
      Repeater {
        model: 7
        Rectangle {
          required property int index
          x: index * ((parent.width - 10 * u) / 6)
          width: 12 * u
          radius: 4 * u
          anchors.bottom: parent.bottom
          color: root.bars[index]
          height: 14 * u
          SequentialAnimation on height {
            loops: Animation.Infinite
            running: root.live
            NumberAnimation { to: (26 + ((index * 37) % 44)) * u; duration: 320 + index * 80; easing.type: Easing.InOutSine }
            NumberAnimation { to: (12 + ((index * 23) % 22)) * u; duration: 280 + index * 60; easing.type: Easing.InOutSine }
          }
        }
      }
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

      readonly property int slotIndex: 2 + tileItem.index - root.pageStart
      readonly property bool onPage: tileItem.index >= root.pageStart && tileItem.index < root.pageStart + root.perPage
      readonly property var sl: tileItem.onPage && root.slots[tileItem.slotIndex] ? root.slots[tileItem.slotIndex] : { x: 0, y: 0, w: 1, h: 1 }
      readonly property bool sel: root.cursorActive && tileItem.index === root.selectedIndex
      readonly property bool hovered: ma.containsMouse
      readonly property bool launchingHere: root.launching && root.launchIndex === tileItem.index
      property bool entered: !root.coldStart

      visible: tileItem.onPage
      x: root.ox + sl.x * root.pitch
      y: root.oy + sl.y * root.pitch
      width: sl.w * root.pitch - root.gap
      height: sl.h * root.pitch - root.gap
      scale: entered ? (hovered ? 1.04 : 1) * (launchingHere ? 0.88 : 1) : 0.7
      opacity: entered ? (launchingHere ? 0 : 1) : 0
      Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
      Behavior on opacity { NumberAnimation { duration: 240 } }
      Timer { interval: 40 * Math.max(0, tileItem.slotIndex); running: root.coldStart && tileItem.onPage; onTriggered: tileItem.entered = true }

      Connections {
        target: root
        function onColdStartChanged() { tileItem.entered = !root.coldStart }
      }

      Rectangle {
        anchors.fill: parent
        radius: 22 * u
        color: root.tile
        border.color: tileItem.sel ? root.blue : (tileItem.hovered ? root.cyan : root.line)
        border.width: tileItem.sel ? 2 : 1
      }

      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 26 * u
        size: 56 * u
        rotation: tileItem.hovered ? -6 : 0
        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
        kind: tileItem.kind
        glyph: tileItem.icon
        glyphFont: tileItem.iconFont
        appIcon: tileItem.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: tileItem.onPage
        fallback: tileItem.label.charAt(0).toUpperCase()
        color: tileItem.sel ? root.blue : root.cyan
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 96 * u
        width: parent.width - 16 * u
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: tileItem.label
        color: tileItem.sel ? root.foreground : Util.alpha(root.foreground, 0.72)
        font.family: root.fontFamily
        font.pixelSize: 11 * u
        font.bold: tileItem.sel
      }
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 118 * u
        width: 26 * u; height: 5 * u; radius: 3 * u
        color: tileItem.sel ? root.blue : (root.isBranch(tileItem.kind) ? Util.alpha(root.purple, 0.6) : root.line)
      }

      MouseArea {
        id: ma
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
    text: root.query.length > 0 ? "no tiles match — the board is empty" : "nothing on this board"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 14 * u
    z: 500
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.height - 34 * u
    text: "type = filter · hover = select · click / ↵ = open · arrows / wheel = move · ⌫ = back · esc close"
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: 11 * u
    opacity: 0.8
    z: 500
  }
}
