import QtQuick

// Слева панель с часами и вводом, справа обои.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; blur: 0 }

  Rectangle {
    id: panel
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    width: parent.width * 0.38
    color: root.bg

    Rectangle {
      anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
      width: 3
      color: root.accent
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 56
      spacing: 14

      Text {
        text: root.time
        color: root.fg
        font.family: root.font
        font.pixelSize: 84
        font.bold: true
      }
      Text {
        visible: root.showDate
        text: root.dateText
        color: root.accent
        font.family: root.font
        font.pixelSize: 20
      }
      Item { width: 1; height: 36 }
      Text {
        text: root.greeting
        color: root.withAlpha(root.fg, 0.7)
        font.family: root.font
        font.pixelSize: 16
      }
      PasswordField {
        id: pw
        host: root
        fieldWidth: panel.width - 112
        fieldHeight: 54
        textAlignment: TextInput.AlignLeft
      }
    }
  }
}
