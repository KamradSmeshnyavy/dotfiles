import QtQuick
import QtQuick.Effects
import qs.Commons

// Liquid — стеклянная карточка по мотивам лаунчера Vitreus (github.com/natepayn3/Vitreus, MIT; код свой): сверху
// крупные часы, поиск-пилюля с подписью раздела, под ней — подсказки быстрых режимов, ниже строки с иконкой, названием
// и описанием; выбранная залита акцентом. Карточка полупрозрачная — за ней размывает Hyprland (layer_rule
// omarchy-menu в apps/hyprland/windows.lua), фон вокруг почти прозрачный, чтобы размывалась только она.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color fg: root.foreground
  readonly property color glassFill: Qt.rgba(root.background.r, root.background.g, root.background.b, 0.42)
  readonly property color rim: Qt.rgba(1, 1, 1, 0.28)
  readonly property int rowH: Math.round(60 * k)

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

  // почти прозрачный фон: ниже порога ignore_alpha размытие не идёт
  Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.12) }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: card
    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height * 0.14 + 30 * k * (1 - root.t)
    opacity: root.t
    scale: 0.96 + 0.04 * root.t
    width: Math.round(680 * k)
    height: Math.min(parent.height * 0.76, head.height + search.height + hints.height + list.contentHeight + foot.height + 110 * k)
    radius: 30 * k
    color: root.glassFill
    border { width: 1; color: root.rim }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // блик по верхней кромке — «жидкое стекло»
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: 60 * k
      radius: card.radius
      gradient: Gradient {
        GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.16) }
        GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
      }
    }

    // шапка: заголовок меню слева, часы справа
    Item {
      id: head
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 26 * k }
      height: 52 * k
      Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7 * k
        Repeater {
          model: 4
          Rectangle { required property int index; width: index === 2 ? 26 * k : 10 * k; height: 10 * k; radius: 5 * k; color: index === 2 ? root.accent : Qt.rgba(1, 1, 1, index < 2 ? 0.85 : 0.35) }
        }
      }
      Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 8 * k
        Text { id: hh; text: Qt.formatTime(clockTick.now, "HH:mm"); color: root.fg; font { family: root.fontFamily; pixelSize: 40 * k; weight: Font.Bold } }
        Column {
          anchors.verticalCenter: hh.verticalCenter
          Text { text: Qt.locale().toString(clockTick.now, "ddd").toUpperCase(); color: Util.alpha(root.fg, 0.75); font { family: root.fontFamily; pixelSize: 12 * k; weight: Font.DemiBold } }
          Text { text: Qt.formatDate(clockTick.now, "d MMM"); color: Util.alpha(root.fg, 0.6); font { family: root.fontFamily; pixelSize: 12 * k } }
        }
      }
      QtObject { id: clockTick; property date now: new Date() }
      Timer { interval: 10000; running: root.live; repeat: true; triggeredOnStart: true; onTriggered: clockTick.now = new Date() }
    }

    // поиск-пилюля
    Rectangle {
      id: search
      anchors { left: parent.left; right: parent.right; top: head.bottom; margins: 22 * k; topMargin: 16 * k }
      height: 56 * k
      radius: height / 2
      color: Qt.rgba(1, 1, 1, 0.12)
      border { width: 1; color: Qt.rgba(1, 1, 1, 0.18) }
      Text { id: lens; x: 22 * k; anchors.verticalCenter: parent.verticalCenter; text: "󰍉"; color: root.accent; font { family: root.mono; pixelSize: 22 * k } }
      Text {
        anchors { left: lens.right; leftMargin: 14 * k; right: mode.left; rightMargin: 10 * k; verticalCenter: parent.verticalCenter }
        textFormat: Text.PlainText
        elide: Text.ElideLeft
        text: root.query.length ? root.query : "Search…"
        color: root.query.length ? root.fg : Util.alpha(root.fg, 0.5)
        font { family: root.fontFamily; pixelSize: 18 * k }
      }
      Text {
        id: mode
        anchors { right: parent.right; rightMargin: 22 * k; verticalCenter: parent.verticalCenter }
        text: root.title || "Apps"
        color: root.accent
        font { family: root.fontFamily; pixelSize: 13 * k; weight: Font.DemiBold }
      }
    }

    // быстрые режимы — по первому символу поиска (Modes.js)
    Row {
      id: hints
      anchors { horizontalCenter: parent.horizontalCenter; top: search.bottom; topMargin: 12 * k }
      spacing: 18 * k
      Repeater {
        model: [["=", "calc"], [":", "emoji"], ["@", "windows"], ["!", "web"], [";", "clipboard"], [">", "commands"]]
        Row {
          required property var modelData
          spacing: 6 * k
          readonly property bool on: root.query.charAt(0) === modelData[0]
          Text { text: parent.modelData[0]; color: root.accent; font { family: root.mono; pixelSize: 13 * k; weight: Font.Bold } }
          Text { text: parent.modelData[1]; color: parent.on ? root.fg : Util.alpha(root.fg, 0.6); font { family: root.fontFamily; pixelSize: 12 * k } }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: hints.bottom; bottom: foot.top; margins: 16 * k; topMargin: 14 * k }
      clip: true
      spacing: 6 * k
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
        radius: 18 * root.k
        color: on ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.45) : Qt.rgba(1, 1, 1, area.containsMouse ? 0.1 : 0.05)
        border { width: 1; color: on ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.8) : Qt.rgba(1, 1, 1, 0.08) }
        Behavior on color { ColorAnimation { duration: 120 } }

        RowIcon {
          id: ico
          x: 14 * root.k
          anchors.verticalCenter: parent.verticalCenter
          size: 36 * root.k
          kind: row.kind
          glyph: row.icon
          glyphFont: row.iconFont
          appIcon: row.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: Math.abs(row.index - root.selectedIndex) < 30
          fallback: row.label.length ? row.label.charAt(0).toUpperCase() : "•"
          color: row.on ? root.fg : Util.alpha(root.fg, 0.85)
        }
        Column {
          anchors { left: ico.right; leftMargin: 14 * root.k; right: parent.right; rightMargin: 16 * root.k; verticalCenter: parent.verticalCenter }
          spacing: 2 * root.k
          Text { width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.label; color: root.fg; font { family: root.fontFamily; pixelSize: 16 * root.k; weight: Font.DemiBold } }
          Text { visible: row.detail.length > 0; width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.detail; color: Util.alpha(root.fg, 0.65); font { family: root.fontFamily; pixelSize: 12 * root.k } }
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
      color: Util.alpha(root.fg, 0.6)
      font { family: root.fontFamily; pixelSize: 14 * k }
    }

    Item {
      id: foot
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 22 * k }
      height: 20 * k
      Text { text: "↑↓ move  ·  Enter open  ·  Esc close"; color: Util.alpha(root.fg, 0.55); font { family: root.fontFamily; pixelSize: 12 * k } }
      Text { anchors.right: parent.right; text: root.count ? (root.selectedIndex + 1) + " / " + root.count : ""; color: Util.alpha(root.fg, 0.55); font { family: root.fontFamily; pixelSize: 12 * k } }
    }
  }
}
