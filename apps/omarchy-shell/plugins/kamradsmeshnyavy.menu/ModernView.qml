import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.Commons

// modern — лаунчер по мотивам стиля Modern из elifouts/Dotfiles (GPL-3.0 — его Modern/launcher: shell.qml, Radial.qml,
// HomePage.qml, AppGrid.qml, v2/launcher-*.png; код свой): карточка матового стекла 580 × 800 со скруглением 20. Сверху
// строка поиска «🔍 запрос  Enter to run»; на главном экране — его циферблат: разделы меню по кругу (кружки 56 px на
// окружности), выбранный — акцентом, в центре — его значок крупно, имя и описание; в разделе «Apps» — сетка значков,
// в остальных и при поиске — список. Внизу вкладки Home / Apps / Commands / Keybinds: Home и Apps открывают разделы,
// Commands — префикс «>», Keybinds — шпаргалка сочетаний Omarchy. Колесо / стрелки — по кругу, Enter — запуск.
SkinBase {
  id: root

  readonly property string ui: Qt.fontFamilies().indexOf("CodeNewRoman Nerd Font Propo") !== -1 ? "CodeNewRoman Nerd Font Propo"
    : Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.fontFamily
  function a(c, k) { return Qt.rgba(c.r, c.g, c.b, k) }
  readonly property bool home: root.title === "Omarchy" && root.query === ""
  readonly property bool apps: root.title === "Apps" && root.query.charAt(0) !== ">"
  readonly property bool cmd: root.query.charAt(0) === ">"
  readonly property bool radial: home  // Menu.qml: ↑↓ ходят по кругу
  readonly property bool tabCmd: true  // Tab — команды «>»

  // вкладки — сигналы Menu.qml (menuRequested / filterRequested / runRequested)
  signal menuRequested(string id)
  signal filterRequested(string text)
  signal runRequested(var cmd)

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: card
    anchors.horizontalCenter: parent.horizontalCenter
    y: (parent.height - height) / 2 + (1 - root.t) * 30
    width: 580
    height: Math.min(800, parent.height - 80)
    radius: 20
    opacity: root.t
    color: root.a(root.background, 0.6)
    border.width: 1
    border.color: root.a(root.foreground, 0.08)
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // поиск
    Row {
      x: 28; y: 26
      height: 40
      spacing: 14
      Rectangle {
        width: 40; height: 40; radius: 20
        color: root.a(root.foreground, 0.08)
        Text { anchors.centerIn: parent; text: "󰍉"; font.family: root.ui; font.pixelSize: 17; color: root.foreground }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.query !== "" ? root.query : root.home ? "Home" : root.title
        font.family: root.ui; font.pixelSize: 20
        color: root.query !== "" ? root.foreground : root.a(root.foreground, 0.85)
      }
    }
    Text {
      anchors.right: parent.right; anchors.rightMargin: 28; y: 36
      text: "Enter to run"; font.family: root.ui; font.pixelSize: 13; color: root.a(root.foreground, 0.35)
    }

    // ── главный экран: циферблат ──
    Item {
      id: dial
      visible: root.home
      x: 0; y: 90
      width: card.width; height: card.height - 90 - 80
      readonly property int n: Math.min(10, root.count)
      readonly property real r: Math.min(width, height) / 2 - 64
      Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath { strokeWidth: 1; strokeColor: root.a(root.foreground, 0.08); fillColor: "transparent"
          PathAngleArc { centerX: dial.width / 2; centerY: dial.height / 2; radiusX: dial.r; radiusY: dial.r; startAngle: 0; sweepAngle: 360 } }
      }
      Repeater {
        model: dial.n
        Rectangle {
          id: dot
          required property int index
          readonly property var row: root.rowAt(index)
          readonly property bool on: index === root.selectedIndex
          readonly property real ang: -Math.PI / 2 + index * 2 * Math.PI / dial.n
          width: on ? 84 : 72; height: width; radius: width / 2
          x: dial.width / 2 + Math.cos(ang) * dial.r - width / 2
          y: dial.height / 2 + Math.sin(ang) * dial.r - height / 2
          color: on ? root.a(root.accent, 0.5) : da.containsMouse ? root.a(root.foreground, 0.12) : root.a(root.foreground, 0.06)
          border.width: on ? 2 : 0
          border.color: root.a(root.accent, 0.7)
          Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
          RowIcon {
            anchors.centerIn: parent
            size: 26
            kind: dot.row ? dot.row.kind : ""
            glyph: dot.row ? dot.row.icon : ""
            glyphFont: dot.row ? dot.row.iconFont : ""
            appIcon: dot.row ? dot.row.appIcon : ""
            resolver: root.iconResolver
            fontFamily: root.ui
            color: root.foreground
          }
          MouseArea {
            id: da
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverSelect(dot.index, mapToItem(root, mouseX, mouseY))
            onClicked: root.activated(dot.index)
          }
        }
      }
      // центр: выбранный раздел
      Column {
        anchors.centerIn: parent
        spacing: 8
        readonly property var row: root.rowAt(root.selectedIndex)
        RowIcon {
          anchors.horizontalCenter: parent.horizontalCenter
          size: 52
          kind: parent.row ? parent.row.kind : ""
          glyph: parent.row ? parent.row.icon : ""
          glyphFont: parent.row ? parent.row.iconFont : ""
          appIcon: parent.row ? parent.row.appIcon : ""
          resolver: root.iconResolver
          fontFamily: root.ui
          color: root.accent
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.row ? parent.row.label : ""; font.family: root.ui; font.pixelSize: 22; color: root.foreground }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.row ? (parent.row.detail || "") : ""; font.family: root.ui; font.pixelSize: 13; color: root.a(root.foreground, 0.4) }
      }
    }

    // ── приложения: сетка; остальное — список ──
    GridView {
      id: grid
      visible: root.apps && !root.home
      x: 24; y: 90
      width: card.width - 48; height: card.height - 90 - 84
      clip: true
      cellWidth: width / 4
      cellHeight: 112
      model: root.rowModel
      currentIndex: root.selectedIndex
      interactive: false
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
      delegate: Item {
        id: cellItem
        required property int index
        required property string label
        required property string kind
        required property string icon
        required property string appIcon
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: grid.cellWidth; height: grid.cellHeight
        Rectangle { anchors.fill: parent; anchors.margins: 6; radius: 14; color: cellItem.on ? root.a(root.accent, 0.35) : ca.containsMouse ? root.a(root.foreground, 0.08) : "transparent" }
        RowIcon { anchors.horizontalCenter: parent.horizontalCenter; y: 20; size: 44; kind: cellItem.kind; glyph: cellItem.icon; appIcon: cellItem.appIcon; resolver: root.iconResolver; fontFamily: root.ui; color: root.foreground }
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 74; width: parent.width - 16; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: cellItem.label; font.family: root.ui; font.pixelSize: 12; color: root.foreground }
        MouseArea { id: ca; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(cellItem.index, mapToItem(root, mouseX, mouseY)); onClicked: root.activated(cellItem.index) }
      }
    }
    ListView {
      id: list
      visible: !root.home && !root.apps
      x: 24; y: 90
      width: card.width - 48; height: card.height - 90 - 84
      clip: true
      interactive: false
      spacing: 4
      model: root.rowModel
      currentIndex: root.selectedIndex
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
      delegate: Item {
        id: rowItem
        required property int index
        required property string label
        required property string detail
        required property string kind
        required property string icon
        required property string appIcon
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: list.width; height: 52
        Rectangle { anchors.fill: parent; radius: 12; color: rowItem.on ? root.a(root.accent, 0.3) : ra.containsMouse ? root.a(root.foreground, 0.07) : "transparent" }
        RowIcon { x: 14; anchors.verticalCenter: parent.verticalCenter; size: 26; kind: rowItem.kind; glyph: rowItem.icon; appIcon: rowItem.appIcon; resolver: root.iconResolver; fontFamily: root.ui; color: root.foreground }
        Column {
          x: 54; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 70
          Text { width: parent.width; elide: Text.ElideRight; text: rowItem.label; font.family: root.ui; font.pixelSize: 14; color: root.foreground }
          Text { visible: text !== ""; width: parent.width; elide: Text.ElideRight; text: rowItem.detail; font.family: root.ui; font.pixelSize: 11; color: root.a(root.foreground, 0.45) }
        }
        MouseArea { id: ra; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(rowItem.index, mapToItem(root, mouseX, mouseY)); onClicked: root.activated(rowItem.index) }
      }
      Text { visible: root.count === 0 && root.query !== ""; x: 14; y: 14; text: root.emptyText(); font.family: root.ui; font.pixelSize: 13; color: root.a(root.foreground, 0.45) }
    }

    // вкладки
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom; anchors.bottomMargin: 22
      spacing: 8
      Repeater {
        model: [["home", "󰋜", "Home"], ["apps", "󰀻", "Apps"], ["cmd", "󰆍", "Commands"], ["keys", "󰌌", "Keybinds"]]
        Rectangle {
          required property var modelData
          readonly property bool on: modelData[0] === "home" ? root.home : modelData[0] === "apps" ? root.apps : modelData[0] === "cmd" ? root.cmd : false
          width: 118; height: 40; radius: 12
          color: on ? root.a(root.accent, 0.35) : tba.containsMouse ? root.a(root.foreground, 0.07) : "transparent"
          Text { anchors.centerIn: parent; text: parent.modelData[1] + "  " + parent.modelData[2]; font.family: root.ui; font.pixelSize: 13; color: parent.on ? root.foreground : root.a(root.foreground, 0.45) }
          MouseArea {
            id: tba; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
              var k = parent.modelData[0]
              if (k === "home") root.menuRequested("root")
              else if (k === "apps") root.menuRequested("apps")
              else if (k === "cmd") root.filterRequested(">")
              else root.runRequested(["omarchy-menu-keybindings"])
            }
          }
        }
      }
    }
  }
}
