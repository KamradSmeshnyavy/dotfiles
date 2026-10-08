import QtQuick

// The typed filter, drawn inside a skin's own search box. The menu owns the
// keyboard, so skins show the query rather than hosting a TextInput.
Item {
  id: root

  property string query: ""
  property string placeholder: "Search…"
  property color color: "white"
  property color placeholderColor: "gray"
  property color caretColor: root.color
  property string fontFamily: ""
  property real pixelSize: 14
  property bool bold: false
  property bool live: true
  property bool caret: true
  property int alignment: Text.AlignLeft

  implicitHeight: label.implicitHeight
  implicitWidth: label.implicitWidth + caretBar.width + 2

  Text {
    id: label
    anchors.verticalCenter: parent.verticalCenter
    x: root.alignment === Text.AlignHCenter ? Math.max(0, (root.width - width - caretBar.width) / 2) : 0
    width: Math.min(implicitWidth, root.width - caretBar.width - 2)
    textFormat: Text.PlainText
    elide: Text.ElideLeft
    text: root.query.length > 0 ? root.query : root.placeholder
    color: root.query.length > 0 ? root.color : root.placeholderColor
    font.family: root.fontFamily
    font.pixelSize: root.pixelSize
    font.bold: root.bold && root.query.length > 0
  }

  Rectangle {
    id: caretBar
    visible: root.caret
    anchors.verticalCenter: parent.verticalCenter
    x: root.query.length > 0 ? label.x + label.width + 2 : label.x - 1
    width: Math.max(2, Math.round(root.pixelSize * 0.12))
    height: Math.round(root.pixelSize * 1.15)
    color: root.caretColor
    SequentialAnimation on opacity {
      loops: Animation.Infinite
      running: root.live && root.caret
      NumberAnimation { to: 1; duration: 60 }
      PauseAnimation { duration: 480 }
      NumberAnimation { to: 0; duration: 60 }
      PauseAnimation { duration: 400 }
    }
  }
}
