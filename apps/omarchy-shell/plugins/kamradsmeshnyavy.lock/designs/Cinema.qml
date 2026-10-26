import QtQuick

// Кинематографичные чёрные полосы: титр сверху, ввод — «субтитром» снизу.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; blur: 0; dim: root.wallpaperDim }

  Rectangle {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    height: parent.height * 0.14
    color: "#000000"
    Text {
      anchors.centerIn: parent
      text: root.time + (root.showDate ? "   ·   " + root.dateText.toUpperCase() : "")
      color: "#ffffff"
      font.family: root.font
      font.pixelSize: 20
      font.letterSpacing: 5
    }
  }

  Rectangle {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
    height: parent.height * 0.14
    color: "#000000"
    PasswordField {
      id: pw
      host: root
      anchors.centerIn: parent
      bare: true
      fieldWidth: 520
      fieldHeight: 50
      textColor: "#ffffff"
      placeholderColor: Qt.rgba(1, 1, 1, 0.45)
      placeholderText: "[ введите пароль ]"
      fontFamily: "serif"
    }
  }
}
