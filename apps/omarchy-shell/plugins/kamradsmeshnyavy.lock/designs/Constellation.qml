import QtQuick

// Каждый введённый символ зажигает звезду и тянет к ней линию от предыдущей.
// Ошибка пароля гасит созвездие (длина пароля сбрасывается в ноль).
DesignBase {
  id: root
  field: pw

  // Детерминированные «случайные» точки: созвездие одинаковое при каждом вводе.
  function point(i) {
    var a = Math.sin(i * 12.9898 + 4.1414) * 43758.5453
    var b = Math.sin(i * 78.233 + 1.732) * 24634.6345
    return { x: 0.12 + (a - Math.floor(a)) * 0.76, y: 0.1 + (b - Math.floor(b)) * 0.5 }
  }
  readonly property int count: Math.min(passwordText.length, 40)

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.75) }

  // Фоновые тусклые звёзды.
  Repeater {
    model: 90
    delegate: Rectangle {
      required property int index
      readonly property var p: root.point(index + 500)
      x: p.x * root.width * 1.1 - root.width * 0.05
      y: (p.y * 1.9 - 0.1) * root.height
      width: 2
      height: 2
      radius: 1
      color: root.fg
      opacity: 0.15 + (index % 7) / 20
    }
  }

  // Тусклый контур созвездия, которое зажжёт пароль.
  Repeater {
    model: 11
    delegate: Rectangle {
      required property int index
      readonly property var a: root.point(index)
      readonly property var b: root.point(index + 1)
      readonly property real ax: a.x * root.width
      readonly property real ay: a.y * root.height
      readonly property real dx: b.x * root.width - ax
      readonly property real dy: b.y * root.height - ay
      x: ax
      y: ay
      width: Math.sqrt(dx * dx + dy * dy)
      height: 1
      color: root.withAlpha(root.fg, 0.1)
      transformOrigin: Item.Left
      rotation: Math.atan2(dy, dx) * 180 / Math.PI
    }
  }
  Repeater {
    model: 12
    delegate: Rectangle {
      required property int index
      readonly property var p: root.point(index)
      x: p.x * root.width - 3
      y: p.y * root.height - 3
      width: 6
      height: 6
      radius: 3
      color: root.withAlpha(root.fg, 0.3)
    }
  }

  // Линии между зажжёнными звёздами.
  Repeater {
    model: Math.max(0, root.count - 1)
    delegate: Rectangle {
      required property int index
      readonly property var a: root.point(index)
      readonly property var b: root.point(index + 1)
      readonly property real ax: a.x * root.width
      readonly property real ay: a.y * root.height
      readonly property real dx: b.x * root.width - ax
      readonly property real dy: b.y * root.height - ay
      x: ax
      y: ay
      width: Math.sqrt(dx * dx + dy * dy)
      height: 1.5
      color: root.withAlpha(root.accent, 0.55)
      transformOrigin: Item.Left
      rotation: Math.atan2(dy, dx) * 180 / Math.PI
    }
  }

  Repeater {
    model: root.count
    delegate: Rectangle {
      required property int index
      readonly property var p: root.point(index)
      x: p.x * root.width - width / 2
      y: p.y * root.height - height / 2
      width: 10
      height: 10
      radius: 5
      color: root.accent
      scale: 0
      Component.onCompleted: scale = 1
      Behavior on scale { NumberAnimation { duration: root.reduceMotion ? 0 : 260; easing.type: Easing.OutBack } }
      Rectangle {
        anchors.centerIn: parent
        width: 26
        height: 26
        radius: 13
        color: root.withAlpha(root.accent, 0.18)
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 90
    spacing: 18
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.time
      color: root.fg
      font.family: root.font
      font.pixelSize: 44
      font.weight: Font.Light
    }
    PasswordField {
      id: pw
      host: root
      fieldWidth: 360
      fieldHeight: 52
      fill: root.withAlpha(root.bg, 0.6)
    }
  }
}
