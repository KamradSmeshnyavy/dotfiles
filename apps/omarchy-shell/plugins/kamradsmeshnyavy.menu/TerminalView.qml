import QtQuick
import Quickshell
import qs.Commons

// The same menu, dressed as a CRT in the active theme's colours: scanlines, a
// drifting refresh band, a blinking block cursor and a power-on snap.
Item {
  id: root

  property var rowModel: null
  property var iconResolver: null
  property int selectedIndex: 0
  property bool cursorActive: true
  property string title: ""
  property string subtitle: ""
  property string query: ""
  property bool burst: true
  property real backdrop: 0.94
  property color foreground: "#cacccc"
  property color accent: "#41f38c"
  property color background: "#04100a"

  readonly property int count: root.rowModel ? root.rowModel.count : 0
  readonly property string hostLabel: Quickshell.env("USER") + "@" + "omarchy"
  readonly property string promptPath: root.subtitle.length > 0
    ? ("~/" + root.subtitle.replace(/\s*›\s*/g, "/").toLowerCase())
    : "~"

  // The CRT is tinted by the active Omarchy theme rather than a fixed green,
  // so it belongs to whatever palette the desktop is wearing.
  readonly property color phosphor: root.accent
  readonly property color phosphorDim: Util.alpha(root.foreground, 0.55)
  readonly property color deep: root.background
  // Text laid over the accent bar. A light accent needs dark text on it and a
  // dark accent needs light text, and themes ship both.
  readonly property color inverse: (0.299 * root.accent.r + 0.587 * root.accent.g + 0.114 * root.accent.b) > 0.5
    ? root.background
    : root.foreground
  readonly property string mono: Style.font.family

  signal activated(int index)
  signal selectRequested(int index)

  function revealSelected() {
    if (root.count === 0) return
    list.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  onSelectedIndexChanged: revealSelected()
  onVisibleChanged: if (visible) powerOn.restart()

  Rectangle {
    anchors.fill: parent
    color: Util.alpha(root.deep, Math.min(0.99, root.backdrop + 0.04))
  }

  Item {
    id: crt

    anchors.fill: parent
    property real openPhase: 1
    opacity: Math.min(1, crt.openPhase * 2)
    transform: Scale {
      origin.x: crt.width / 2
      origin.y: crt.height / 2
      yScale: 0.04 + 0.96 * crt.openPhase
      xScale: 0.6 + 0.4 * Math.min(1, crt.openPhase * 3)
    }

    SequentialAnimation {
      id: powerOn
      NumberAnimation { target: crt; property: "openPhase"; from: 0; to: 1; duration: 260; easing.type: Easing.OutQuart }
    }

    Column {
      id: content

      anchors.fill: parent
      anchors.leftMargin: Style.space(42)
      anchors.rightMargin: Style.space(42)
      anchors.topMargin: Style.space(30)
      anchors.bottomMargin: Style.space(22)
      spacing: Style.space(10)

      Row {
        width: parent.width
        spacing: 0

        Text {
          textFormat: Text.PlainText
          text: root.hostLabel
          color: root.phosphor
          font.family: root.mono
          font.pixelSize: Style.font.heading
          font.bold: true
        }

        Text {
          textFormat: Text.PlainText
          text: ":" + root.promptPath + "$ "
          color: root.phosphorDim
          font.family: root.mono
          font.pixelSize: Style.font.heading
        }

        Text {
          textFormat: Text.PlainText
          text: root.query
          color: root.phosphor
          font.family: root.mono
          font.pixelSize: Style.font.heading
        }

        Rectangle {
          width: Style.space(10)
          height: Style.font.heading
          color: root.phosphor
          SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: root.visible
            NumberAnimation { to: 1; duration: 60 }
            PauseAnimation { duration: 480 }
            NumberAnimation { to: 0; duration: 60 }
            PauseAnimation { duration: 400 }
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        width: parent.width
        elide: Text.ElideRight
        text: "── " + root.title.toUpperCase() + " " + "─".repeat(220)
        color: root.phosphorDim
        opacity: 0.6
        font.family: root.mono
        font.pixelSize: Style.font.bodySmall
      }

      ListView {
        id: list

        width: parent.width
        height: parent.height - y - Style.space(30)
        model: root.rowModel
        clip: true
        spacing: Style.space(1)
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
          id: line

          required property int index
          required property string kind
          required property string icon
          required property string iconFont
          required property string appIcon
          required property string label
          required property string detail

          readonly property bool isApp: line.kind === "app"
          readonly property bool isActive: root.cursorActive && line.index === root.selectedIndex

          width: ListView.view.width
          height: Math.round(Style.font.body * 1.9)
          color: line.isActive ? Util.alpha(root.accent, 0.9) : "transparent"

          // Rows type themselves in, one shortly after the other.
          opacity: 0
          x: root.burst ? Style.space(-14) : 0
          SequentialAnimation {
            running: true
            PauseAnimation { duration: root.burst ? Math.max(0, Math.min(line.index * 14, 420)) : 0 }
            ParallelAnimation {
              NumberAnimation { target: line; property: "opacity"; to: 1; duration: root.burst ? 160 : 90 }
              NumberAnimation { target: line; property: "x"; to: 0; duration: 220; easing.type: Easing.OutCubic }
            }
          }

          Text {
            id: caret
            anchors.left: parent.left
            anchors.leftMargin: Style.space(4)
            anchors.verticalCenter: parent.verticalCenter
            text: line.isActive ? "▸" : " "
            color: line.isActive ? root.inverse : root.phosphorDim
            font.family: root.mono
            font.pixelSize: Style.font.body
          }

          Text {
            id: ordinal
            anchors.left: caret.right
            anchors.leftMargin: Style.space(8)
            anchors.verticalCenter: parent.verticalCenter
            text: (line.index + 1 < 10 ? "0" : "") + (line.index + 1)
            color: line.isActive ? root.inverse : root.phosphorDim
            opacity: line.isActive ? 0.8 : 0.75
            font.family: root.mono
            font.pixelSize: Style.font.bodySmall
          }

          Image {
            id: appIconImage
            visible: line.isApp
            anchors.left: ordinal.right
            anchors.leftMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            width: Style.font.body
            height: width
            fillMode: Image.PreserveAspectFit
            sourceSize.width: width * Screen.devicePixelRatio
            sourceSize.height: height * Screen.devicePixelRatio
            source: line.isApp && root.iconResolver ? root.iconResolver(line.appIcon) : ""
            asynchronous: false
          }

          Text {
            id: glyph
            visible: !line.isApp
            anchors.left: ordinal.right
            anchors.leftMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            width: Style.font.body
            horizontalAlignment: Text.AlignHCenter
            text: line.icon
            color: line.isActive ? root.inverse : root.accent
            font.family: line.iconFont.length > 0 ? line.iconFont : root.mono
            font.pixelSize: Style.font.body
          }

          Text {
            textFormat: Text.PlainText
            anchors.left: glyph.right
            anchors.leftMargin: Style.space(12)
            anchors.right: trailing.left
            anchors.rightMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            text: line.label
            elide: Text.ElideRight
            color: line.isActive ? root.inverse : root.foreground
            font.family: root.mono
            font.pixelSize: Style.font.body
            font.bold: line.isActive
          }

          Text {
            id: trailing
            textFormat: Text.PlainText
            anchors.right: parent.right
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, parent.width * 0.32)
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideLeft
            text: line.kind === "menu" || line.kind === "link" ? "▸ dir" : line.detail
            color: line.isActive ? root.inverse : root.phosphorDim
            opacity: 0.85
            font.family: root.mono
            font.pixelSize: Style.font.bodySmall
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.selectRequested(line.index)
            onClicked: root.activated(line.index)
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        width: parent.width
        elide: Text.ElideRight
        text: (root.count === 0
          ? (root.query.length > 0 ? "no matches for “" + root.query + "”" : "empty")
          : (root.count + (root.count === 1 ? " entry" : " entries")))
          + "   ·   ↑↓ select   ⏎ run   ⌫ back   esc quit"
        color: root.phosphorDim
        font.family: root.mono
        font.pixelSize: Style.font.bodySmall
      }
    }
  }

  // Scanlines. Painted once per resize rather than stacked as hundreds of
  // rectangles the scene graph would have to keep alive.
  Canvas {
    id: scanlines
    anchors.fill: parent
    opacity: 0.5

    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.fillStyle = Qt.rgba(0, 0, 0, 0.5)
      for (var y = 0; y < height; y += 3) ctx.fillRect(0, y, width, 1.4)
    }
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
  }

  Rectangle {
    id: band
    width: parent.width
    height: Style.space(140)
    opacity: 0.05
    gradient: Gradient {
      GradientStop { position: 0; color: "transparent" }
      GradientStop { position: 0.5; color: root.phosphor }
      GradientStop { position: 1; color: "transparent" }
    }

    NumberAnimation on y {
      running: root.visible
      loops: Animation.Infinite
      from: -band.height
      to: root.height
      duration: 7000
    }
  }

  Rectangle {
    anchors.fill: parent
    color: root.phosphor
    opacity: 0.012
    SequentialAnimation on opacity {
      loops: Animation.Infinite
      running: root.visible
      NumberAnimation { to: 0.03; duration: 90 }
      NumberAnimation { to: 0.008; duration: 140 }
      NumberAnimation { to: 0.02; duration: 60 }
      PauseAnimation { duration: 900 }
    }
  }

  // Vignette: the tube is brightest in the middle.
  Rectangle {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: Style.space(90)
    gradient: Gradient {
      GradientStop { position: 0; color: Util.alpha(root.deep, 0.85) }
      GradientStop { position: 1; color: "transparent" }
    }
  }

  Rectangle {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: Style.space(90)
    gradient: Gradient {
      GradientStop { position: 0; color: "transparent" }
      GradientStop { position: 1; color: Util.alpha(root.deep, 0.85) }
    }
  }
}
