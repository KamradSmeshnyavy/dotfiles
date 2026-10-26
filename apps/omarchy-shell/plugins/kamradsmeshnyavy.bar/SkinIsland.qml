import QtQuick

// Остров под одной секцией бара в форме islands. Занимает границы `target`
// плюс отступ скина; пустая секция острова не рисует.
Rectangle {
  id: island

  required property var skin
  required property Item target
  required property bool vertical
  property bool transparent: false
  // Явные границы (центр с якорем собирается из нескольких списков).
  property real spanStart: target ? (vertical ? target.y : target.x) : 0
  property real spanEnd: target ? (vertical ? target.y + target.height : target.x + target.width) : 0

  readonly property int pad: Math.max(skin.islandGap, 6)
  // Форма окна, в котором остров (compact может её сменить).
  readonly property Item host: {
    var p = parent
    while (p && p.skinHost !== true) p = p.parent
    return p || null
  }
  readonly property string shape: host ? host.skinShape : skin.shape

  visible: shape === "islands" && target !== null && target.visible && spanEnd - spanStart > 0
  z: -1

  x: vertical ? 0 : spanStart - pad
  y: vertical ? spanStart - pad : 0
  width: vertical ? parent.width : spanEnd - spanStart + 2 * pad
  height: vertical ? spanEnd - spanStart + 2 * pad : parent.height

  radius: skin.radiusFor(vertical ? width : height, "islands")
  color: transparent ? "transparent" : skin.backgroundColor
  border.width: skin.borderWidth
  border.color: skin.borderColor

  gradient: skin.hasGradient && !transparent ? islandGradient : null
  Gradient {
    id: islandGradient
    orientation: island.vertical ? Gradient.Vertical : Gradient.Horizontal
    GradientStop { position: 0; color: island.skin.backgroundColor }
    GradientStop { position: 1; color: island.skin.gradientColor }
  }
}
