import QtQuick
import QtQuick.Shapes

// Дашборд: графики CPU и RAM за последние 2 минуты, температура и батарея строкой.
Rectangle {
  id: stats

  required property var host

  radius: 16
  color: Qt.rgba(host.foreground.r, host.foreground.g, host.foreground.b, 0.05)

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 6

    Repeater {
      model: [
        { label: "CPU", history: stats.host.cpuHistory, value: stats.host.cpu },
        { label: "RAM", history: stats.host.memHistory, value: stats.host.mem }
      ]
      delegate: Item {
        id: graph
        required property var modelData
        width: parent.width
        height: 36

        Text {
          id: label
          width: 74
          anchors.verticalCenter: parent.verticalCenter
          text: graph.modelData.label + " " + Math.round(graph.modelData.value * 100) + "%"
          font.family: stats.host.fontFamily
          font.pixelSize: 11
          color: stats.host.foreground
          opacity: 0.8
        }
        Shape {
          id: line
          anchors { left: label.right; right: parent.right; top: parent.top; bottom: parent.bottom }
          preferredRendererType: Shape.CurveRenderer
          readonly property var pts: {
            var h = graph.modelData.history
            var n = stats.host.historyLength
            var out = [Qt.point(0, height)]
            for (var i = 0; i < h.length; i++)
              out.push(Qt.point((n - h.length + i) * width / (n - 1), height - h[i] * (height - 2) - 1))
            out.push(Qt.point(width, height))
            return out
          }
          ShapePath {
            strokeColor: stats.host.accent
            strokeWidth: 1.5
            fillGradient: LinearGradient {
              x1: 0; y1: 0; x2: 0; y2: line.height
              GradientStop { position: 0; color: Qt.rgba(stats.host.accent.r, stats.host.accent.g, stats.host.accent.b, 0.35) }
              GradientStop { position: 1; color: "transparent" }
            }
            startX: 0
            startY: line.height
            PathPolyline { path: line.pts }
          }
        }
      }
    }

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: " " + Math.round(stats.host.temp) + "°" +
        (stats.host.battery >= 0 ? "     " + (stats.host.batteryStatus === "Charging" ? "󰂄 " : "󰁹 ") + stats.host.battery + "%" : "")
      font.family: stats.host.fontFamily
      font.pixelSize: 12
      color: stats.host.foreground
      opacity: 0.8
    }
  }
}
