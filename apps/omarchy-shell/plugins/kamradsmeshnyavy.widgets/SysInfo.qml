import QtQuick
import QtQuick.Shapes

// Кольца системы: CPU, RAM, температура, батарея (если есть). Данные — Widgets.qml (/proc, /sys).
Row {
  id: sys

  required property var host

  spacing: 18

  Repeater {
    model: [
      { label: "CPU", value: sys.host.cpu, text: Math.round(sys.host.cpu * 100) + "%" },
      { label: "RAM", value: sys.host.mem, text: Math.round(sys.host.mem * 100) + "%" },
      { label: "TEMP", value: Math.min(1, sys.host.temp / 100), text: Math.round(sys.host.temp) + "°", hot: sys.host.temp >= 85 },
      { label: sys.host.batteryStatus === "Charging" ? "BAT 󱐋" : "BAT", value: sys.host.battery / 100,
        text: sys.host.battery + "%", hot: sys.host.battery >= 0 && sys.host.battery <= 15, hidden: sys.host.battery < 0 }
    ]

    delegate: Column {
      id: ring
      required property var modelData
      visible: !modelData.hidden
      spacing: 6

      readonly property int size: 72
      readonly property color tint: modelData.hot ? sys.host.resolve("red", "#e05561") : sys.host.accent

      Item {
        width: ring.size
        height: ring.size

        Shape {
          anchors.fill: parent
          preferredRendererType: Shape.CurveRenderer
          ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.rgba(sys.host.foreground.r, sys.host.foreground.g, sys.host.foreground.b, 0.12)
            strokeWidth: 6
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: ring.size / 2; centerY: ring.size / 2; radiusX: ring.size / 2 - 4; radiusY: radiusX; startAngle: 135; sweepAngle: 270 }
          }
          ShapePath {
            fillColor: "transparent"
            strokeColor: ring.tint
            strokeWidth: 6
            capStyle: ShapePath.RoundCap
            PathAngleArc {
              centerX: ring.size / 2; centerY: ring.size / 2; radiusX: ring.size / 2 - 4; radiusY: radiusX
              startAngle: 135
              sweepAngle: Math.max(0.5, 270 * Math.max(0, Math.min(1, ring.modelData.value)))
              Behavior on sweepAngle { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
          }
        }
        Text {
          anchors.centerIn: parent
          text: ring.modelData.text
          font.family: sys.host.fontFamily
          font.pixelSize: 15
          font.weight: Font.Bold
          color: sys.host.foreground
        }
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: ring.modelData.label
        font.family: sys.host.fontFamily
        font.pixelSize: 11
        font.letterSpacing: 2
        color: sys.host.foreground
        opacity: 0.65
      }
    }
  }
}
