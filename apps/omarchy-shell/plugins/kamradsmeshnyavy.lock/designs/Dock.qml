import QtQuick

// Всё в тонкой полосе внизу экрана.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; blur: Math.min(root.wallpaperBlur, 0.3) }

  Rectangle {
    id: bar
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
    height: 64
    radius: 18
    color: root.withAlpha(root.bg, 0.82)
    border.width: 1
    border.color: root.withAlpha(root.fg, 0.12)

    Text {
      anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
      text: root.time
      color: root.fg
      font.family: root.font
      font.pixelSize: 26
      font.bold: true
    }

    PasswordField {
      id: pw
      host: root
      anchors.centerIn: parent
      fieldWidth: 340
      fieldHeight: 44
      outlineThickness: 2
      fieldFontSize: 15
    }

    Text {
      anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
      visible: root.showDate
      text: root.dateText
      color: root.withAlpha(root.fg, 0.7)
      font.family: root.font
      font.pixelSize: 16
    }
  }
}
