import QtQuick
import qs.Commons

// "Zen" from bjarneo/omarchy-quickapps: paper, ink circles on a faint ring,
// a breathing vermillion seal, kanji numerals for the position. Upstream is
// Kanagawa Lotus; here the paper is the theme background, the ink its
// foreground, the indigo its blue and the seal its red.
SkinBase {
  id: root

  launchDelay: 0

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property color paper: root.background
  readonly property color ink: root.foreground
  readonly property color sumi: root.theme ? root.theme.muted : Util.alpha(root.foreground, 0.55)
  readonly property color indigo: root.theme ? root.theme.blue : "#4d699b"
  readonly property color seal: root.theme ? root.theme.red : "#c84053"
  readonly property string serif: "serif"

  readonly property var kanjiNum: ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
  function indexKanji(n) { return n >= 0 && n <= 10 ? root.kanjiNum[n] : String(n) }

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

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

  // One brush stroke at the top.
  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 80 * u
    width: 120 * u; height: 1; color: root.ink
  }
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 92 * u
    textFormat: Text.PlainText
    text: root.query.length > 0 ? root.query : root.title.toLowerCase()
    color: root.query.length > 0 ? root.seal : root.sumi
    font.family: root.serif; font.pixelSize: 12 * u; font.letterSpacing: 4; font.italic: root.query.length === 0
  }

  // 静, "stillness", very faint.
  Text {
    anchors.right: parent.right; anchors.rightMargin: 60 * u
    anchors.verticalCenter: parent.verticalCenter
    text: "静"
    color: Util.alpha(root.ink, 0.10)
    font.family: root.serif; font.pixelSize: 220 * u; font.weight: Font.Light
  }

  Column {
    anchors.right: parent.right; anchors.rightMargin: 60 * u
    anchors.top: parent.top; anchors.topMargin: 80 * u
    spacing: 6 * u
    visible: root.count > 0
    Text {
      anchors.right: parent.right
      text: root.indexKanji(root.selectedIndex + 1)
      color: root.seal
      font.family: root.serif; font.pixelSize: 22 * u; font.weight: Font.Light
    }
    Rectangle { anchors.right: parent.right; width: 1; height: 24 * u; color: root.sumi; opacity: 0.5 }
    Text {
      anchors.right: parent.right
      text: root.indexKanji(root.count)
      color: root.sumi
      font.family: root.serif; font.pixelSize: 14 * u; font.weight: Font.Light
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 720 * u; height: 720 * u

    Rectangle {
      anchors.centerIn: parent
      width: 460 * u; height: 460 * u; radius: 230 * u
      color: "transparent"
      border.color: Util.alpha(root.indigo, 0.18)
      border.width: 1
    }

    Column {
      anchors.centerIn: parent
      spacing: 18 * u
      width: 320 * u
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label.toLowerCase() : "—"
        color: root.ink
        font.family: root.serif; font.pixelSize: 32 * u; font.letterSpacing: 4; font.weight: Font.Light
      }
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 8 * u; height: 8 * u; radius: 4 * u
        color: root.seal
        opacity: root.current ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
        SequentialAnimation on scale {
          running: root.live && root.current !== null
          loops: Animation.Infinite
          NumberAnimation { from: 1.0; to: 1.35; duration: 2400; easing.type: Easing.InOutSine }
          NumberAnimation { from: 1.35; to: 1.0; duration: 2400; easing.type: Easing.InOutSine }
        }
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.detail : root.emptyText().toLowerCase()
        color: root.indigo
        opacity: 0.55
        font.family: root.serif; font.pixelSize: 11 * u; font.letterSpacing: 2; font.italic: true
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
        width: 72 * u; height: 96 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 230 * u
        y: stage.height / 2 - 28 * u + Math.sin(angle) * 230 * u
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }
        Behavior on y { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }
        scale: tile.focusedTile ? 1.08 : 1.0
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutQuart } }

        Rectangle {
          id: disk
          anchors.horizontalCenter: parent.horizontalCenter
          width: 56 * u; height: 56 * u; radius: 28 * u
          color: tile.focusedTile ? root.ink : "transparent"
          border.color: tile.focusedTile ? root.ink : root.sumi
          border.width: tile.focusedTile ? 0 : 1
          Behavior on color { ColorAnimation { duration: 350 } }
          Behavior on border.color { ColorAnimation { duration: 350 } }
        }
        Text {
          anchors.right: disk.right; anchors.rightMargin: -2
          anchors.top: disk.top; anchors.topMargin: -2
          visible: tile.slot < 9
          text: String(tile.slot + 1)
          color: tile.focusedTile ? root.seal : root.sumi
          opacity: tile.focusedTile ? 0.9 : 0.45
          font.family: root.serif; font.pixelSize: 10 * u; font.weight: Font.Light
        }
        RowIcon {
          anchors.centerIn: disk
          size: 28 * u
          opacity: tile.focusedTile ? 0.95 : 0.75
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0).toLowerCase()
          color: tile.focusedTile ? root.paper : root.ink
        }
        Rectangle {
          anchors.horizontalCenter: disk.horizontalCenter
          anchors.top: disk.bottom; anchors.topMargin: 8 * u
          width: 4 * u; height: 4 * u; radius: 2 * u
          color: root.seal
          opacity: tile.focusedTile ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 350 } }
        }
        Text {
          anchors.horizontalCenter: disk.horizontalCenter
          anchors.top: disk.bottom; anchors.topMargin: 18 * u
          width: 110 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label.toLowerCase()
          color: tile.focusedTile ? root.ink : root.sumi
          font.family: root.serif; font.pixelSize: 9 * u; font.letterSpacing: 1.5
          opacity: tile.focusedTile ? 1 : 0.55
          Behavior on opacity { NumberAnimation { duration: 250 } }
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

  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 60 * u
    spacing: 18 * u
    Repeater {
      model: [["← →", "navigate", false], ["↵", "open", true], ["⌫", "return", false], ["esc", "dismiss", false]]
      Row {
        required property var modelData
        required property int index
        spacing: 18 * u
        Rectangle { visible: index > 0; width: 1; height: 12 * u; color: root.sumi; opacity: 0.4; anchors.verticalCenter: parent.verticalCenter }
        Text { text: modelData[0]; color: modelData[2] ? root.seal : root.sumi; font.family: root.serif; font.pixelSize: 12 * u; font.letterSpacing: 3 }
        Text { text: modelData[1]; color: root.sumi; opacity: 0.7; font.family: root.serif; font.pixelSize: 11 * u; font.letterSpacing: 2; font.italic: true }
      }
    }
  }
}
