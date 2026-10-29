import QtQuick
import QtQuick.Shapes

// Визуализатор cava у нижнего края экрана. Стили (visualizerStyle): bars — столбики
// снизу; mirror — столбики, отражённые от середины; wave — сглаженная линия с заливкой.
Item {
  id: viz

  required property var host
  readonly property var levels: host.levels
  readonly property string style: String(host.value("visualizerStyle"))
  readonly property real alpha: Math.max(0.05, Math.min(1, host.num("visualizerAlpha")))
  readonly property color tint: Qt.rgba(host.accent.r, host.accent.g, host.accent.b, alpha)

  opacity: host.playing ? 1 : 0.5
  Behavior on opacity { NumberAnimation { duration: 400 } }

  Row {
    visible: viz.style !== "wave"
    anchors.fill: parent
    readonly property real slot: width / Math.max(1, viz.levels.length)

    Repeater {
      model: viz.levels.length
      delegate: Item {
        required property int index
        width: parent.slot
        height: viz.height
        readonly property real level: viz.levels[index] || 0

        Rectangle {
          width: Math.max(2, parent.width * 0.62)
          anchors.horizontalCenter: parent.horizontalCenter
          height: Math.max(2, parent.level * (viz.style === "mirror" ? viz.height / 2 : viz.height))
          y: viz.style === "mirror" ? (viz.height - height) / 2 : viz.height - height
          radius: width / 2
          gradient: Gradient {
            GradientStop { position: 0; color: viz.tint }
            GradientStop { position: 1; color: Qt.rgba(viz.tint.r, viz.tint.g, viz.tint.b, viz.alpha * 0.25) }
          }
          Behavior on height { NumberAnimation { duration: 60 } }
        }
      }
    }
  }

  Shape {
    visible: viz.style === "wave"
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeColor: viz.tint
      strokeWidth: 2
      fillGradient: LinearGradient {
        x1: 0; y1: 0; x2: 0; y2: viz.height
        GradientStop { position: 0; color: Qt.rgba(viz.tint.r, viz.tint.g, viz.tint.b, viz.alpha * 0.6) }
        GradientStop { position: 1; color: "transparent" }
      }
      startX: 0
      startY: viz.height
      PathPolyline {
        path: {
          var n = viz.levels.length
          var pts = [Qt.point(0, viz.height)]
          for (var i = 0; i < n; i++)
            pts.push(Qt.point(n > 1 ? i * viz.width / (n - 1) : 0, viz.height - (viz.levels[i] || 0) * viz.height * 0.9))
          pts.push(Qt.point(viz.width, viz.height))
          return pts
        }
      }
    }
  }
}
