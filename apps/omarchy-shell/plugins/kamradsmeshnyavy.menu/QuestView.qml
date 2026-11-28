import QtQuick
import Quickshell
import qs.Commons

// quest — лаунчер райса Quest (свой): меню «ПРЕДМЕТЫ» ролевой игры. Три окна-диалога (QuestWin) по центру: сверху
// поиск «▶ запрос█», посередине список до 9 строк — значок приложения пикселями (24 → 12 px без сглаживания), имя,
// описание тусклее, у выбранной — рука-курсор и золото; справа под списком — окно описания выбранного «предмета»
// и счёт «N / M». Окна раскрываются по вертикали из середины. Стрелки / Enter / колесо — как у остальных видов (SkinBase).
SkinBase {
  id: root

  QuestPal { id: qp }
  readonly property int rowH: 38
  readonly property int rows: 9

  property real t: 0
  onWoke: { t = 0; grow.restart() }
  Component.onCompleted: grow.restart()
  NumberAnimation { id: grow; target: root; property: "t"; from: 0; to: 1; duration: 260 }
  function g(i) { return Math.max(0, Math.min(1, root.t * 3 - i * 0.5)) }

  property bool blink: true
  Timer { id: blinker; interval: 500; repeat: true; running: root.live; onTriggered: root.blink = !root.blink }
  onQueryChanged: { blink = true; blinker.restart() }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  readonly property var cur: root.rowModel && root.count > 0 && root.selectedIndex >= 0 ? root.rowModel.get(root.selectedIndex) : null

  Column {
    anchors.centerIn: parent
    spacing: 8

    // ── поиск ──
    QuestWin {
      id: search
      pal: qp
      width: Math.min(720, root.width - 80); height: 58
      transform: Scale { origin.y: search.height / 2; yScale: root.g(0) }
      MouseArea { anchors.fill: parent }
      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12
        Text { anchors.verticalCenter: parent.verticalCenter; text: root.title && root.title !== "Apps" && root.title !== "Go" ? root.title.toUpperCase() : "ПРЕДМЕТЫ"; color: qp.hi; font.family: qp.font(8); font.pixelSize: qp.size(8) }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "▶"; color: qp.hi; font.family: qp.body; font.pixelSize: 18 }
        Text { anchors.verticalCenter: parent.verticalCenter; text: root.query || ""; color: qp.text; font.family: qp.body; font.pixelSize: 20 }
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 10; height: 20; color: qp.hi; opacity: root.blink ? 1 : 0; antialiasing: false }
      }
    }

    // ── список ──
    QuestWin {
      id: listWin
      pal: qp
      width: search.width; height: root.rows * root.rowH + 24
      transform: Scale { origin.y: listWin.height / 2; yScale: root.g(1) }
      MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }
      ListView {
        id: list
        anchors.fill: parent
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
          Image {
            visible: row.on
            source: qp.sprite("hand"); smooth: false
            width: 18; height: 12; x: 0
            anchors.verticalCenter: parent.verticalCenter
          }
          Image {
            id: ic
            x: 28; anchors.verticalCenter: parent.verticalCenter
            width: 24; height: 24
            sourceSize.width: 12; sourceSize.height: 12
            smooth: false
            source: row.kind === "app" && row.appIcon !== "" && root.iconResolver ? root.iconResolver(row.appIcon) : qp.sprite("potion")
          }
          Text {
            x: 64; anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.45 - 64
            elide: Text.ElideRight
            text: row.label
            color: row.on ? qp.hi : qp.text
            font.family: qp.body; font.pixelSize: 20
          }
          Text {
            x: parent.width * 0.45 + 8; anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.55 - 12
            elide: Text.ElideRight
            text: row.detail
            color: qp.dim
            font.family: qp.body; font.pixelSize: 16
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
          x: 28; height: root.rowH; verticalAlignment: Text.AlignVCenter
          text: "Такого предмета нет в сумке."
          color: qp.red
          font.family: qp.body; font.pixelSize: 18
        }
      }
    }

    // ── описание и счёт ──
    QuestWin {
      id: foot
      pal: qp
      width: search.width; height: 50
      transform: Scale { origin.y: foot.height / 2; yScale: root.g(2) }
      MouseArea { anchors.fill: parent }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - count.implicitWidth - 20
        elide: Text.ElideRight
        text: root.cur ? (root.cur.detail || root.cur.label || "") : "Выберите предмет."
        color: qp.text
        font.family: qp.body; font.pixelSize: 17
      }
      Text {
        id: count
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        text: (root.count ? root.selectedIndex + 1 : 0) + " / " + root.count
        color: qp.hi
        font.family: qp.font(8); font.pixelSize: qp.size(8)
      }
    }
  }
}
