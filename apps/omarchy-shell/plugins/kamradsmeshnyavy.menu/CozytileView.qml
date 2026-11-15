import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// cozytile — лаунчер по мотивам rofi-лаунчера Cozytile (Darkkal44, rofi/settings/launcher/*.rasi; лицензии нет — только
// облик, код свой), размеры — как в его rasi, в логических px: окно 400 px без скругления цвета фона темы; сверху —
// картинка во всю ширину (у него — кусок обоев launcher.png, здесь — текущие обои) с отступами 100 / 40, на ней квадрат
// со значком поиска и поле «Search» (отступы 12 / 15–16, скругление 7, цвет фона); ниже — отступ 20 и 5 строк
// (отступ 12, зазор 10, скругление 7) шрифтом JetBrains Mono 11; выбранная строка — цвет выбора темы (magenta в
// colors.toml — его selected), текст на ней — цветом фона.
SkinBase {
  id: root

  readonly property color ink: root.foreground
  property color selected: root.accent
  FileView {
    id: tomlFile
    path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
    printErrors: false
    onLoaded: { var m = String(text()).match(/^\s*magenta\s*=\s*"(#[0-9a-fA-F]{6})"/m); if (m) root.selected = m[1] }
  }
  readonly property string mono: Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.fontFamily
  readonly property int fontPx: 15                    // JetBrains Mono 11 pt
  readonly property int rowH: 12 * 2 + 18

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1; tomlFile.reload() }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: win
    anchors.centerIn: parent
    opacity: root.t
    width: 400
    height: head.height + 20 + list.height + 20
    color: root.background
    clip: true
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // inputbar: картинка, отступы 100 / 40
    Item {
      id: head
      width: parent.width
      height: 100 + 42 + 100
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
        x: 40; y: 100
        spacing: 10
        Rectangle {
          width: glass.implicitWidth + 30; height: 42; radius: 7
          color: root.background
          Text { id: glass; anchors.centerIn: parent; text: ""; color: root.ink; font { family: root.mono; pixelSize: root.fontPx } }
        }
        Rectangle {
          width: 400 - 80 - 10 - (glass.implicitWidth + 30); height: 42; radius: 7
          color: root.background
          Row {
            x: 16; anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            Text {
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: root.query.length ? root.query : "Search"
              color: root.ink
              font { family: root.mono; pixelSize: root.fontPx }
            }
            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 2; height: 17; color: root.ink
              opacity: blink.on ? 1 : 0
              QtObject { id: blink; property bool on: true }
              Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
            }
          }
        }
      }
    }

    // listview: 5 строк
    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: head.bottom; margins: 20 }
      height: 5 * root.rowH + 4 * spacing
      clip: true
      spacing: 10
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
        radius: 7
        color: on ? root.selected : "transparent"
        Text {
          anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: row.label
          color: row.on ? root.background : root.ink
          font { family: root.mono; pixelSize: root.fontPx }
        }
        MouseArea {
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
      font { family: root.mono; pixelSize: 13 }
    }
  }
}
