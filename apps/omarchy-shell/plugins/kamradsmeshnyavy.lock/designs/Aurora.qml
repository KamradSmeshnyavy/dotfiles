import QtQuick
import QtQuick.Effects

// Плывущее сияние: размытые пятна цветов темы медленно ходят по экрану.
DesignBase {
  id: root
  field: pw

  Rectangle { anchors.fill: parent; color: root.bg }

  Item {
    id: blobs
    anchors.fill: parent
    visible: false

    Repeater {
      model: [
        { c: root.accent, x: 0.15, y: 0.2, dx: 0.35, dy: 0.25, t: 23000 },
        { c: Qt.lighter(root.accent, 1.4), x: 0.65, y: 0.55, dx: -0.3, dy: -0.3, t: 29000 },
        { c: root.muted, x: 0.4, y: 0.75, dx: 0.25, dy: -0.4, t: 34000 },
        { c: root.fg, x: 0.8, y: 0.1, dx: -0.4, dy: 0.3, t: 41000 }
      ]
      delegate: Rectangle {
        id: blob
        required property var modelData
        width: blobs.width * 0.55
        height: width
        radius: width / 2
        color: modelData.c
        opacity: 0.55
        property real phase: 0
        x: blobs.width * (modelData.x + modelData.dx * phase) - width / 2
        y: blobs.height * (modelData.y + modelData.dy * phase) - height / 2
        SequentialAnimation on phase {
          running: !root.reduceMotion
          loops: Animation.Infinite
          NumberAnimation { from: 0; to: 1; duration: blob.modelData.t; easing.type: Easing.InOutSine }
          NumberAnimation { from: 1; to: 0; duration: blob.modelData.t; easing.type: Easing.InOutSine }
        }
      }
    }
  }

  MultiEffect {
    anchors.fill: parent
    source: blobs
    blurEnabled: true
    blur: 1
    blurMax: 128
    blurMultiplier: 2
    saturation: 0.2
  }

  Rectangle { anchors.fill: parent; color: "#000000"; opacity: 0.25 + root.wallpaperDim * 0.5 }

  Column {
    anchors.centerIn: parent
    spacing: 26
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.time
      color: root.fg
      font.family: root.font
      font.pixelSize: 100
      font.weight: Font.Light
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      visible: root.showDate
      text: root.dateText
      color: root.withAlpha(root.fg, 0.8)
      font.family: root.font
      font.pixelSize: 18
    }
    Item { width: 1; height: 10 }
    PasswordField {
      id: pw
      host: root
      anchors.horizontalCenter: parent.horizontalCenter
      fieldWidth: 360
      fieldHeight: 56
      fieldRadius: 28
      fill: root.withAlpha(root.bg, 0.5)
    }
  }
}
