import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// cozytile — лаунчер по мотивам rofi-лаунчера Cozytile (Darkkal44; лицензии нет — только облик, код свой): карточка 400 px
// по центру. Сверху — шапка-картинка (у него — кусок обоев launcher.png, здесь — текущие обои) с квадратиком-значком и
// полем «Search» цвета фона со скруглением 7; ниже — 5 строк без значков, выбранная залита цветом выбора темы (magenta
// в colors.toml — его selected), текст на ней — цветом фона.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color ink: root.foreground
  property color selected: root.accent
  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
    printErrors: false
    onLoaded: { var m = String(text()).match(/^\s*magenta\s*=\s*"(#[0-9a-fA-F]{6})"/m); if (m) root.selected = m[1] }
  }
  readonly property string mono: Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.fontFamily
  readonly property int rowH: Math.round(44 * k)

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: win
    anchors.centerIn: parent
    opacity: root.t
    scale: 0.97 + 0.03 * root.t
    width: Math.round(400 * k)
    height: head.height + list.height + 40 * k
    color: root.background
    clip: true
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    Item {
      id: head
      width: parent.width
      height: Math.round(150 * k)
      clip: true
      Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.local/state/omarchy/current/background"
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: 800
        asynchronous: true
        cache: false
      }
      Row {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 40 * k; rightMargin: 40 * k }
        spacing: 10 * k
        Rectangle {
          width: 42 * k; height: 40 * k; radius: 7 * k
          color: root.background
          Text { anchors.centerIn: parent; text: ""; color: root.ink; font { family: root.mono; pixelSize: 14 * k } }
        }
        Rectangle {
          width: parent.width - 52 * k; height: 40 * k; radius: 7 * k
          color: root.background
          Row {
            x: 16 * k; anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            Text {
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: root.query.length ? root.query : "Search"
              color: root.ink
              opacity: root.query.length ? 1 : 0.85
              font { family: root.mono; pixelSize: 13 * k }
            }
            Rectangle {
              visible: root.query.length > 0
              anchors.verticalCenter: parent.verticalCenter
              width: 2 * k; height: 16 * k; color: root.ink
              opacity: blink.on ? 1 : 0
              QtObject { id: blink; property bool on: true }
              Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
            }
          }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: head.bottom; margins: 20 * k }
      height: Math.min(5, Math.max(1, root.count)) * root.rowH + Math.max(0, Math.min(5, root.count) - 1) * spacing
      clip: true
      spacing: 10 * k
      model: root.rowModel
      currentIndex: root.selectedIndex
      highlightFollowsCurrentItem: false
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
      delegate: Rectangle {
        id: row
        required property int index
        required property string label
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: list.width
        height: root.rowH
        radius: 7 * root.k
        color: on ? root.selected : area.containsMouse ? Util.alpha(root.ink, 0.07) : "transparent"
        Text {
          anchors { left: parent.left; leftMargin: 12 * root.k; right: parent.right; rightMargin: 12 * root.k; verticalCenter: parent.verticalCenter }
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: row.label
          color: row.on ? root.background : root.ink
          font { family: root.mono; pixelSize: 13 * root.k }
        }
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onPositionChanged: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onClicked: root.activated(row.index)
        }
      }
    }
    Text {
      visible: root.count === 0
      anchors.centerIn: list
      text: root.emptyText()
      color: Util.alpha(root.ink, 0.5)
      font { family: root.mono; pixelSize: 12 * k }
    }
  }
}
