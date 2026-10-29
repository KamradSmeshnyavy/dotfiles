import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons

// edge: OSD со шкалой (громкость, яркость, микрофон) — вертикальный слайдер, выезжающий
// из края экрана / рамки бара (идея caelestia, написано с нуля). Окно встаёт у края внутри
// зарезервированных зон, поэтому с формой бара frame растёт прямо из рамки; вогнутые углы
// сверху и снизу переходят в край. Клики не перехватывает.
PanelWindow {
  id: edge

  required property var osd          // корень Osd.qml: opened, icon, value, maxValue, message
  property string side: "right"      // right | left
  property color fill: Commons.Color.popups.background
  property int flare: 14

  readonly property int thickness: 54
  readonly property int length: 250
  readonly property int bodyRadius: 18

  property bool shown: osd.opened
  property real progress: shown ? 1 : 0
  Behavior on progress { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
  readonly property real w: Math.round(thickness * progress)
  readonly property bool right: side !== "left"

  visible: progress > 0.001
  anchors.right: right
  anchors.left: !right
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0
  implicitWidth: thickness
  implicitHeight: length + 2 * flare
  color: "transparent"
  surfaceFormat.opaque: false
  WlrLayershell.namespace: "omarchy-osd"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region {}

  // Контур рисуется для правого края, у левого — зеркально.
  Shape {
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

      fillColor: edge.fill
      strokeWidth: -1
      startX: outline.ww
      startY: 0

      // Верхний вогнутый угол: от края экрана к телу.
      PathArc { x: outline.ww - outline.fx; y: outline.top; radiusX: Math.max(0.01, outline.fx); radiusY: edge.flare; direction: PathArc.Clockwise }
      PathLine { x: outline.x0 + outline.br; y: outline.top }
      PathArc { x: outline.x0; y: outline.top + outline.br; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.x0; y: outline.bottom - outline.br }
      PathArc { x: outline.x0 + outline.br; y: outline.bottom; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.ww - outline.fx; y: outline.bottom }
      PathArc { x: outline.ww; y: edge.height; radiusX: Math.max(0.01, outline.fx); radiusY: edge.flare; direction: PathArc.Clockwise }
      PathLine { x: outline.ww; y: 0 }
    }
  }

  Item {
    x: edge.right ? edge.width - edge.w : 0
    y: edge.flare
    width: edge.w
    height: edge.length
    clip: true
    opacity: Math.max(0, (edge.progress - 0.4) / 0.6)

    Column {
      width: edge.thickness
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: 12

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: edge.osd.message
        font.family: Style.font.family
        font.pixelSize: 12
        font.bold: true
        color: Commons.Color.popups.text
      }

      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: 8
        height: edge.length - 100
        radius: 4
        color: Util.alpha(Commons.Color.popups.text, 0.18)
        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          radius: 4
          height: parent.height * Math.max(0, Math.min(1, edge.osd.value / Math.max(1, edge.osd.maxValue)))
          color: Commons.Color.accent
          Behavior on height { enabled: edge.shown; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: edge.osd.icon
        font.family: Style.font.family
        font.pixelSize: 22
        color: Commons.Color.popups.text
      }
    }
  }
}
