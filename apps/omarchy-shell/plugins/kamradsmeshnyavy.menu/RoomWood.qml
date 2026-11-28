import QtQuick

// Деревянная панель райса Cozy Room: тёмный контур, рамка тёмного дерева, заливка деревом с горизонтальными
// досками (тонкие тёмные линии), светлая кромка сверху; lit — кромка светом лампы. Без сглаживания.
// Одинаковый файл в kamradsmeshnyavy.{bar/modules, widgets, osd, notifications/components, lock/designs, menu} — правку переносить во все.
Item {
  id: wd
  required property QtObject pal
  property real radius: 4
  property int thick: 3
  property bool lit: false
  property int plank: 14          // высота доски, px; 0 — без досок
  property color fill: pal.wood
  default property alias content: inner.data
  property alias inner: inner
  property int pad: 8

  Rectangle { anchors.fill: parent; anchors.margins: -1; radius: wd.radius + 1; color: wd.pal.ink; antialiasing: false }
  Rectangle { anchors.fill: parent; radius: wd.radius; color: wd.lit ? wd.pal.lamp : wd.pal.dark; antialiasing: false }
  Rectangle {
    id: body
    anchors.fill: parent
    anchors.margins: wd.thick
    radius: Math.max(0, wd.radius - wd.thick)
    color: wd.fill
    antialiasing: false
    clip: true
    Repeater {
      model: wd.plank > 0 ? Math.floor(body.height / wd.plank) : 0
      Rectangle { required property int index; y: (index + 1) * wd.plank; width: body.width; height: 1; color: wd.pal.alpha(wd.pal.ink, 0.18) }
    }
    Rectangle { width: parent.width; height: 2; color: wd.pal.alpha("#ffffff", 0.12) }
  }
  Item {
    id: inner
    anchors.fill: parent
    anchors.margins: wd.thick + wd.pad
  }
}
