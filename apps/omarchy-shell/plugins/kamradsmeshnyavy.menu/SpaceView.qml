import QtQuick
import Quickshell
import qs.Commons

// space — лаунчер по мотивам стиля Space из elifouts/Dotfiles (GPL-3.0 — его Space/launcher/Launcher.qml, облик со
// скриншота space/launcher.png; код свой): «маленький терминал под баром». Окно 620 px сверху по центру, фон темы на
// 82 %, полоса 3 px акцентом слева, над окном — «SPACE» вразрядку; строка «~/run $ запрос█», ниже 7 строк
// «N  Имя // описание» JetBrains Mono, выбранная — светлой подложкой и «›» вместо номера. Колесо, стрелки, Enter — как
// у остальных видов (SkinBase).
SkinBase {
  id: root

  readonly property string mono: Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.fontFamily
  readonly property int rowH: 25
  readonly property int rows: 7
  function a(c, k) { return Qt.rgba(c.r, c.g, c.b, k) }

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Text {
    anchors.horizontalCenter: win.horizontalCenter
    anchors.bottom: win.top
    anchors.bottomMargin: -4
    opacity: root.t
    text: "SPACE"
    color: root.a(root.accent, 0.8)
    font { family: root.mono; pixelSize: 18; letterSpacing: 2; weight: Font.Medium }
  }

  Rectangle {
    id: win
    anchors.horizontalCenter: parent.horizontalCenter
    y: 46 - 10 * (1 - root.t)
    opacity: root.t
    width: 620
    height: 18 + 26 + root.rows * root.rowH + 16
    color: root.a(root.background, 0.82)
    border.width: 1
    border.color: root.a(root.accent, 0.3)
    clip: true
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }
    Rectangle { width: 3; height: parent.height; color: root.accent }

    // приглашение
    Row {
      x: 18; y: 14
      spacing: 8
      Text { text: "~/run $"; color: root.a(root.foreground, 0.55); font { family: root.mono; pixelSize: 13 } }
      Text { textFormat: Text.PlainText; text: root.query; color: root.foreground; font { family: root.mono; pixelSize: 14; weight: Font.Medium } }
      Rectangle {
        width: 8; height: 16
        anchors.verticalCenter: parent.verticalCenter
        color: root.foreground
        opacity: blink.on ? 0.85 : 0
        QtObject { id: blink; property bool on: true }
        Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
      }
    }

    ListView {
      id: list
      x: 18; y: 18 + 26
      width: parent.width - 36
      height: root.rows * root.rowH
      clip: true
      model: root.rowModel
      currentIndex: root.selectedIndex
      highlightFollowsCurrentItem: false
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
      delegate: Rectangle {
        id: row
        required property int index
        required property string label
        required property string detail
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: list.width
        height: root.rowH
        color: on ? root.a(root.foreground, 0.1) : "transparent"
        Row {
          x: 8
          anchors.verticalCenter: parent.verticalCenter
          spacing: 10
          Text {
            width: 12
            text: row.on ? "›" : String(row.index + 1)
            color: row.on ? root.foreground : root.a(root.foreground, 0.4)
            font { family: root.mono; pixelSize: 12 }
          }
          Text {
            textFormat: Text.PlainText
            text: row.label
            color: root.foreground
            font { family: root.mono; pixelSize: 13; weight: row.on ? Font.Medium : Font.Normal }
          }
          Text {
            visible: row.detail.length > 0
            textFormat: Text.PlainText
            text: "// " + row.detail
            elide: Text.ElideRight
            width: Math.max(0, list.width - 40 - x)
            color: root.a(root.foreground, 0.5)
            font { family: root.mono; pixelSize: 13 }
          }
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
      color: Util.alpha(root.foreground, 0.5)
      font { family: root.mono; pixelSize: 13 }
    }
  }
}
