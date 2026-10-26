import QtQuick

// Цифровой дождь: колонки символов падают с разной скоростью.
DesignBase {
  id: root
  field: pw

  Rectangle { anchors.fill: parent; color: "#040404" }

  readonly property string glyphs: "アイウエオカキクケコサシスセソタチツテト0123456789ABCDEF<>/*+=#"
  function column(seed, n) {
    var out = []
    var x = seed * 9301 + 49297
    for (var i = 0; i < n; i++) {
      x = (x * 9301 + 49297) % 233280
      out.push(root.glyphs.charAt(x % root.glyphs.length))
    }
    return out.join("\n")
  }

  Item {
    anchors.fill: parent
    clip: true

    Repeater {
      model: Math.ceil(root.width / 22)
      delegate: Text {
        id: drop
        required property int index
        readonly property real speed: 7000 + (index * 7919) % 9000
        x: index * 22
        width: 22
        text: root.column(index, 40)
        color: root.accent
        opacity: 0.25 + ((index * 31) % 50) / 100
        font.family: root.font
        font.pixelSize: 18
        lineHeight: 1.0
        horizontalAlignment: Text.AlignHCenter
        y: -height
        NumberAnimation on y {
          running: !root.reduceMotion
          from: -drop.height - (drop.index * 97) % 600
          to: root.height
          duration: drop.speed
          loops: Animation.Infinite
        }
      }
    }
  }

  Rectangle {
    anchors.centerIn: parent
    width: 440
    height: 190
    radius: 12
    color: Qt.rgba(0, 0, 0, 0.85)
    border.width: 1
    border.color: root.accent

    Column {
      anchors.centerIn: parent
      spacing: 18
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.time
        color: root.accent
        font.family: root.font
        font.pixelSize: 54
        font.bold: true
      }
      PasswordField {
        id: pw
        host: root
        fieldWidth: 360
        fieldHeight: 52
        fill: "#000000"
        textColor: root.accent
      }
    }
  }
}
