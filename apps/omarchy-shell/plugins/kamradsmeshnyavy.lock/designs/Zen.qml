import QtQuick

// Без поля: просто печатайте — точки появляются по центру.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.25) }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: pw.top
    anchors.bottomMargin: 40
    text: root.time
    color: root.fg
    opacity: 0.85
    font.family: root.font
    font.pixelSize: 54
    font.weight: Font.Light
  }

  PasswordField {
    id: pw
    host: root
    anchors.centerIn: parent
    bare: true
    fieldWidth: 600
    placeholderText: "просто печатайте"
    placeholderColor: root.withAlpha(root.fg, 0.35)
    dotFontSize: 30
  }
}
