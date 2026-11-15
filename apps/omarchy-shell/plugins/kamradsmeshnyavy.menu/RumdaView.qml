import QtQuick
import qs.Commons

// rumda — лаунчер по мотивам Rumda (github.com/hexonide/rumda, без лицензии — только облик, код свой): маленькое окно
// по центру с квадратными углами и рамкой 2 px светлым акцентом, поле «Search...» с подсказкой цветом акцента, ниже —
// одни названия (без значков и описаний, как у его rofi), выбранная строка залита акцентом, текст на ней — цветом фона.
// Шрифт — пиксельный Dogica Pixel, если он есть.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color ink: root.foreground
  readonly property color panel: Qt.rgba(Qt.darker(root.background, 1.05).r, Qt.darker(root.background, 1.05).g, Qt.darker(root.background, 1.05).b, 1)
  readonly property color line: Util.alpha(root.foreground, 0.2)
  readonly property string px: Qt.fontFamilies().indexOf("Dogica Pixel") !== -1 ? "Dogica Pixel" : root.fontFamily
  readonly property int rowH: Math.round(30 * k)
  readonly property bool clipMode: root.query.charAt(0) === ";"

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

  Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.35 * root.t) }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: win
    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round((parent.height - height) / 2) + Math.round(8 * k * (1 - root.t))
    opacity: root.t
    width: Math.round(parent.width * 0.22)
    height: Math.round(parent.height * 0.34)
    color: root.background
    border { width: 2; color: Qt.lighter(root.accent, 1.35) }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // поле ввода с блочным курсором
    Rectangle {
      id: field
      anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 10 * k; rightMargin: 10 * k; topMargin: 10 * k }
      height: 30 * k
      color: Util.alpha(root.ink, 0.06)
      border { width: 0; color: "transparent" }
      Row {
        x: 8 * k; anchors.verticalCenter: parent.verticalCenter
        spacing: 2 * k
        Text {
          visible: root.query.length > 0
          anchors.verticalCenter: parent.verticalCenter
          textFormat: Text.PlainText
          text: root.query
          color: root.ink
          font { family: root.px; pixelSize: 15 * k }
        }
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 7 * k; height: 16 * k
          color: root.ink
          opacity: blink.on ? 0.9 : 0
          QtObject { id: blink; property bool on: true }
          Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
        }
        Text {
          visible: root.query.length === 0
          anchors.verticalCenter: parent.verticalCenter
          text: "Search..."
          color: root.accent
          font { family: root.px; pixelSize: 15 * k }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: field.bottom; bottom: parent.bottom; leftMargin: 10 * k; rightMargin: 10 * k; topMargin: 8 * k; bottomMargin: 8 * k }
      clip: true
      spacing: 0
      model: root.rowModel
      currentIndex: root.selectedIndex
      highlightFollowsCurrentItem: false
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

      delegate: Rectangle {
        id: row
        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label
        required property string detail
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: list.width
        height: root.rowH
        radius: 1
        color: on ? root.accent : area.containsMouse ? Util.alpha(root.ink, 0.08) : "transparent"

        RowIcon {
          id: ico
          visible: false
          width: 0
          x: 8 * root.k
          anchors.verticalCenter: parent.verticalCenter
          size: 18 * root.k
          kind: row.kind
          glyph: row.icon
          glyphFont: row.iconFont
          appIcon: row.appIcon
          resolver: root.iconResolver
          fontFamily: root.px
          load: Math.abs(row.index - root.selectedIndex) < 30
          fallback: row.label.length ? row.label.charAt(0).toUpperCase() : "•"
          color: row.on ? root.background : root.ink
        }
        Row {
          anchors { left: parent.left; leftMargin: 10 * root.k; right: parent.right; rightMargin: 8 * root.k; verticalCenter: parent.verticalCenter }
          spacing: 10 * root.k
          Text { id: nm; textFormat: Text.PlainText; text: row.label; color: row.on ? root.background : root.ink; font { family: root.px; pixelSize: 11 * root.k } }
          Text {
            visible: false
            width: parent.width - nm.width - 10 * root.k
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: row.detail
            color: row.on ? Util.alpha(root.background, 0.75) : Util.alpha(root.ink, 0.45)
            font { family: root.px; pixelSize: 14 * root.k }
          }
        }
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onPositionChanged: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onClicked: root.activated(row.index)
        }
      }
    }
    Text {
      visible: root.count === 0
      anchors.centerIn: list
      text: root.emptyText()
      color: Util.alpha(root.ink, 0.5)
      font { family: root.px; pixelSize: 14 * k }
    }

  }
}
