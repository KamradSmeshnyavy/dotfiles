import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes

// Меню выключения, выезжающее из правого края / рамки (идея caelestia, написано с нуля).
// Пункты и команды — как в стоковом System-меню Omarchy. Выход, перезагрузка и выключение
// срабатывают со второго нажатия (первое — «ещё раз, чтобы подтвердить», 3 с).
// Клавиши: j/k или ↑↓, Enter, 1–6, Esc; клик мимо закрывает.
PanelWindow {
  id: power

  required property var host

  readonly property int thickness: 104
  readonly property int button: 64
  readonly property int buttonWidth: 84
  readonly property int gap: 10
  readonly property int flare: host.drawerFlare
  readonly property int bodyRadius: 22

  property bool hibernate: false
  property bool suspend: true
  readonly property var items: {
    var out = [
      { id: "lock", icon: "󰌾", label: host.tr("Lock", "Блокировка"), action: "omarchy-system-lock" }
    ]
    if (suspend) out.push({ id: "suspend", icon: "󰒲", label: host.tr("Suspend", "Сон"), action: "systemctl suspend" })
    if (hibernate) out.push({ id: "hibernate", icon: "󰤁", label: host.tr("Hibernate", "Гибернация"), action: "systemctl hibernate" })
    out.push({ id: "logout", icon: "󰍃", label: host.tr("Log out", "Выход"), action: "omarchy-system-logout", confirm: true })
    out.push({ id: "reboot", icon: "󰜉", label: host.tr("Reboot", "Перезагрузка"), action: "omarchy-system-reboot", confirm: true })
    out.push({ id: "shutdown", icon: "󰐥", label: host.tr("Shut down", "Выключение"), action: "omarchy-system-shutdown", confirm: true })
    return out
  }
  readonly property int length: items.length * button + (items.length - 1) * gap + 2 * 18

  property int selected: 0
  property string armed: ""   // id пункта, ждущего подтверждения
  Timer { id: disarm; interval: 3000; onTriggered: power.armed = "" }

  property real progress: host.powerOpen ? 1 : 0
  Behavior on progress { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
  readonly property real w: Math.round(thickness * progress)

  // Что доступно: сон можно отключить в Omarchy, гибернация — только если настроена.
  Process {
    id: probe
    command: ["bash", "-c", "omarchy-toggle-enabled suspend-off >/dev/null 2>&1 && echo nosuspend; omarchy-hibernation-available >/dev/null 2>&1 && echo hibernate; true"]
    stdout: StdioCollector {
      onStreamFinished: {
        power.suspend = text.indexOf("nosuspend") === -1
        power.hibernate = text.indexOf("hibernate") !== -1
      }
    }
  }
  Connections {
    target: power.host
    function onPowerOpenChanged() {
      if (!power.host.powerOpen) return
      power.selected = 0
      power.armed = ""
      probe.running = true
    }
  }

  function activate(i) {
    if (i < 0 || i >= items.length) return
    selected = i
    var it = items[i]
    if (it.confirm && armed !== it.id) {
      armed = it.id
      disarm.restart()
      return
    }
    armed = ""
    host.powerOpen = false
    Quickshell.execDetached(["bash", "-c", it.action])
  }

  visible: progress > 0.001
  screen: host.focusedScreen
  anchors.right: true
  exclusionMode: ExclusionMode.Normal
  exclusiveZone: 0
  implicitWidth: thickness
  implicitHeight: length + 2 * flare
  color: "transparent"
  surfaceFormat.opaque: false
  WlrLayershell.namespace: "omarchy-power"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: host.powerOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  mask: Region { item: hit }

  HyprlandFocusGrab {
    active: power.host.powerOpen
    windows: [power]
    onCleared: power.host.powerOpen = false
  }

  Item {
    id: hit
    x: power.width - power.w
    y: power.flare
    width: power.w
    height: power.length
  }

  // Контур как у OSD у края: вогнутые углы сверху и снизу переходят в край экрана.
  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      id: outline
      readonly property real ww: power.width
      readonly property real x0: ww - power.w
      readonly property real fx: Math.min(power.flare, power.w)
      readonly property real br: Math.max(0, Math.min(power.bodyRadius, (power.w - fx) / 2))
      readonly property real top: power.flare
      readonly property real bottom: power.height - power.flare

      fillColor: power.host.drawerColor
      strokeWidth: -1
      startX: outline.ww
      startY: 0

      PathArc { x: outline.ww - outline.fx; y: outline.top; radiusX: Math.max(0.01, outline.fx); radiusY: power.flare }
      PathLine { x: outline.x0 + outline.br; y: outline.top }
      PathArc { x: outline.x0; y: outline.top + outline.br; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.x0; y: outline.bottom - outline.br }
      PathArc { x: outline.x0 + outline.br; y: outline.bottom; radiusX: Math.max(0.01, outline.br); radiusY: Math.max(0.01, outline.br); direction: PathArc.Counterclockwise }
      PathLine { x: outline.ww - outline.fx; y: outline.bottom }
      PathArc { x: outline.ww; y: power.height; radiusX: Math.max(0.01, outline.fx); radiusY: power.flare }
      PathLine { x: outline.ww; y: 0 }
    }
  }

  Item {
    id: content
    x: power.width - power.w
    y: power.flare
    width: power.w
    height: power.length
    clip: true
    opacity: Math.max(0, (power.progress - 0.4) / 0.6)
    focus: power.host.powerOpen

    Keys.onPressed: event => {
      var t = event.text
      if (event.key === Qt.Key_Escape) power.host.powerOpen = false
      else if (event.key === Qt.Key_Down || t === "j") power.selected = (power.selected + 1) % power.items.length
      else if (event.key === Qt.Key_Up || t === "k") power.selected = (power.selected - 1 + power.items.length) % power.items.length
      else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) power.activate(power.selected)
      else if (t >= "1" && t <= String(power.items.length)) power.activate(Number(t) - 1)
      else return
      event.accepted = true
    }

    Column {
      x: (power.thickness - power.buttonWidth) / 2
      anchors.verticalCenter: parent.verticalCenter
      spacing: power.gap

      Repeater {
        model: power.items
        delegate: Rectangle {
          id: btn
          required property var modelData
          required property int index
          readonly property bool current: power.selected === index
          readonly property bool armed: power.armed === modelData.id
          readonly property color danger: power.host.resolve("red", "#e05561")

          width: power.buttonWidth
          height: power.button
          radius: 18
          color: armed ? Qt.rgba(danger.r, danger.g, danger.b, 0.85)
            : current || hover.hovered ? Qt.rgba(power.host.accent.r, power.host.accent.g, power.host.accent.b, 0.22)
            : Qt.rgba(power.host.foreground.r, power.host.foreground.g, power.host.foreground.b, 0.05)
          border.width: current ? 2 : 0
          border.color: armed ? danger : power.host.accent
          Behavior on color { ColorAnimation { duration: 140 } }

          Column {
            anchors.centerIn: parent
            spacing: 3
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: btn.modelData.icon
              font.family: power.host.fontFamily
              font.pixelSize: 22
              color: btn.armed ? power.host.background : btn.current ? power.host.accent : power.host.foreground
            }
            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              width: power.buttonWidth - 6
              horizontalAlignment: Text.AlignHCenter
              elide: Text.ElideRight
              text: btn.armed ? power.host.tr("again", "ещё раз") : btn.modelData.label
              font.family: power.host.fontFamily
              font.pixelSize: 9
              color: btn.armed ? power.host.background : power.host.foreground
              opacity: btn.armed ? 1 : 0.75
            }
          }

          HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor; onHoveredChanged: if (hovered) power.selected = btn.index }
          TapHandler { onTapped: power.activate(btn.index) }
        }
      }
    }
  }
}
