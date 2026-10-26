import QtQuick
import QtQuick.Effects

// Светящиеся неоновые часы и рамка поля цвета акцента.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.7) }

  Column {
    anchors.centerIn: parent
    spacing: 40

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.time
      color: root.accent
      font.family: root.font
      font.pixelSize: 120
      font.weight: Font.Light
      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: root.accent
        shadowBlur: 1
        shadowOpacity: 1
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
      }
    }

    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      width: pw.width
      height: pw.height

      // Ореол вокруг поля.
      Rectangle {
        anchors.fill: parent
        radius: pw.radius
        color: "transparent"
        border.width: 2
        border.color: root.accent
        layer.enabled: true
        layer.effect: MultiEffect {
          shadowEnabled: true
          shadowColor: root.accent
          shadowBlur: 1
          shadowOpacity: 1
          shadowHorizontalOffset: 0
          shadowVerticalOffset: 0
        }
      }

      PasswordField {
        id: pw
        host: root
        fieldWidth: 380
        fieldHeight: 58
        fill: root.withAlpha("#000000", 0.6)
        textColor: root.accent
      }
    }
  }
}
