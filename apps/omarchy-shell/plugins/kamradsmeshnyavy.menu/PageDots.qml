import QtQuick

// One dot per page, the current one stretched into a pill. Hidden when there
// is only one page. Long menus (a hundred apps on a 12-slot ring) would draw a
// dotted line, so past maxDots it falls back to "3 / 12".
Item {
  id: root

  property int page: 0
  property int pages: 1
  property color color: "white"
  property color activeColor: "white"
  property real dot: 6
  property int maxDots: 14
  property string fontFamily: ""

  visible: root.pages > 1
  implicitWidth: root.pages > root.maxDots ? label.implicitWidth : row.implicitWidth
  implicitHeight: Math.max(root.dot, label.implicitHeight)

  Row {
    id: row
    anchors.centerIn: parent
    visible: root.pages <= root.maxDots
    spacing: root.dot
    Repeater {
      model: root.pages <= root.maxDots ? root.pages : 0
      Rectangle {
        required property int index
        anchors.verticalCenter: parent.verticalCenter
        height: root.dot
        width: index === root.page ? root.dot * 3 : root.dot
        radius: root.dot / 2
        color: index === root.page ? root.activeColor : root.color
        opacity: index === root.page ? 1 : 0.45
        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
      }
    }
  }

  Text {
    id: label
    anchors.centerIn: parent
    visible: root.pages > root.maxDots
    text: (root.page + 1) + " / " + root.pages
    color: root.activeColor
    font.family: root.fontFamily
    font.pixelSize: root.dot * 2
  }
}
