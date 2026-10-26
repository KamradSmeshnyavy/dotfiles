import QtQuick

// Журнальная вёрстка: дата заголовком, тонкие линии, поле — подчёркиванием.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.55) }

  Column {
    anchors.centerIn: parent
    width: 760
    spacing: 18

    Rectangle { width: parent.width; height: 1; color: root.withAlpha(root.fg, 0.5) }
    Text {
      width: parent.width
      text: Qt.locale().toString(root.now, "dddd").toUpperCase()
      color: root.accent
      font.family: "serif"
      font.pixelSize: 18
      font.letterSpacing: 6
    }
    Text {
      width: parent.width
      text: Qt.locale().toString(root.now, "d MMMM yyyy")
      color: root.fg
      font.family: "serif"
      font.pixelSize: 72
      font.italic: true
    }
    Rectangle { width: parent.width; height: 1; color: root.withAlpha(root.fg, 0.5) }
    Row {
      width: parent.width
      spacing: 24
      Text {
        text: root.time
        color: root.fg
        font.family: "serif"
        font.pixelSize: 40
      }
      Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        text: "— " + root.greeting
        color: root.withAlpha(root.fg, 0.7)
        font.family: "serif"
        font.pixelSize: 18
        font.italic: true
      }
    }
    Item { width: 1; height: 20 }
    PasswordField {
      id: pw
      host: root
      bare: true
      fieldWidth: 420
      fieldHeight: 48
      textAlignment: TextInput.AlignLeft
      fontFamily: "serif"
      placeholderText: "пароль"
      Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 2
        color: pw.errorState ? "#e06c75" : root.accent
      }
    }
  }
}
