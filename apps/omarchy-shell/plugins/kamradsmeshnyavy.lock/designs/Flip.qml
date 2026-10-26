import QtQuick

// Перекидные часы: две карточки с разрезом посередине.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.2) }

  Row {
    id: cards
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: pw.top
    anchors.bottomMargin: 48
    spacing: 20

    Repeater {
      model: [root.hours, root.minutes]
      delegate: Rectangle {
        required property string modelData
        width: 200
        height: 220
        radius: 18
        color: "#151515"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        Text {
          anchors.centerIn: parent
          text: parent.modelData
          color: "#f2f2f2"
          font.family: root.font
          font.pixelSize: 150
          font.bold: true
        }
        // Разрез «перекидной» карточки.
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width
          height: 3
          color: "#000000"
        }
        Rectangle { x: -4; anchors.verticalCenter: parent.verticalCenter; width: 8; height: 22; radius: 3; color: "#2a2a2a" }
        Rectangle { x: parent.width - 4; anchors.verticalCenter: parent.verticalCenter; width: 8; height: 22; radius: 3; color: "#2a2a2a" }
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: cards.bottom
    anchors.topMargin: 10
    visible: root.showDate
    text: root.dateText
    color: root.withAlpha(root.fg, 0.8)
    font.family: root.font
    font.pixelSize: 15
    z: 1
  }

  PasswordField {
    id: pw
    host: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 170
    fieldWidth: 360
    fieldHeight: 56
  }
}
