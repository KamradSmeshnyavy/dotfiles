import QtQuick

// Эффект слоя для пикселизации Retro на ходу (DripMotion.pixel): item.layer.effect: Pixelate { px: … }.
// Слой включают только пока px > 1 — в покое кадров и памяти не стоит.
ShaderEffect {
  property real px: 0
  readonly property size size: Qt.size(width, height)
  fragmentShader: Qt.resolvedUrl("shaders/pixelate.frag.qsb")
}
