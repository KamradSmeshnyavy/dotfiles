import QtQuick
import Quickshell
import qs.Commons

// surface — лаунчер по мотивам rofi-лаунчера surface-dots (snes19xx, «type 7» adi1090x; README разрешает брать со
// ссылкой; код свой): узкая панель у левого нижнего угла. Сверху — шапка-картинка (у него — картинки с Pinterest,
// здесь — текущие обои) с полупрозрачной пилюлей поиска; ниже — четыре круглые кнопки (приложения — активна, файлы,
// окна, веб); дальше — список: значок и название моноширинным шрифтом, выбранная строка — пилюля акцентом с
// градиентом и тонкой рамкой. Цвета — роли его ThemeEngine из цветов темы.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color ink: root.foreground
  readonly property bool dark: 0.299 * root.background.r + 0.587 * root.background.g + 0.114 * root.background.b < 0.5
  function mix(a, b, t) { return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1) }
  readonly property color item: dark ? mix(root.background, root.foreground, 0.14) : Qt.rgba(0, 0, 0, 0.06)
  readonly property string monoFont: Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.mono
  readonly property int rowH: Math.round(32 * k)

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: win
    x: Math.round(6 * k) - Math.round((1 - root.t) * width * 0.3)
    y: parent.height - height - Math.round(6 * k)
    opacity: root.t
    width: Math.round(Math.max(260 * k, parent.width * 0.155))
    height: Math.round(parent.height * 0.45)
    radius: 10 * k
    color: root.background
    border { width: 1; color: Util.alpha(root.ink, 0.1) }
    clip: true
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // шапка: обои и пилюля поиска
    Item {
      id: head
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: Math.round(parent.height * 0.21)
      clip: true
      Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/.local/state/omarchy/current/background"
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: 600
        asynchronous: true
        cache: false
      }
      Rectangle { anchors.fill: parent; color: Util.alpha(root.background, 0.25) }
      Rectangle {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12 * k; rightMargin: 12 * k }
        height: 30 * k
        radius: height / 2
        color: Util.alpha(root.background, 0.72)
        Row {
          x: 12 * k; anchors.verticalCenter: parent.verticalCenter
          spacing: 8 * k
          Text { anchors.verticalCenter: parent.verticalCenter; text: "\u{F0349}"; color: root.ink; font { family: root.monoFont; pixelSize: 13 * k } }
          Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.query.length ? root.query : "Search"
            color: root.query.length ? root.ink : Util.alpha(root.ink, 0.45)
            font { family: root.monoFont; pixelSize: 12 * k }
          }
          Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 1.5 * k; height: 14 * k
            color: root.ink
            opacity: blink.on ? 0.9 : 0
            QtObject { id: blink; property bool on: true }
            Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
          }
        }
      }
    }

    // кнопки категорий
    Row {
      id: cats
      anchors { top: head.bottom; topMargin: 10 * k; horizontalCenter: parent.horizontalCenter }
      spacing: (win.width - 24 * k - 4 * 36 * k) / 3
      Repeater {
        model: [
          { g: "\uf00a", cmd: "" },
          { g: "\uf07b", cmd: "nautilus --new-window" },
          { g: "\uf2d0", cmd: "omarchy-shell widgets toggleOverview" },
          { g: "\uf1a0", cmd: "xdg-open https://duckduckgo.com" }
        ]
        Rectangle {
          required property var modelData
          required property int index
          width: 36 * k; height: 26 * k; radius: height / 2
          color: index === 0 ? root.accent : ca.containsMouse ? Util.alpha(root.ink, 0.12) : root.item
          Text { anchors.centerIn: parent; text: modelData.g; color: index === 0 ? root.background : root.ink; font { family: root.monoFont; pixelSize: 13 * k } }
          MouseArea {
            id: ca
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (modelData.cmd) { Quickshell.execDetached(["bash", "-c", modelData.cmd]); root.dismissRequested() }
          }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: cats.bottom; bottom: parent.bottom; leftMargin: 10 * k; rightMargin: 10 * k; topMargin: 12 * k; bottomMargin: 10 * k }
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
        radius: 10 * root.k
        color: area.containsMouse && !on ? Util.alpha(root.ink, 0.06) : "transparent"
        border { width: on ? 1 : 0; color: Util.alpha(root.accent, 0.9) }
        gradient: on ? sel : null
        Gradient {
          id: sel
          orientation: Gradient.Horizontal
          GradientStop { position: 0; color: Util.alpha(root.accent, 0.85) }
          GradientStop { position: 1; color: Util.alpha(root.accent, 0.35) }
        }

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
          fontFamily: root.monoFont
          load: Math.abs(row.index - root.selectedIndex) < 30
          fallback: row.label.length ? row.label.charAt(0).toUpperCase() : "•"
          color: root.ink
        }
        Text {
          anchors { left: ico.right; leftMargin: 12 * root.k; right: parent.right; rightMargin: 8 * root.k; verticalCenter: parent.verticalCenter }
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: row.label
          color: row.on && !root.dark ? root.background : root.ink
          font { family: root.monoFont; pixelSize: 11 * root.k }
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
      font { family: root.monoFont; pixelSize: 12 * k }
    }
  }
}
