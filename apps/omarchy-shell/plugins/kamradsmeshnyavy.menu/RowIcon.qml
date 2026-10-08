import QtQuick
import qs.Commons

// One row's icon, whatever the row is: an app's themed image, or the Nerd Font
// glyph a menu row carries. Every skin needs exactly this, and getting the
// image half wrong (async loads, low-res decode) crashes or blurs.
Item {
  id: root

  property string kind: ""
  property string glyph: ""
  property string glyphFont: ""
  property string appIcon: ""
  property var resolver: null
  property string fontFamily: Style.font.menuFamily
  property color color: "white"
  property real size: 32
  // Skins that lay out every row at once only load images near the cursor;
  // a cold Apps list would otherwise decode a hundred icons in one frame.
  property bool load: true
  // Shown when a row has no glyph at all.
  property string fallback: ""

  readonly property bool isApp: root.kind === "app"
  readonly property bool ready: root.isApp && image.status === Image.Ready

  implicitWidth: root.size
  implicitHeight: root.size

  Image {
    id: image
    anchors.fill: parent
    visible: root.isApp
    fillMode: Image.PreserveAspectFit
    // Synchronous on purpose: themed icons resolved off-thread by two views
    // at once abort Quickshell inside QIcon::pixmap.
    asynchronous: false
    sourceSize.width: Math.max(16, Math.round(root.size * Screen.devicePixelRatio))
    sourceSize.height: Math.max(16, Math.round(root.size * Screen.devicePixelRatio))
    source: root.isApp && root.load && root.resolver ? root.resolver(root.appIcon) : ""
  }

  Text {
    anchors.centerIn: parent
    visible: !root.isApp || (root.load && image.status !== Image.Ready && image.status !== Image.Loading)
    textFormat: Text.PlainText
    text: !root.isApp && root.glyph.length > 0 ? root.glyph : root.fallback
    color: root.color
    font.family: root.glyphFont.length > 0 ? root.glyphFont : root.fontFamily
    font.pixelSize: Math.round(root.size * 0.82)
    font.bold: root.isApp || root.glyph.length === 0
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }
}
