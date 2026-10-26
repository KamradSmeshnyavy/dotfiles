import QtQuick

// Капсула сверху: время, дата и ввод в одном острове.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; blur: Math.min(root.wallpaperBlur, 0.4) }

  Rectangle {
    id: island
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 18
    width: row.implicitWidth + 28
    height: 60
    radius: height / 2
    color: "#000000"
    border.width: 1
    border.color: root.withAlpha(root.fg, 0.12)

    Row {
      id: row
      anchors.centerIn: parent
      spacing: 18
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.time
        color: "#ffffff"
        font.family: root.font
        font.pixelSize: 22
        font.bold: true
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.showDate
        text: root.dateText
        color: Qt.rgba(1, 1, 1, 0.6)
        font.family: root.font
        font.pixelSize: 14
      }
      PasswordField {
        id: pw
        host: root
        anchors.verticalCenter: parent.verticalCenter
        fieldWidth: 280
        fieldHeight: 42
        fieldRadius: 21
        outlineThickness: 2
        fieldFontSize: 14
        fill: "#161616"
        textColor: "#ffffff"
      }
    }
  }
}
