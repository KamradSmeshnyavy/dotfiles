import QtQuick
import qs.Commons

// yami — окно лаунчера по мотивам yami (github.com/Trendorin/yami, MIT; код свой): графитовая панель с рамкой в пиксель
// и жёсткой пиксельной тенью, шапка «■ apps 43» с вкладками APPS / CLIPBOARD (горит та, в каком режиме поиск: буфер —
// по «;») и крестиком, поле ввода с блочным курсором, строки «значок · название · описание» (выбранная залита
// светлым), внизу подсказки быстрых режимов. Шрифт — пиксельный Tiny5, если он есть.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color ink: root.foreground
  readonly property color panel: Qt.rgba(Qt.darker(root.background, 1.05).r, Qt.darker(root.background, 1.05).g, Qt.darker(root.background, 1.05).b, 1)
  readonly property color line: Util.alpha(root.foreground, 0.2)
  readonly property string px: Qt.fontFamilies().indexOf("Tiny5") !== -1 ? "Tiny5" : root.fontFamily
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

  // жёсткая тень
  Rectangle { x: win.x + 4; y: win.y + 4; width: win.width; height: win.height; color: Qt.rgba(0, 0, 0, 0.55); opacity: root.t }
  Rectangle {
    id: win
    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round(parent.height * 0.28) + Math.round(8 * k * (1 - root.t))
    opacity: root.t
    width: Math.round(640 * k)
    height: Math.min(parent.height * 0.62, head.height + field.height + list.contentHeight + foot.height + 48 * k)
    color: root.panel
    border { width: 1; color: root.line }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // шапка
    Item {
      id: head
      anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 12 * k; rightMargin: 8 * k }
      height: 30 * k
      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6 * k
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 6 * k; height: 6 * k; color: root.ink; opacity: 0.6 }
        Text { text: (root.title || "apps").toLowerCase(); color: root.ink; font { family: root.px; pixelSize: 14 * k } }
        Text { text: root.count; color: Util.alpha(root.ink, 0.45); font { family: root.px; pixelSize: 14 * k } }
      }
      Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 5 * k
        Repeater {
          model: [["APPS", !root.clipMode], ["CLIPBOARD", root.clipMode]]
          Rectangle {
            required property var modelData
            width: tab.implicitWidth + 10 * k; height: 20 * k
            color: modelData[1] ? Util.alpha(root.ink, 0.55) : "transparent"
            border { width: 1; color: Util.alpha(root.ink, modelData[1] ? 0.7 : 0.25) }
            Text { id: tab; anchors.centerIn: parent; text: parent.modelData[0]; color: parent.modelData[1] ? root.background : root.ink; font { family: root.px; pixelSize: 13 * k } }
          }
        }
        Rectangle {
          width: 20 * k; height: 20 * k
          color: xArea.containsMouse ? Util.alpha(root.ink, 0.2) : "transparent"
          border { width: 1; color: Util.alpha(root.ink, 0.35) }
          Text { anchors.centerIn: parent; text: "✕"; color: root.ink; font { family: root.px; pixelSize: 13 * k } }
          MouseArea { id: xArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.dismissRequested() }
        }
      }
    }

    // поле ввода с блочным курсором
    Rectangle {
      id: field
      anchors { left: parent.left; right: parent.right; top: head.bottom; leftMargin: 12 * k; rightMargin: 12 * k; topMargin: 6 * k }
      height: 30 * k
      color: Qt.darker(root.panel, 1.25)
      border { width: 1; color: Util.alpha(root.ink, 0.35) }
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
          text: "type… Enter — launch"
          color: Util.alpha(root.ink, 0.4)
          font { family: root.px; pixelSize: 15 * k }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: field.bottom; bottom: foot.top; leftMargin: 12 * k; rightMargin: 12 * k; topMargin: 8 * k; bottomMargin: 4 * k }
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
        color: on ? Util.alpha(root.ink, 0.42) : area.containsMouse ? Util.alpha(root.ink, 0.08) : "transparent"
        border { width: on ? 1 : 0; color: Util.alpha(root.ink, 0.65) }

        RowIcon {
          id: ico
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
          anchors { left: ico.right; leftMargin: 10 * root.k; right: parent.right; rightMargin: 8 * root.k; verticalCenter: parent.verticalCenter }
          spacing: 10 * root.k
          Text { id: nm; textFormat: Text.PlainText; text: row.label; color: row.on ? root.background : root.ink; font { family: root.px; pixelSize: 15 * root.k } }
          Text {
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

    Text {
      id: foot
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 12 * k; rightMargin: 12 * k; bottomMargin: 8 * k }
      elide: Text.ElideRight
      text: "Enter — launch · = calculate · > command · @ windows · ! web · : emoji · ; clipboard"
      color: Util.alpha(root.ink, 0.45)
      font { family: root.px; pixelSize: 13 * k }
    }
  }
}
