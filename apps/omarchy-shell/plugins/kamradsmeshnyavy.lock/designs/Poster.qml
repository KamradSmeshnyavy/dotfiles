import QtQuick

// Огромные часы плакатом: часы над минутами, поле в углу.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.35) }

  Column {
    anchors { left: parent.left; leftMargin: 70; verticalCenter: parent.verticalCenter; verticalCenterOffset: -40 }
    spacing: -60

    Text {
      text: root.hours
      color: root.fg
      font.family: root.font
      font.pixelSize: 260
      font.bold: true
    }
    Text {
      text: root.minutes
      color: root.accent
      font.family: root.font
      font.pixelSize: 260
      font.bold: true
    }
  }

  Text {
    anchors { left: parent.left; leftMargin: 78; bottom: pw.top; bottomMargin: 18 }
    visible: root.showDate
    text: root.dateText.toUpperCase()
    color: root.withAlpha(root.fg, 0.75)
    font.family: root.font
    font.pixelSize: 18
    font.letterSpacing: 4
  }

  PasswordField {
    id: pw
    host: root
    anchors { left: parent.left; leftMargin: 70; bottom: parent.bottom; bottomMargin: 70 }
    fieldWidth: 380
    fieldHeight: 56
    textAlignment: TextInput.AlignLeft
  }
}
