import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Обзор рабочих столов: сетка столов с обоями и живыми превью окон (ScreencopyView).
// Клик по столу — перейти, по окну — фокус на нём, перетащить окно на другой стол — перенести
// туда, не уходя с текущего. Клавиши: ←→↑↓ / hjkl, Enter, 1–9, Esc.
// Диспетчеры — через `hyprctl eval` (Lua-конфиг: обычный `hyprctl dispatch` ничего не делает).
PanelWindow {
  id: ov

  required property var host

  readonly property var monitor: Hyprland.monitorFor(screen)
  readonly property int activeWs: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 1
  // Столы 1…max(5, занятые, активный), не больше 10.
  readonly property int count: {
    var n = Math.max(5, activeWs)
    var list = Hyprland.toplevels.values
    for (var i = 0; i < list.length; i++) {
      var ws = list[i].workspace
      if (ws && ws.id > n && ws.id <= 10) n = ws.id
    }
    return Math.min(10, n)
  }
  readonly property int columns: count <= 5 ? count : Math.ceil(count / 2)
  readonly property int rows: Math.ceil(count / columns)
  readonly property real gap: 22
  readonly property real tileW: Math.min((width - 120 - (columns - 1) * gap) / columns, (height - 160 - (rows - 1) * gap) / rows * width / height)
  readonly property real ratio: tileW / width
  readonly property real tileH: height * ratio

  property int selected: 1
  property bool dragging: false
  property int dragFrom: 0     // стол, с которого тащат окно: он рисуется поверх соседей

  function hl(lua) { Quickshell.execDetached(["hyprctl", "eval", lua]) }
  function goTo(ws) { host.overviewOpen = false; hl("hl.dispatch(hl.dsp.focus({ workspace = '" + ws + "' }))") }
  function focusWindow(address) { host.overviewOpen = false; hl("hl.dispatch(hl.dsp.focus({ window = 'address:" + address + "' }))") }
  function moveWindow(address, ws) {
    hl("hl.dispatch(hl.dsp.window.move({ workspace = '" + ws + "', follow = false, window = 'address:" + address + "' }))")
    refresh.restart()
  }
  Timer { id: refresh; interval: 120; onTriggered: Hyprland.refreshToplevels() }

  Connections {
    target: ov.host
    function onOverviewOpenChanged() {
      if (!ov.host.overviewOpen) return
      Hyprland.refreshToplevels()
      ov.selected = ov.activeWs
    }
  }

  visible: host.overviewOpen
  screen: host.focusedScreen
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  surfaceFormat.opaque: false
  WlrLayershell.namespace: "omarchy-overview"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: host.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(ov.host.panelStyle.color.r, ov.host.panelStyle.color.g, ov.host.panelStyle.color.b, 0.93)
    opacity: ov.host.overviewOpen ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 180 } }
    TapHandler { onTapped: ov.host.overviewOpen = false }
  }

  Item {
    id: keys
    anchors.fill: parent
    focus: ov.host.overviewOpen
    Keys.onPressed: event => {
      var t = event.text
      var col = (ov.selected - 1) % ov.columns, row = Math.floor((ov.selected - 1) / ov.columns)
      if (event.key === Qt.Key_Escape) ov.host.overviewOpen = false
      else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) ov.goTo(ov.selected)
      else if (event.key === Qt.Key_Left || t === "h") ov.selected = ov.selected > 1 ? ov.selected - 1 : ov.count
      else if (event.key === Qt.Key_Right || t === "l") ov.selected = ov.selected < ov.count ? ov.selected + 1 : 1
      else if (event.key === Qt.Key_Up || t === "k") ov.selected = Math.max(1, ov.selected - ov.columns)
      else if (event.key === Qt.Key_Down || t === "j") ov.selected = Math.min(ov.count, ov.selected + ov.columns)
      else if (t >= "1" && t <= "9" && Number(t) <= ov.count) ov.goTo(Number(t))
      else return
      event.accepted = true
    }
  }

  Grid {
    id: grid
    anchors.centerIn: parent
    columns: ov.columns
    spacing: ov.gap
    scale: ov.host.overviewOpen ? 1 : 0.94
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Repeater {
      model: ov.count
      delegate: Item {
        id: tile
        required property int index
        readonly property int ws: index + 1
        readonly property bool active: ws === ov.activeWs
        readonly property bool current: ws === ov.selected
        width: ov.tileW
        height: ov.tileH + 24
        z: ov.dragging && ov.dragFrom === ws ? 10 : 1

        Text {
          text: tile.ws
          font.family: ov.host.fontFamily
          font.pixelSize: 14
          font.bold: tile.active
          color: tile.active ? ov.host.accent : ov.host.foreground
          opacity: tile.active ? 1 : 0.7
        }

        Rectangle {
          id: screenTile
          y: 24
          width: ov.tileW
          height: ov.tileH
          radius: 12
          color: ov.host.background
          border.width: tile.current || drop.containsDrag ? 2 : 1
          border.color: drop.containsDrag ? ov.host.accent
            : tile.current ? ov.host.accent
            : Qt.rgba(ov.host.foreground.r, ov.host.foreground.g, ov.host.foreground.b, 0.15)
          clip: !ov.dragging

          Image {
            anchors.fill: parent
            anchors.margins: 1
            source: "file://" + ov.host.home + "/.local/state/omarchy/current/background"
            sourceSize.width: 480
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 0.55
            cache: true
          }

          HoverHandler { onHoveredChanged: if (hovered) ov.selected = tile.ws }
          TapHandler { onTapped: ov.goTo(tile.ws) }

          DropArea {
            id: drop
            anchors.fill: parent
            onDropped: drag => {
              var address = drag.source ? drag.source.address : ""
              if (address && drag.source.wsId !== tile.ws) ov.moveWindow(address, tile.ws)
            }
          }

          Repeater {
            model: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === tile.ws && t.lastIpcObject && t.lastIpcObject.at)

            delegate: Item {
              id: win
              required property var modelData
              readonly property var ipc: modelData.lastIpcObject
              readonly property string address: String(ipc.address || "")
              readonly property int wsId: tile.ws
              readonly property real homeX: (ipc.at[0] - (ov.monitor ? ov.monitor.x : 0)) * ov.ratio
              readonly property real homeY: (ipc.at[1] - (ov.monitor ? ov.monitor.y : 0)) * ov.ratio

              x: homeX
              y: homeY
              width: Math.max(12, ipc.size[0] * ov.ratio)
              height: Math.max(12, ipc.size[1] * ov.ratio)
              z: mouse.drag.active ? 100 : (ipc.floating ? 2 : 1)

              Drag.active: mouse.drag.active
              Drag.source: win
              Drag.hotSpot.x: width / 2
              Drag.hotSpot.y: height / 2

              Rectangle {
                anchors.fill: parent
                radius: 6
                color: Qt.rgba(ov.host.foreground.r, ov.host.foreground.g, ov.host.foreground.b, 0.08)
                border.width: mouse.containsMouse ? 2 : 1
                border.color: mouse.containsMouse ? ov.host.accent : Qt.rgba(ov.host.foreground.r, ov.host.foreground.g, ov.host.foreground.b, 0.25)
                clip: true

                ScreencopyView {
                  anchors.fill: parent
                  anchors.margins: 1
                  captureSource: ov.host.overviewOpen ? win.modelData.wayland : null
                  live: ov.host.overviewOpen
                  constraintSize: Qt.size(width, height)
                }
              }

              Image {
                anchors.centerIn: parent
                width: Math.min(28, parent.width / 2)
                height: width
                source: Quickshell.iconPath(String(win.ipc.class || "").toLowerCase(), true)
                sourceSize.width: 56
                sourceSize.height: 56
                visible: status === Image.Ready
                opacity: mouse.containsMouse ? 1 : 0.8
              }

              MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                drag.target: win
                drag.threshold: 8
                onPressed: { ov.dragging = true; ov.dragFrom = win.wsId }
                onReleased: {
                  if (drag.active) win.Drag.drop()
                  else ov.focusWindow(win.address)
                  ov.dragging = false
                  win.x = Qt.binding(() => win.homeX)
                  win.y = Qt.binding(() => win.homeY)
                }
              }
            }
          }
        }
      }
    }
  }

  Text {
    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 36 }
    text: ov.host.tr("click — go · drag a window — move it · ←→↑↓ Enter 1–9 · Esc",
      "клик — перейти · перетащить окно — перенести · ←→↑↓ Enter 1–9 · Esc")
    font.family: ov.host.fontFamily
    font.pixelSize: 12
    color: ov.host.foreground
    opacity: 0.55
  }
}
