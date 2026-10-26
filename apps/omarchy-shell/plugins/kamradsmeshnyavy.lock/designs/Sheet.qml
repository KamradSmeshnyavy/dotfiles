import QtQuick
import QtQuick.Effects

// Матовая боковая панель справа: аватар, время, ввод.
DesignBase {
  id: root
  field: pw

  Wallpaper { id: wp; anchors.fill: parent; host: root; blur: 0 }

  Item {
    id: sheet
    anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: 24 }
    width: 420

    // Кусок обоев под панелью, размытый — «матовое стекло».
    ShaderEffectSource {
      id: glass
      anchors.fill: parent
      sourceItem: wp
      sourceRect: Qt.rect(sheet.x, sheet.y, sheet.width, sheet.height)
      visible: false
    }
    MultiEffect {
      anchors.fill: parent
      source: glass
      blurEnabled: true
      blur: 1
      blurMax: 64
      maskEnabled: true
      maskSource: shape
    }
    Rectangle { id: shape; anchors.fill: parent; radius: 28; visible: false; layer.enabled: true }

    Rectangle {
      anchors.fill: parent
      radius: 28
      color: root.withAlpha(root.bg, 0.55)
      border.width: 1
      border.color: root.withAlpha(root.fg, 0.15)
    }

    Column {
      anchors.centerIn: parent
      spacing: 18

      Avatar { host: root; size: 110; anchors.horizontalCenter: parent.horizontalCenter }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.greeting
        color: root.fg
        font.family: root.font
        font.pixelSize: 18
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.time
        color: root.fg
        font.family: root.font
        font.pixelSize: 64
        font.weight: Font.Light
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.showDate
        text: root.dateText
        color: root.withAlpha(root.fg, 0.7)
        font.family: root.font
        font.pixelSize: 16
      }
      Item { width: 1; height: 12 }
      PasswordField {
        id: pw
        host: root
        anchors.horizontalCenter: parent.horizontalCenter
        fieldWidth: 340
        fieldHeight: 54
        fieldRadius: 27
      }
    }
  }
}
