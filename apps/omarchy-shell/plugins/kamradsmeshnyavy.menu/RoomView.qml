import QtQuick
import Quickshell
import qs.Commons

// room — лаунчер райса Cozy Room (свой): записка в линейку (RoomNote) на деревянной доске (RoomWood). Сверху
// «что достать? ▸ запрос█», ниже до 9 строк по линейке — значок приложения, имя и описание тусклее; выбранная строка
// выделена маркером цвета лампы; внизу — описание выбранного и счёт «N из M». Доска мягко выплывает снизу.
// Стрелки / Enter / колесо — как у остальных видов (SkinBase).
SkinBase {
  id: root

  RoomPal { id: rp }
  readonly property int rowH: 38
  readonly property int rows: 9

  property real t: 0
  onWoke: { t = 0; grow.restart() }
  Component.onCompleted: grow.restart()
  NumberAnimation { id: grow; target: root; property: "t"; from: 0; to: 1; duration: 320; easing.type: Easing.OutCubic }

  property bool blink: true
  Timer { id: blinker; interval: 520; repeat: true; running: root.live; onTriggered: root.blink = !root.blink }
  onQueryChanged: { blink = true; blinker.restart() }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }
  readonly property var cur: root.rowModel && root.count > 0 && root.selectedIndex >= 0 ? root.rowModel.get(root.selectedIndex) : null

  RoomWood {
    id: board
    pal: rp
    width: Math.min(760, root.width - 80); height: root.rows * root.rowH + 200
    anchors.centerIn: parent
    anchors.verticalCenterOffset: (1 - root.t) * 50
    opacity: root.t
    radius: 6
    pad: 18
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    RoomNote {
      id: paper
      pal: rp
      tilt: -0.6
      anchors.fill: parent
      pad: 18

      Row {
        id: search
        spacing: 10
        Text { text: root.title && root.title !== "Apps" && root.title !== "Go" ? root.title.toLowerCase() + " ▸" : "что достать? ▸"; color: rp.alpha(rp.paperink, 0.6); font.family: rp.font; font.pixelSize: 20 }
        Text { text: root.query || ""; color: rp.paperink; font.family: rp.font; font.pixelSize: 22; font.bold: true }
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 3; height: 22; color: rp.paperink; opacity: root.blink ? 1 : 0; antialiasing: false }
      }
      Rectangle { y: 40; width: parent.width; height: 2; color: rp.alpha(rp.red, 0.45) }

      ListView {
        id: list
        y: 50
        width: parent.width; height: root.rows * root.rowH
        interactive: false
        clip: true
        model: root.rowModel
        currentIndex: root.selectedIndex
        highlightFollowsCurrentItem: false
        boundsBehavior: Flickable.StopAtBounds
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
        delegate: Item {
          id: row
          required property int index
          required property string kind
          required property string appIcon
          required property string label
          required property string detail
          readonly property bool on: root.cursorActive && index === root.selectedIndex
          width: list.width
          height: root.rowH
          Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: rp.alpha(rp.cyan, 0.35) }
          Rectangle {   // маркер
            visible: row.on
            x: 36; anchors.verticalCenter: parent.verticalCenter
            width: Math.min(parent.width - 40, nm.implicitWidth + 16); height: 22
            color: rp.alpha(rp.lamp, 0.5); rotation: -0.8; antialiasing: false
          }
          Image {
            x: 4; anchors.verticalCenter: parent.verticalCenter
            width: 24; height: 24
            sourceSize.width: 24; sourceSize.height: 24
            source: row.kind === "app" && row.appIcon !== "" && root.iconResolver ? root.iconResolver(row.appIcon) : rp.sprite("note")
            smooth: row.kind === "app"
          }
          Text {
            id: nm
            x: 44; anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.46 - 44
            elide: Text.ElideRight
            text: row.label
            color: rp.paperink
            font.family: rp.font; font.pixelSize: 19; font.bold: row.on
          }
          Text {
            x: parent.width * 0.46 + 8; anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.54 - 12
            elide: Text.ElideRight
            text: row.detail
            color: rp.alpha(rp.paperink, 0.55)
            font.family: rp.font; font.pixelSize: 15
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
        Text {
          visible: root.count === 0 && root.query !== ""
          x: 44; height: root.rowH; verticalAlignment: Text.AlignVCenter
          text: "Такого в комнате нет."
          color: rp.red
          font.family: rp.font; font.pixelSize: 18; font.italic: true
        }
      }
      Text {
        anchors.bottom: parent.bottom
        width: parent.width - cnt.implicitWidth - 20
        elide: Text.ElideRight
        text: root.cur ? (root.cur.detail || root.cur.label || "") : ""
        color: rp.alpha(rp.paperink, 0.7)
        font.family: rp.font; font.pixelSize: 16; font.italic: true
      }
      Text {
        id: cnt
        anchors.right: parent.right; anchors.bottom: parent.bottom
        text: (root.count ? root.selectedIndex + 1 : 0) + " из " + root.count
        color: rp.alpha(rp.paperink, 0.6)
        font.family: rp.mono; font.pixelSize: 14
      }
    }
  }
}
