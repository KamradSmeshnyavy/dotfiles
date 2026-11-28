import QtQuick

// Записка райса Cozy Room: лист бумаги с жёсткой тенью, полоска скотча сверху (полупрозрачный свет лампы),
// лёгкий наклон tilt (градусы). Текст — цветом paperink.
// Одинаковый файл в kamradsmeshnyavy.{bar/modules, widgets, osd, notifications/components, lock/designs, menu} — правку переносить во все.
Item {
  id: nt
  required property QtObject pal
  property real tilt: 0
  property bool tape: true
  property color fill: pal.paper
  default property alias content: inner.data
  property alias inner: inner
  property int pad: 14
  rotation: tilt
  antialiasing: true

  Rectangle { x: 5; y: 6; width: parent.width; height: parent.height; color: nt.pal.alpha(nt.pal.ink, 0.35); antialiasing: false }
  Rectangle { anchors.fill: parent; color: nt.fill; border.width: 1; border.color: nt.pal.alpha(nt.pal.ink, 0.25); antialiasing: false }
  Rectangle {
    visible: nt.tape
    width: Math.min(90, parent.width * 0.32); height: 16
    anchors.horizontalCenter: parent.horizontalCenter
    y: -8
    rotation: -nt.tilt * 1.5 - 2
    color: nt.pal.alpha(nt.pal.lamp, 0.55)
    antialiasing: false
  }
  Item {
    id: inner
    anchors.fill: parent
    anchors.margins: nt.pad
  }
}
