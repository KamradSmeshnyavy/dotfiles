import QtQuick
import Quickshell.Io

// Аптайм, память, нагрузка и батарея (из /proc и /sys, раз в 5 секунд).
DesignBase {
  id: root
  field: pw

  property real uptime: 0
  property real memTotal: 0
  property real memAvail: 0
  property string load: ""
  property int battery: -1
  property string batteryStatus: ""

  FileView { id: upF; path: "/proc/uptime"; onLoaded: root.uptime = Number(text().split(" ")[0]) }
  FileView { id: loadF; path: "/proc/loadavg"; onLoaded: root.load = text().split(" ").slice(0, 3).join("  ") }
  FileView {
    id: memF
    path: "/proc/meminfo"
    onLoaded: {
      var t = text()
      var total = t.match(/MemTotal:\s+(\d+)/)
      var avail = t.match(/MemAvailable:\s+(\d+)/)
      root.memTotal = total ? Number(total[1]) : 0
      root.memAvail = avail ? Number(avail[1]) : 0
    }
  }
  FileView { id: batF; path: "/sys/class/power_supply/BAT0/capacity"; printErrors: false; onLoaded: root.battery = Number(text()) }
  FileView { id: batS; path: "/sys/class/power_supply/BAT0/status"; printErrors: false; onLoaded: root.batteryStatus = text().trim() }
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: { upF.reload(); loadF.reload(); memF.reload(); batF.reload(); batS.reload() }
  }

  function uptimeText(s) {
    var d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60)
    return (d > 0 ? d + "д " : "") + h + "ч " + m + "м"
  }

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.3) }

  Row {
    anchors.centerIn: parent
    spacing: 70

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 12
      Text { text: root.time; color: root.fg; font.family: root.font; font.pixelSize: 86; font.bold: true }
      Text { visible: root.showDate; text: root.dateText; color: root.accent; font.family: root.font; font.pixelSize: 18 }
      Item { width: 1; height: 20 }
      PasswordField { id: pw; host: root; fieldWidth: 360; fieldHeight: 54; textAlignment: TextInput.AlignLeft }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 360
      height: stats.implicitHeight + 48
      radius: 18
      color: root.withAlpha(root.bg, 0.85)
      border.width: 1
      border.color: root.withAlpha(root.fg, 0.1)

      Column {
        id: stats
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 24 }
        spacing: 18

        Repeater {
          model: [
            { icon: "󰔟", label: "Аптайм", value: root.uptimeText(root.uptime), part: -1 },
            { icon: "󰍛", label: "Память", value: root.memTotal > 0 ? ((root.memTotal - root.memAvail) / 1048576).toFixed(1) + " / " + (root.memTotal / 1048576).toFixed(1) + " ГБ" : "—",
              part: root.memTotal > 0 ? (root.memTotal - root.memAvail) / root.memTotal : -1 },
            { icon: "󰓅", label: "Нагрузка", value: root.load || "—", part: -1 },
            { icon: root.batteryStatus === "Charging" ? "󰂄" : "󰁹", label: "Батарея", value: root.battery >= 0 ? root.battery + "%  " + root.batteryStatus : "нет",
              part: root.battery >= 0 ? root.battery / 100 : -1 }
          ]
          delegate: Column {
            required property var modelData
            width: stats.width
            spacing: 6
            Row {
              width: parent.width
              spacing: 10
              Text { text: modelData.icon; color: root.accent; font.family: root.font; font.pixelSize: 18 }
              Text { text: modelData.label; color: root.withAlpha(root.fg, 0.7); font.family: root.font; font.pixelSize: 15; width: 110 }
              Text { text: modelData.value; color: root.fg; font.family: root.font; font.pixelSize: 15 }
            }
            Rectangle {
              visible: modelData.part >= 0
              width: parent.width
              height: 6
              radius: 3
              color: root.withAlpha(root.fg, 0.12)
              Rectangle { width: parent.width * Math.max(0, Math.min(1, modelData.part)); height: parent.height; radius: 3; color: root.accent }
            }
          }
        }
      }
    }
  }
}
