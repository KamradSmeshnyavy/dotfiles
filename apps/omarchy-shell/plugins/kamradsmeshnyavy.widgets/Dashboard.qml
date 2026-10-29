import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes

// Дашборд, «вытекающий» из-под бара / рамки (идея caelestia, написано с нуля): окно у
// верхнего края под зарезервированной зоной бара, цвет бара, вогнутые углы сверху
// сливаются с полосой, высота растёт от нуля. Esc или клик мимо — закрыть.
PanelWindow {
  id: dash

  required property var host

  readonly property int bodyWidth: 920
  readonly property int bodyHeight: 300
  readonly property int flare: host.drawerFlare
  readonly property int bottomRadius: 22

  property real progress: host.dashboardOpen ? 1 : 0
  Behavior on progress { NumberAnimation { duration: 340; easing.type: Easing.OutCubic } }
  readonly property real h: Math.round(bodyHeight * progress)

  visible: progress > 0.001
  screen: host.focusedScreen
  anchors.top: true
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0
  implicitWidth: bodyWidth + 2 * flare
  implicitHeight: bodyHeight
  color: "transparent"
  surfaceFormat.opaque: false
  WlrLayershell.namespace: "omarchy-dashboard"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: host.dashboardOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  mask: Region { item: hit }

  HyprlandFocusGrab {
    active: dash.host.dashboardOpen
    windows: [dash]
    onCleared: dash.host.dashboardOpen = false
  }

  Item {
    id: hit
    x: dash.flare
    width: dash.bodyWidth
    height: dash.h
  }

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      id: outline
      // Пока дашборд ниже радиуса, вогнутый угол сплющен по высоте (эллипс), а нижние
      // углы берут только оставшуюся высоту — контур не ломается при любой высоте.
      readonly property real fy: Math.min(dash.flare, dash.h)
      readonly property real br: Math.max(0, Math.min(dash.bottomRadius, (dash.h - fy) / 2))
      readonly property real left: dash.flare
      readonly property real right: dash.width - dash.flare

      fillColor: dash.host.drawerColor
      strokeWidth: -1
      startX: 0
      startY: 0

      PathLine { x: dash.width; y: 0 }
      // Правый вогнутый угол: переход от полосы бара к телу дашборда.
      PathArc { x: outline.right; y: outline.fy; radiusX: dash.flare; radiusY: Math.max(0.01, outline.fy); direction: PathArc.Counterclockwise }
      PathLine { x: outline.right; y: dash.h - outline.br }
      PathArc { x: outline.right - outline.br; y: dash.h; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br) }
      PathLine { x: outline.left + outline.br; y: dash.h }
      PathArc { x: outline.left; y: dash.h - outline.br; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br) }
      PathLine { x: outline.left; y: outline.fy }
      PathArc { x: 0; y: 0; radiusX: dash.flare; radiusY: Math.max(0.01, outline.fy); direction: PathArc.Counterclockwise }
    }
  }

  Item {
    id: content
    x: dash.flare
    width: dash.bodyWidth
    height: dash.h
    clip: true
    opacity: Math.max(0, (dash.progress - 0.35) / 0.65)
    focus: dash.host.dashboardOpen
    Keys.onEscapePressed: dash.host.dashboardOpen = false

    Row {
      x: 20
      y: 16
      height: dash.bodyHeight - 36
      spacing: 16

      DashMedia { host: dash.host; width: 360; height: parent.height }
      DashCalendar { host: dash.host; width: 250; height: parent.height }
      Column {
        width: 238
        height: parent.height
        spacing: 12
        DashWeather { host: dash.host; width: parent.width; height: 116 }
        DashStats { host: dash.host; width: parent.width; height: parent.height - 128 }
      }
    }
  }
}
