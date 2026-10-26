import QtQuick

// Карточка-приветствие с аватаром и именем.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root }

  Rectangle {
    anchors.centerIn: parent
    width: 460
    height: column.implicitHeight + 80
    radius: 24
    color: root.withAlpha(root.bg, 0.88)
    border.width: 1
    border.color: root.withAlpha(root.accent, 0.5)

    Column {
      id: column
      anchors.centerIn: parent
      spacing: 16

      Avatar { host: root; size: 96; anchors.horizontalCenter: parent.horizontalCenter }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.greeting
        color: root.fg
        font.family: root.font
        font.pixelSize: 24
        font.bold: true
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.time + (root.showDate ? "  ·  " + root.dateText : "")
        color: root.withAlpha(root.fg, 0.65)
        font.family: root.font
        font.pixelSize: 15
      }
      Item { width: 1; height: 6 }
      PasswordField {
        id: pw
        host: root
        anchors.horizontalCenter: parent.horizontalCenter
        fieldWidth: 360
        fieldHeight: 54
      }
    }
  }
}
