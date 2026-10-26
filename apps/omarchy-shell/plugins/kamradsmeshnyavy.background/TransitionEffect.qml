import QtQuick

// fx: переход между двумя кадрами обоев (shaders/transition.frag). Используют
// Background.qml и превью Wallpaper FX в Customizer. fromItem / toItem — любые
// Item (обычно Image с PreserveAspectCrop): их отрисовка снимается в текстуры,
// поэтому обрезка под экран уже учтена.
ShaderEffect {
  id: fx

  property Item fromItem: null
  property Item toItem: null
  property string effect: "fade"
  property real progress: 0
  property real angleDegrees: 0
  property real softness: 0.02
  property real seed: Math.random()
  property point origin: Qt.point(0.5, 0.5)
  // Прятать исходные кадры, пока эффект их показывает.
  property bool hideSources: visible

  // Имена эффектов → номер в шейдере. none и random решает тот, кто запускает переход.
  readonly property var modes: ({
    "fade": 1, "slant": 2, "wipe": 3, "wave": 4, "grow": 5, "outer": 6, "diamond": 7, "clock": 8,
    "blinds": 9, "doors": 10, "mosaic": 11, "dissolve": 12, "pixelize": 13, "ripple": 14, "swirl": 15,
    "crosszoom": 16, "slide": 17, "zoom": 18, "glitch": 19, "burn": 20, "waterdrop": 21, "hexagon": 22
  })
  readonly property var effectNames: Object.keys(modes)

  readonly property real mode: modes[effect] !== undefined ? modes[effect] : 1
  readonly property real angle: angleDegrees * Math.PI / 180
  readonly property real aspect: width / Math.max(1, height)

  property variant fromTex: fromSource
  property variant toTex: toSource

  ShaderEffectSource {
    id: fromSource
    sourceItem: fx.fromItem
    hideSource: fx.hideSources
    visible: false
  }
  ShaderEffectSource {
    id: toSource
    sourceItem: fx.toItem
    hideSource: fx.hideSources
    visible: false
  }

  fragmentShader: Qt.resolvedUrl("shaders/transition.frag.qsb")
}
