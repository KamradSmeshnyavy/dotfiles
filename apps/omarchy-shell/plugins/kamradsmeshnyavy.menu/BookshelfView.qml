import QtQuick
import qs.Commons

// Bookshelf: three wooden shelves of spines, one book per row, each its own
// height, width and binding colour. The selected book slides out and its
// cover opens on the reading stand to the right; launching opens it flat.
// Wood is the theme brown, bindings are its hues, gilt lines its yellow.
SkinBase {
  id: root

  launchDelay: 460

  readonly property real caseX: 70 * u
  readonly property real caseW: root.width * 0.64 - caseX
  readonly property real caseTop: 120 * u
  readonly property real shelfH: (root.height - caseTop - 110 * u) / 3
  readonly property real plank: 18 * u
  readonly property real slotW: 64 * u
  readonly property int perShelf: Math.max(4, Math.floor((caseW - 40 * u) / slotW))
  pageSize: perShelf * 3

  readonly property var hues: root.theme ? root.theme.hues : [root.accent]
  // bookshelf-hack (fs) draws through these: outlined bars on 1px shelves
  // and a `stat` instead of a cover.
  readonly property color dim: root.hack ? root.hackDim : (root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55))
  readonly property color wood: root.hack ? root.hackLine : (root.theme ? root.theme.mix(root.theme.brown, root.background, 0.25) : "#5a3a22")
  readonly property color woodDark: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.wood, "#000000", 0.45) : "#2a1a10")
  readonly property color wall: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.background, root.theme.brown, 0.12) : "#17120e")
  readonly property color gilt: root.hack ? root.hackInk : (root.theme ? root.theme.mix(root.theme.yellow, root.foreground, 0.15) : "#d8b46a")
  readonly property color paper: root.hack ? root.hackBg : (root.theme ? root.theme.mix(root.foreground, root.theme.yellow, 0.12) : "#efe6d2")
  readonly property string serif: root.hack ? root.mono : "serif"
  function perms(kind) { return root.isBranch(kind) ? "drwxr-xr-x" : (kind === "app" ? "-rwxr-xr-x" : "-rwx------") }

  property real open: 0

  function hash(i, s) { var x = Math.sin(i * 91.7 + s * 47.3) * 24634.6345; return x - Math.floor(x) }
  function bookColor(i) { if (root.hack) return root.hackBg; return root.theme ? root.theme.mix(root.hues[i % root.hues.length], root.background, 0.3 + root.hash(i, 4) * 0.25) : "#704030" }
  function shelfFloor(s) { return root.caseTop + (s + 1) * root.shelfH - root.plank }

  function navigate(dx, dy) {
    if (dx !== 0) root.clampTo(root.selectedIndex + dx)
    else root.clampTo(root.selectedIndex + dy * root.perShelf)
  }

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
    openAnim.restart()
  }
  NumberAnimation { id: openAnim; target: root; property: "open"; from: 0; to: 1; duration: 440; easing.type: Easing.InOutCubic }
  onWoke: root.open = 0

  Rectangle { anchors.fill: parent; color: root.wall; opacity: Math.min(0.98, root.backdrop) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Wallpaper, the case, its planks, and a lamp's pool of light.
  Canvas {
    anchors.fill: parent
    property var key: [root.wall, root.wood, root.perShelf, root.shelfH, root.hack]
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
        // Just the shelves: one rule per shelf, a bracket at each end.
        ctx.strokeStyle = th.rgba(root.gilt, 0.35)
        ctx.lineWidth = 1
        for (var hs = 0; hs < 3; hs++) {
          var hy = root.shelfFloor(hs) + 0.5
          ctx.beginPath()
          ctx.moveTo(root.caseX, hy - 8 * u); ctx.lineTo(root.caseX, hy)
          ctx.lineTo(root.caseX + root.caseW, hy); ctx.lineTo(root.caseX + root.caseW, hy - 8 * u)
          ctx.stroke()
          ctx.font = Math.round(10 * u) + "px monospace"
          ctx.fillStyle = th.rgba(root.gilt, 0.4)
          ctx.fillText("/shelf" + hs, root.caseX + root.caseW - 60 * u, hy + 14 * u)
        }
        return
      }
      ctx.fillStyle = th.rgba(th.mix(root.wall, root.foreground, 0.025), 1)
      for (var x = 0; x < width; x += 36 * u) ctx.fillRect(x, 0, 12 * u, height)
      var lamp = ctx.createRadialGradient(width * 0.36, 0, 0, width * 0.36, 0, height * 0.9)
      lamp.addColorStop(0, th.rgba(th.yellow, 0.14))
      lamp.addColorStop(1, th.rgba(th.yellow, 0))
      ctx.fillStyle = lamp
      ctx.fillRect(0, 0, width, height)

      var x0 = root.caseX - 22 * u, x1 = root.caseX + root.caseW + 22 * u
      var y0 = root.caseTop - 26 * u, y1 = root.caseTop + root.shelfH * 3 + 8 * u
      ctx.fillStyle = th.rgba(root.woodDark, 1)
      ctx.fillRect(x0, y0, x1 - x0, y1 - y0)
      ctx.fillStyle = th.rgba(th.mix(root.woodDark, "#000000", 0.35), 1)
      ctx.fillRect(x0 + 18 * u, y0 + 18 * u, x1 - x0 - 36 * u, y1 - y0 - 30 * u)
      for (var s = 0; s < 3; s++) {
        var py = root.shelfFloor(s)
        var g = ctx.createLinearGradient(0, py, 0, py + root.plank)
        g.addColorStop(0, th.rgba(th.mix(root.wood, "#ffffff", 0.12), 1))
        g.addColorStop(1, th.rgba(root.woodDark, 1))
        ctx.fillStyle = g
        ctx.fillRect(x0, py, x1 - x0, root.plank)
        ctx.fillStyle = "rgba(0,0,0,0.35)"
        ctx.fillRect(x0 + 18 * u, py - 6 * u, x1 - x0 - 36 * u, 6 * u)
      }
      ctx.fillStyle = th.rgba(root.wood, 1)
      ctx.fillRect(x0, y0, x1 - x0, 20 * u)
      ctx.fillRect(x0, y0, 18 * u, y1 - y0)
      ctx.fillRect(x1 - 18 * u, y0, 18 * u, y1 - y0)
    }
  }

  Text {
    x: root.caseX
    y: 40 * u
    textFormat: Text.PlainText
    text: root.hack ? "~/" + root.title.toLowerCase() : root.title
    color: root.gilt
    font.family: root.serif; font.pixelSize: 30 * u; font.italic: !root.hack; font.weight: Font.Bold
  }
  QueryText {
    x: root.caseX + 2 * u
    y: 82 * u
    width: root.caseW * 0.6
    height: 18 * u
    query: root.query
    placeholder: root.hack ? "$ find ~/" + (root.subtitle.length > 0 ? root.subtitle.toLowerCase().replace(/\s*›\s*/g, "/") : "") + " -name …" : (root.subtitle.length > 0 ? root.subtitle : "type to search the catalogue")
    color: root.foreground
    placeholderColor: root.dim
    caretColor: root.gilt
    fontFamily: root.serif
    pixelSize: 13 * u
    live: root.live
  }
  PageDots {
    x: root.caseX + root.caseW - width
    y: 88 * u
    page: root.page
    pages: root.pages
    color: root.dim
    activeColor: root.gilt
    dot: 6 * u
    fontFamily: root.serif
  }

  Repeater {
    model: root.rowModel

    delegate: Item {
      id: book

      required property int index
      required property string kind
      required property string icon
      required property string iconFont
      required property string appIcon
      required property string label

      readonly property int slot: book.index - root.pageStart
      readonly property bool onPage: slot >= 0 && slot < root.pageCount
      readonly property int shelf: Math.floor(Math.max(0, slot) / root.perShelf)
      readonly property int col: Math.max(0, slot) % root.perShelf
      readonly property bool selHere: root.cursorActive && book.index === root.selectedIndex
      readonly property color binding: root.bookColor(book.index)

      visible: book.onPage
      width: (42 + root.hash(book.index, 1) * 16) * u
      height: root.shelfH * (0.64 + root.hash(book.index, 2) * 0.26)
      x: root.caseX + 20 * u + book.col * root.slotW + (root.slotW - width) / 2
      y: root.shelfFloor(book.shelf) - height - (book.selHere ? 30 * u : 0)
      Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }
      transformOrigin: Item.Bottom
      rotation: book.selHere ? -4 : (root.hash(book.index, 3) > 0.86 ? 6 : 0)
      Behavior on rotation { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
      z: book.selHere ? 20 : 10

      Rectangle {
        anchors.fill: parent
        radius: root.hack ? 0 : 3 * u
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: root.theme ? root.theme.mix(book.binding, "#000000", 0.35) : book.binding }
          GradientStop { position: 0.45; color: root.theme ? root.theme.mix(book.binding, "#ffffff", 0.12) : book.binding }
          GradientStop { position: 1.0; color: root.theme ? root.theme.mix(book.binding, "#000000", 0.4) : book.binding }
        }
        border.color: book.selHere ? root.gilt : (root.hack ? root.hackDim : Qt.rgba(0, 0, 0, 0.35))
        border.width: book.selHere && !root.hack ? 2 : 1
      }
      // Gilt bands top and bottom.
      Repeater {
        model: root.hack ? 0 : 2
        Column {
          required property int index
          x: 4 * root.u
          y: index === 0 ? 14 * root.u : book.height - 22 * root.u
          spacing: 3 * root.u
          Rectangle { width: book.width - 8 * root.u; height: 1.5; color: Util.alpha(root.gilt, 0.8) }
          Rectangle { width: book.width - 8 * root.u; height: 1.5; color: Util.alpha(root.gilt, 0.8) }
        }
      }
      RowIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 26 * u
        size: Math.min(book.width - 14 * u, 26 * u)
        kind: book.kind
        glyph: book.icon
        glyphFont: book.iconFont
        appIcon: book.appIcon
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        load: book.onPage
        fallback: book.label.charAt(0).toUpperCase()
        color: root.gilt
      }
      // Title down the spine.
      Item {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 62 * u
        width: book.width
        height: book.height - 92 * u
        clip: true
        Text {
          anchors.centerIn: parent
          width: parent.height
          rotation: -90
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.hack ? root.perms(book.kind) + "  " + book.label.toLowerCase() : book.label
          color: root.hack ? (book.selHere ? root.hackInk : root.hackDim) : (root.theme ? root.theme.mix(root.gilt, "#ffffff", book.selHere ? 0.4 : 0) : "#fff")
          font.family: root.serif; font.pixelSize: Math.min(15 * root.u, book.width * 0.36); font.weight: Font.DemiBold; font.letterSpacing: 1
        }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hoverSelect(book.index, mapToItem(root, mouseX, mouseY))
        onPositionChanged: root.hoverSelect(book.index, mapToItem(root, mouseX, mouseY))
        onClicked: root.activated(book.index)
      }
    }
  }

  // Reading stand: the selected book's cover, swinging open on each pick.
  Item {
    id: stand
    x: root.width * 0.69
    y: root.caseTop + 10 * u
    width: Math.min(root.width * 0.26, 420 * u)
    height: Math.min(root.shelfH * 3 - 40 * u, width * 1.38)
    visible: !!root.current

    // bookshelf-hack: `stat` of the selected book in place of its cover.
    Column {
      visible: root.hack
      anchors.fill: parent
      anchors.margins: 18 * u
      spacing: 6 * u
      Text { text: "$ stat " + (root.current ? root.current.label.toLowerCase().replace(/ /g, "_") : ""); color: root.hackInk; font.family: root.mono; font.pixelSize: 14 * u; font.weight: Font.Bold; width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText }
      Item { width: 1; height: 6 * u }
      RowIcon {
        size: 48 * u
        opacity: 0.85
        kind: root.current ? root.current.kind : ""
        glyph: root.current ? root.current.icon : ""
        glyphFont: root.current ? root.current.iconFont : ""
        appIcon: root.current ? root.current.appIcon : ""
        resolver: root.iconResolver
        fontFamily: root.fontFamily
        fallback: root.current ? root.current.label.charAt(0).toUpperCase() : ""
        color: root.hackInk
      }
      Repeater {
        model: root.hack && root.current ? [
          ["File", root.current.label.toLowerCase()],
          ["Size", (parseInt(root.fakeHex(root.selectedIndex, 4), 16) % 9000 + 120) + " B"],
          ["Inode", String(parseInt(root.fakeHex(root.selectedIndex * 3, 5), 16))],
          ["Access", root.perms(root.current.kind)],
          ["Type", root.isBranch(root.current.kind) ? "directory" : (root.current.kind === "app" ? "application" : "script")],
          ["Modify", "2026-" + String(1 + parseInt(root.fakeHex(root.selectedIndex, 1), 16) % 12).padStart(2, "0") + "-" + String(1 + parseInt(root.fakeHex(root.selectedIndex + 9, 2), 16) % 28).padStart(2, "0")],
          ["Desc", root.current.detail || "-"]
        ] : []
        Row {
          required property var modelData
          Text { width: 80 * root.u; text: modelData[0] + ":"; color: root.hackDim; font.family: root.mono; font.pixelSize: 12 * root.u }
          Text { width: stand.width - 120 * root.u; elide: Text.ElideRight; textFormat: Text.PlainText; text: modelData[1]; color: root.hackText; font.family: root.mono; font.pixelSize: 12 * root.u }
        }
      }
      Rectangle { width: parent.width; height: 1; color: root.hackLine }
      Text {
        width: parent.width
        textFormat: Text.PlainText
        // `open` runs 0→1 on launch: the file scrolls past like a `cat`.
        text: root.open > 0 ? Array(Math.ceil(root.open * 12)).fill(0).map(function(_, i) { return root.fakeHex(root.selectedIndex * 16 + i, 8) + " " + root.fakeHex(i * 5 + 1, 8) }).join("\n") : ""
        color: root.hackDim
        font.family: root.mono; font.pixelSize: 11 * u
      }
    }

    // The page beneath the cover.
    Rectangle {
      visible: !root.hack
      anchors.fill: parent
      radius: 4 * u
      color: root.paper
      Column {
        anchors.centerIn: parent
        width: parent.width - 60 * u
        spacing: 10 * u
        Repeater {
          model: 9
          Rectangle { width: parent.width * (index % 3 === 2 ? 0.7 : 1); height: 2; color: Qt.rgba(0, 0, 0, 0.12) }
        }
      }
    }
    Rectangle {
      id: cover
      visible: !root.hack
      anchors.fill: parent
      radius: 4 * u
      color: root.current ? root.bookColor(root.selectedIndex) : root.wood
      border.color: root.gilt
      border.width: 2
      property real swing: 0
      transform: Rotation {
        origin.x: 0; origin.y: cover.height / 2
        axis { x: 0; y: 1; z: 0 }
        angle: -cover.swing * 70 - root.open * 110
      }
      Connections {
        target: root
        function onSelectedIndexChanged() { coverSwing.restart() }
      }
      SequentialAnimation {
        id: coverSwing
        NumberAnimation { target: cover; property: "swing"; to: 1; duration: 110; easing.type: Easing.InCubic }
        NumberAnimation { target: cover; property: "swing"; to: 0; duration: 300; easing.type: Easing.OutBack }
      }
      Rectangle {
        anchors.fill: parent; anchors.margins: 14 * u
        radius: 3 * u
        color: "transparent"
        border.color: Util.alpha(root.gilt, 0.7)
        border.width: 1.5
      }
      Column {
        anchors.centerIn: parent
        width: parent.width - 60 * u
        spacing: 16 * u
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: "VOL. " + (root.selectedIndex + 1)
          color: root.gilt
          font.family: root.serif; font.pixelSize: 12 * u; font.letterSpacing: 4
        }
        RowIcon {
          anchors.horizontalCenter: parent.horizontalCenter
          size: 96 * u
          kind: root.current ? root.current.kind : ""
          glyph: root.current ? root.current.icon : ""
          glyphFont: root.current ? root.current.iconFont : ""
          appIcon: root.current ? root.current.appIcon : ""
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          fallback: root.current ? root.current.label.charAt(0).toUpperCase() : ""
          color: root.gilt
        }
        Text {
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
          maximumLineCount: 3
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.current ? root.current.label : ""
          color: root.theme ? root.theme.mix(root.gilt, "#ffffff", 0.35) : "#fff"
          font.family: root.serif; font.pixelSize: 24 * u; font.weight: Font.Bold
        }
        Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 60 * u; height: 1.5; color: root.gilt }
        Text {
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          wrapMode: Text.Wrap
          maximumLineCount: 4
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: root.current ? (root.current.detail || (root.isBranch(root.current.kind) ? "a collected edition" : "")) : ""
          color: root.theme ? root.theme.mix(root.gilt, root.background, 0.25) : "#ccc"
          font.family: root.serif; font.pixelSize: 13 * u; font.italic: !root.hack
        }
      }
    }
  }

  Text {
    visible: root.count === 0
    x: root.caseX + 40 * u
    y: root.caseTop + root.shelfH / 2
    textFormat: Text.PlainText
    text: root.emptyText()
    color: root.dim
    font.family: root.serif; font.pixelSize: 18 * u; font.italic: !root.hack
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 26 * u
    text: root.hack ? "[arrows] ls  [^h ^l] next dir  [enter] open  [bksp] cd ..  [esc] exit" : "arrows / ^j ^k = browse  ·  ^h ^l / PgUp PgDn = next bookcase  ·  ↵ = open  ·  ⌫ = back  ·  esc = leave the library"
    color: root.dim
    font.family: root.serif; font.pixelSize: 11 * u; font.italic: !root.hack; font.letterSpacing: 1
  }
}
