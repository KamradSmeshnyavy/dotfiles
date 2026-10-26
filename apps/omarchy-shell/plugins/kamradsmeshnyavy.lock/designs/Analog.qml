import QtQuick

// Стрелочные часы над полем.
DesignBase {
  id: root
  field: pw

  // Стрелка: прямоугольник от центра вверх, повёрнутый вокруг центра.
  component Hand: Item {
    property real angle: 0
    property real length: 100
    property real thickness: 4
    property color tint: "white"
    anchors.fill: parent
    rotation: angle
    Rectangle {
      x: (parent.width - width) / 2
      y: parent.height / 2 - parent.length
      width: parent.thickness
      height: parent.length + 14
      radius: width / 2
      color: parent.tint
      antialiasing: true
    }
  }


  Wallpaper { anchors.fill: parent; host: root }

  Item {
    id: dial
    width: 320
    height: 320
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: pw.top
    anchors.bottomMargin: 50

    readonly property real h: root.now.getHours() % 12 + root.now.getMinutes() / 60
    readonly property real m: root.now.getMinutes() + root.now.getSeconds() / 60
    readonly property real s: root.now.getSeconds()

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: root.withAlpha(root.bg, 0.75)
      border.width: 2
      border.color: root.withAlpha(root.fg, 0.25)
    }

    // Деления: часовые длинные, минутные — точки.
    Repeater {
      model: 60
      delegate: Item {
        required property int index
        anchors.fill: parent
        rotation: index * 6
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          y: 10
          width: parent.index % 5 === 0 ? 4 : 2
          height: parent.index % 5 === 0 ? 18 : 6
          radius: 2
          color: parent.index % 5 === 0 ? root.fg : root.withAlpha(root.fg, 0.4)
        }
      }
    }

    Hand { angle: dial.h * 30; length: 85; thickness: 7; tint: root.fg }
    Hand { angle: dial.m * 6; length: 125; thickness: 5; tint: root.fg }
    Hand { visible: !root.reduceMotion; angle: dial.s * 6; length: 135; thickness: 2; tint: root.accent }

    Rectangle {
      anchors.centerIn: parent
      width: 14
      height: 14
      radius: 7
      color: root.accent
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: pw.bottom
    anchors.topMargin: 18
    visible: root.showDate
    text: root.dateText
    color: root.withAlpha(root.fg, 0.75)
    font.family: root.font
    font.pixelSize: 16
  }

  PasswordField {
    id: pw
    host: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 150
    fieldWidth: 340
    fieldHeight: 56
  }
}
