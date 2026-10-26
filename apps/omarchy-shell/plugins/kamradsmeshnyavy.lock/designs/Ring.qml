import QtQuick
import QtQuick.Shapes

// Кольцо секунд вокруг времени, поле под кольцом.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root }

  Item {
    id: ring
    width: 340
    height: 340
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -60

    readonly property real progress: (root.now.getSeconds() + 1) / 60

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: root.withAlpha(root.bg, 0.6)
    }

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeColor: root.withAlpha(root.fg, 0.12)
        strokeWidth: 10
        fillColor: "transparent"
        PathAngleArc { centerX: 170; centerY: 170; radiusX: 155; radiusY: 155; startAngle: 0; sweepAngle: 360 }
      }
      ShapePath {
        strokeColor: root.accent
        strokeWidth: 10
        capStyle: ShapePath.RoundCap
        fillColor: "transparent"
        PathAngleArc { centerX: 170; centerY: 170; radiusX: 155; radiusY: 155; startAngle: -90; sweepAngle: 360 * ring.progress }
      }
    }

    Column {
      anchors.centerIn: parent
      spacing: 6
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.time
        color: root.fg
        font.family: root.font
        font.pixelSize: 64
        font.weight: Font.Light
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.showDate
        text: root.dateText
        color: root.withAlpha(root.fg, 0.65)
        font.family: root.font
        font.pixelSize: 14
      }
    }
  }

  PasswordField {
    id: pw
    host: root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: ring.bottom
    anchors.topMargin: 40
    fieldWidth: 340
    fieldHeight: 54
    fieldRadius: 27
  }
}
