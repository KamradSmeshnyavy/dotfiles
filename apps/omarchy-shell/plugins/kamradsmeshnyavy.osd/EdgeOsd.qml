import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// edge: OSD со шкалой (громкость, яркость, микрофон) — вертикальный слайдер у края экрана
// (идея caelestia, написано с нуля). Вид — BarStyle (style):
//   attached — выезжает из края / рамки бара, вогнутые углы сверху и снизу переходят в край;
//   floating — карточка с отступом от края, рамкой и тенью.
// Окно встаёт у края внутри зарезервированных зон (с рамкой frame — прямо из неё). Клики не перехватывает.
PanelWindow {
  id: edge

  required property var osd          // корень Osd.qml: opened, icon, value, maxValue, message
  required property var style        // BarStyle.qml
  property string side: "right"      // right | left
  property string align: "center"    // center | top | bottom — вдоль края
  property string size: "normal"     // compact | normal | large
  property bool showValue: true

  readonly property bool attached: style.attached
  readonly property real k: size === "compact" ? 0.8 : size === "large" ? 1.25 : 1
  readonly property int thickness: Math.round(54 * k)
  readonly property int length: Math.round(250 * k)
  readonly property int flare: attached ? style.flare : 0
  readonly property int bodyRadius: style.cornerRadius
  readonly property int edgeGap: attached ? 0 : 12
  readonly property int shadowPad: attached ? 0 : 20
  readonly property int outer: Math.max(flare, shadowPad)   // поле над и под телом

  property bool shown: osd.opened
  property real progress: shown ? 1 : 0
  Behavior on progress { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
  readonly property real w: Math.round(thickness * progress)
  readonly property bool right: side !== "left"

  visible: progress > 0.001
  anchors.right: right
  anchors.left: !right
  anchors.top: align === "top"
  anchors.bottom: align === "bottom"
  margins.top: align === "top" ? 40 : 0
  margins.bottom: align === "bottom" ? 40 : 0
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0
  implicitWidth: thickness + edgeGap + shadowPad
  implicitHeight: length + 2 * outer
  color: "transparent"
  surfaceFormat.opaque: false
  WlrLayershell.namespace: "omarchy-osd"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region {}

  // Тело в координатах окна: для правого края — у правой стороны, для левого — зеркально.
  readonly property real bodyX: right ? width - edgeGap - w : edgeGap
  readonly property real bodyY: outer

  // floating: карточка.
  Rectangle {
    visible: !edge.attached
    x: edge.bodyX
    y: edge.bodyY
    width: edge.w
    height: edge.length
    radius: Math.min(edge.bodyRadius, width / 2)
    color: edge.style.color
    border.width: edge.style.borderWidth
    border.color: edge.style.borderColor
    layer.enabled: width > 1
    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#000000"; shadowOpacity: 0.4; shadowBlur: 0.8 }
  }

  // attached: контур рисуется для правого края, у левого — зеркально.
  Shape {
    visible: edge.attached
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    transform: Scale { origin.x: edge.width / 2; xScale: edge.right ? 1 : -1 }

    ShapePath {
      id: outline
      readonly property real ww: edge.width
      readonly property real x0: ww - edge.w             // внутренний край тела
      readonly property real fx: Math.min(edge.flare, edge.w)
      readonly property real br: Math.max(0, Math.min(edge.bodyRadius, (edge.w - fx) / 2, edge.length / 2))
      readonly property real top: edge.flare
      readonly property real bottom: edge.height - edge.flare

      fillColor: edge.style.color
      strokeWidth: -1
      startX: outline.ww
      startY: 0

      // Верхний вогнутый угол: от края экрана к телу.
      PathArc { x: outline.ww - outline.fx; y: outline.top; radiusX: Math.max(0.01, outline.fx); radiusY: Math.max(0.01, edge.flare); direction: PathArc.Clockwise }
      PathLine { x: outline.x0 + outline.br; y: outline.top }
      PathArc { x: outline.x0; y: outline.top + outline.br; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.x0; y: outline.bottom - outline.br }
      PathArc { x: outline.x0 + outline.br; y: outline.bottom; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.ww - outline.fx; y: outline.bottom }
      PathArc { x: outline.ww; y: edge.height; radiusX: Math.max(0.01, outline.fx); radiusY: Math.max(0.01, edge.flare); direction: PathArc.Clockwise }
      PathLine { x: outline.ww; y: 0 }
    }
  }

  Item {
    x: edge.bodyX
    y: edge.bodyY
    width: edge.w
    height: edge.length
    clip: true
    opacity: Math.max(0, (edge.progress - 0.4) / 0.6)

    Column {
      width: edge.thickness
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: Math.round(12 * edge.k)

      Text {
        visible: edge.showValue
        anchors.horizontalCenter: parent.horizontalCenter
        text: edge.osd.message
        font.family: Style.font.family
        font.pixelSize: Math.round(12 * edge.k)
        font.bold: true
        color: Commons.Color.popups.text
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.round(8 * edge.k)
        height: edge.length - Math.round((edge.showValue ? 100 : 70) * edge.k)
        radius: width / 2
        color: Util.alpha(Commons.Color.popups.text, 0.18)
        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          radius: width / 2
          height: parent.height * Math.max(0, Math.min(1, edge.osd.value / Math.max(1, edge.osd.maxValue)))
          color: Commons.Color.accent
          Behavior on height { enabled: edge.shown; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: edge.osd.icon
        font.family: Style.font.family
        font.pixelSize: Math.round(22 * edge.k)
        color: Commons.Color.popups.text
      }
    }
  }
}
