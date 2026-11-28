import QtQuick

// Окно-диалог райса Quest: тёмный контур, светлая внешняя рамка, внутренняя рамка frame2 и градиент w1 → w2
// сверху вниз, как окна 16-битных ролевых игр. Без сглаживания — края пиксельные.
// Одинаковый файл в kamradsmeshnyavy.{bar/modules, widgets/quest, osd, notifications, lock/designs, menu} — правку переносить во все.
Item {
  id: win
  required property QtObject pal
  property real radius: pal.radius
  property int thick: 3            // светлая рамка, px
  property bool lit: false         // выделенное окно: рамка золотом курсора
  property real opacityFill: 1
  default property alias content: inner.data
  property alias inner: inner
  property int pad: 8

  // контур
  Rectangle {
    anchors.fill: parent
    anchors.margins: -1
    radius: win.radius + 1
    color: win.pal.ink
    antialiasing: false
  }
  // внешняя рамка
  Rectangle {
    anchors.fill: parent
    radius: win.radius
    color: win.lit ? win.pal.hi : win.pal.frame
    antialiasing: false
  }
  // заливка-градиент
  Rectangle {
    id: fill
    anchors.fill: parent
    anchors.margins: win.thick
    radius: Math.max(0, win.radius - win.thick)
    antialiasing: false
    opacity: win.opacityFill
    gradient: Gradient {
      GradientStop { position: 0; color: win.pal.w1 }
      GradientStop { position: 1; color: win.pal.w2 }
    }
    // внутренняя рамка
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: "transparent"
      border.width: 1
      border.color: win.pal.frame2
      antialiasing: false
    }
  }
  Item {
    id: inner
    anchors.fill: parent
    anchors.margins: win.thick + win.pad
  }
}
