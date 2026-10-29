import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// Дашборд у верхнего края (идея caelestia, написано с нуля). Вид — BarStyle (host.panelStyle):
//   attached — «вытекает» из-под сплошного бара / рамки: вогнутые углы сверху переходят в полосу;
//   floating — отдельная скруглённая карточка с отступом, рамкой и тенью (прозрачный или
//              «островной» бар — тогда затёкам не к чему прилипать).
// Анимация (dashAnimation): grow — растёт по высоте, slide — выезжает сверху, fade — проявляется.
// Блоки включаются ключами dashMedia / dashCalendar / dashWeather / dashStats. Esc или клик мимо — закрыть.
PanelWindow {
  id: dash

  required property var host
  readonly property var style: host.panelStyle
  readonly property bool attached: style.attached

  // Блоки и ширина: колонка справа (погода + графики) — один блок, если есть хоть одно из двух.
  readonly property bool showMedia: host.value("dashMedia") !== false
  readonly property bool showCalendar: host.value("dashCalendar") !== false
  readonly property bool showWeather: host.value("dashWeather") !== false
  readonly property bool showStats: host.value("dashStats") !== false
  readonly property bool showSide: showWeather || showStats
  readonly property int pad: 20
  readonly property int gap: 16
  readonly property int contentWidth: {
    var w = [], n = 0
    if (showMedia) w.push(360)
    if (showCalendar) w.push(250)
    if (showSide) w.push(238)
    for (var i = 0; i < w.length; i++) n += w[i]
    return Math.max(250, n + Math.max(0, w.length - 1) * gap)
  }
  readonly property int bodyWidth: contentWidth + 2 * pad
  readonly property int bodyHeight: 300
  readonly property int flare: attached ? style.flare : 0
  readonly property int margin: attached ? 0 : 10       // отступ плавающей карточки от бара
  readonly property int shadowPad: attached ? 0 : 24
  readonly property string animation: String(host.value("dashAnimation"))
  readonly property int duration: Math.max(60, host.num("dashDuration"))

  property real progress: host.dashboardOpen ? 1 : 0
  Behavior on progress { NumberAnimation { duration: dash.duration; easing.type: Easing.OutCubic } }
  // grow — высота растёт; slide — сдвиг сверху; fade — только прозрачность (+ лёгкий масштаб).
  readonly property real h: animation === "grow" ? Math.round(bodyHeight * progress) : bodyHeight
  readonly property real slide: animation === "slide" ? (1 - progress) * -(bodyHeight + margin) : 0
  readonly property real fadeOpacity: animation === "grow" ? 1 : progress

  visible: progress > 0.001
  screen: host.focusedScreen
  anchors.top: true
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0
  implicitWidth: bodyWidth + 2 * Math.max(flare, shadowPad)
  implicitHeight: bodyHeight + margin + shadowPad
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

  // Всё содержимое — в «листе», который сдвигается при slide.
  Item {
    id: sheet
    width: dash.width
    height: dash.height
    y: dash.slide
    opacity: dash.fadeOpacity
    scale: dash.animation === "fade" ? 0.97 + 0.03 * dash.progress : 1
    transformOrigin: Item.Top

    Item {
      id: hit
      x: (dash.width - dash.bodyWidth) / 2
      y: dash.margin
      width: dash.bodyWidth
      height: dash.h
    }

    // attached: контур с вогнутыми углами сверху.
    Shape {
      visible: dash.attached
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        id: outline
        // Пока дашборд ниже радиуса, вогнутый угол сплющен по высоте (эллипс), а нижние
        // углы берут только оставшуюся высоту — контур не ломается при любой высоте.
        readonly property real fy: Math.min(dash.flare, dash.h)
        readonly property real br: Math.max(0, Math.min(dash.style.cornerRadius, (dash.h - fy) / 2))
        readonly property real left: hit.x
        readonly property real right: hit.x + hit.width

        fillColor: dash.style.color
        strokeWidth: -1
        startX: outline.left - dash.flare
        startY: 0

        PathLine { x: outline.right + dash.flare; y: 0 }
        PathArc { x: outline.right; y: outline.fy; radiusX: Math.max(0.01, dash.flare); radiusY: Math.max(0.01, outline.fy); direction: PathArc.Counterclockwise }
        PathLine { x: outline.right; y: dash.h - outline.br }
        PathArc { x: outline.right - outline.br; y: dash.h; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br) }
        PathLine { x: outline.left + outline.br; y: dash.h }
        PathArc { x: outline.left; y: dash.h - outline.br; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br) }
        PathLine { x: outline.left; y: outline.fy }
        PathArc { x: outline.left - dash.flare; y: 0; radiusX: Math.max(0.01, dash.flare); radiusY: Math.max(0.01, outline.fy); direction: PathArc.Counterclockwise }
      }
    }

    // floating: карточка с рамкой и тенью.
    Rectangle {
      visible: !dash.attached
      x: hit.x
      y: hit.y
      width: hit.width
      height: hit.height
      radius: Math.min(dash.style.cornerRadius, height / 2)
      color: dash.style.color
      border.width: dash.style.borderWidth
      border.color: dash.style.borderColor
      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#000000"
        shadowOpacity: 0.4
        shadowBlur: 0.8
        shadowVerticalOffset: 4
      }
    }

    Item {
      id: content
      x: hit.x
      y: hit.y
      width: dash.bodyWidth
      height: dash.h
      clip: true
      opacity: dash.animation === "grow" ? Math.max(0, (dash.progress - 0.35) / 0.65) : 1
      focus: dash.host.dashboardOpen
      Keys.onEscapePressed: dash.host.dashboardOpen = false

      Row {
        x: dash.pad
        y: 16
        height: dash.bodyHeight - 36
        spacing: dash.gap

        DashMedia { visible: dash.showMedia; host: dash.host; width: 360; height: parent.height }
        DashCalendar { visible: dash.showCalendar; host: dash.host; width: 250; height: parent.height }
        Column {
          visible: dash.showSide
          width: 238
          height: parent.height
          spacing: 12
          DashWeather { visible: dash.showWeather; host: dash.host; width: parent.width; height: dash.showStats ? 116 : parent.height }
          DashStats { visible: dash.showStats; host: dash.host; width: parent.width; height: dash.showWeather ? parent.height - 128 : parent.height }
        }
      }
    }
  }
}
