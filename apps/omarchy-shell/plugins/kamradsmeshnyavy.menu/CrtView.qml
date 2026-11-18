import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// crt — лаунчер по мотивам стиля Retro из elifouts/Dotfiles (GPL-3.0 — его Retro/launcher/Launcher.qml и
// retro/launcher-default.png; код свой): нумерованное «Program menu» старой машины в двойной рамке по центру экрана.
// Шапка «MAIN» (Tab — «COMMAND»: команды лаунчера, префикс «>») и «A1», строка «Program menu · user@host»,
// «Select one of the following:», до 9 строк «N. Имя  — описание» (выбранная залита акцентом), подсказки
// «Tab-Commands  Esc-End», «Ready for option number or program name», строка ввода «> запрос█» с мигающим курсором,
// внизу «SYS-0059  59 programs indexed» и «1/9». Окно раскрывается из черты (его масштаб по Y). Цифра 1–9 при пустой
// строке — сразу запуск (digitLaunch, Menu.qml), стрелки / Enter — как у остальных видов (SkinBase).
SkinBase {
  id: root

  readonly property string term: Qt.fontFamilies().indexOf("Terminess Nerd Font Mono") !== -1 ? "Terminess Nerd Font Mono" : root.mono
  readonly property int size: 14
  readonly property int rowH: 22
  readonly property int rows: 9
  readonly property bool tabCmd: true     // Menu.qml: Tab — «Program menu» ↔ «Shell commands» (префикс «>»)
  readonly property bool digitLaunch: true // Menu.qml: цифра при пустой строке — запуск строки
  readonly property bool cmd: root.query.charAt(0) === ">"
  readonly property string typed: cmd ? root.query.slice(1) : root.query
  function a(c, k) { return Qt.rgba(c.r, c.g, c.b, k) }
  readonly property color dim: a(root.foreground, 0.5)
  readonly property color low: a(root.accent, 0.18)
  readonly property color line: a(root.accent, 0.55)
  readonly property string host: hostFile.text().trim() || "sys"
  FileView { id: hostFile; path: "/etc/hostname"; printErrors: false }

  // раскрытие: его Scale yScale 0.04 → 1, xScale 0.6 → 1
  property real t: 0
  onWoke: { t = 0; grow.restart() }
  Component.onCompleted: grow.restart()
  NumberAnimation { id: grow; target: root; property: "t"; from: 0; to: 1; duration: 150 }

  // мигание курсора (его Blink: 530 мс, сброс при наборе)
  property bool blink: true
  Timer { id: blinker; interval: 530; repeat: true; running: root.live; onTriggered: root.blink = !root.blink }
  onQueryChanged: { blink = true; blinker.restart() }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  component T: Text {
    font.family: root.term
    font.pixelSize: root.size
    color: root.foreground
    textFormat: Text.PlainText
    verticalAlignment: Text.AlignVCenter
  }

  Rectangle {
    id: frame
    anchors.centerIn: parent
    width: Math.min(760, root.width - 80)
    height: col.implicitHeight + 36
    color: root.background
    opacity: root.t
    transform: Scale { origin.x: frame.width / 2; origin.y: frame.height / 2; yScale: 0.04 + 0.96 * Math.min(1, root.t * 1.4); xScale: Math.min(1, 0.6 + root.t) }
    border.width: 1
    border.color: root.line
    Rectangle { anchors.fill: parent; anchors.margins: 3; color: "transparent"; border.width: 1; border.color: root.line }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    Column {
      id: col
      x: 22; y: 16
      width: parent.width - 44
      spacing: 4

      Item {
        width: parent.width; height: 22
        T { anchors.horizontalCenter: parent.horizontalCenter; height: parent.height; text: root.cmd ? "COMMAND" : "MAIN"; color: root.accent; font.letterSpacing: 1 }
        T { anchors.right: parent.right; height: parent.height; text: root.cmd ? "C1" : "A1"; color: root.dim; font.letterSpacing: 1 }
      }
      T {
        anchors.horizontalCenter: parent.horizontalCenter
        text: (root.cmd ? "Shell commands" : (root.title && root.title !== "Apps" && root.title !== "Go" ? root.title : "Program menu")) + "  ·  " + Quickshell.env("USER") + "@" + root.host
      }
      Item { width: 1; height: 6 }
      T { text: root.cmd ? "Run one of the following:" : "Select one of the following:" }
      Item { width: 1; height: 4 }

      ListView {
        id: list
        width: parent.width
        height: root.rows * root.rowH
        interactive: false
        clip: true
        model: root.rowModel
        currentIndex: root.selectedIndex
        highlightFollowsCurrentItem: false
        boundsBehavior: Flickable.StopAtBounds
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
        delegate: Item {
          id: row
          required property int index
          required property string label
          required property string detail
          readonly property bool on: root.cursorActive && index === root.selectedIndex
          width: list.width
          height: root.rowH
          Rectangle { x: 18; width: parent.width - 18; height: parent.height; color: row.on ? root.accent : hov.containsMouse ? root.low : "transparent" }
          T {
            x: 24; width: parent.width - 30; height: parent.height
            elide: Text.ElideRight
            text: (row.index + 1) + ". " + row.label + (row.detail ? "  — " + row.detail : "")
            color: row.on ? root.background : root.foreground
          }
          MouseArea {
            id: hov
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
            onPositionChanged: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
            onClicked: root.activated(row.index)
          }
        }
        T {
          visible: root.count === 0 && root.query !== ""
          x: 24; height: root.rowH
          text: root.cmd ? "SYS-0127  Bad command or file name" : "SYS-0404  No match for that name"
          color: Color.urgent
        }
      }

      Item { width: 1; height: 8 }
      Row {
        spacing: 34
        T { text: "Tab-" + (root.cmd ? "Programs" : "Commands"); color: root.dim }
        T { text: "Esc-End"; color: root.dim }
        T { text: "?-Help"; color: root.dim }
      }
      T { text: "Ready for option number or " + (root.cmd ? "command" : "program name") }
      Row {
        spacing: 8
        height: 24
        T { anchors.verticalCenter: parent.verticalCenter; text: ">"; color: root.accent; font.pixelSize: root.size + 2 }
        T { id: q; anchors.verticalCenter: parent.verticalCenter; text: root.typed; font.pixelSize: root.size + 2 }
        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 9; height: 18; color: root.accent; opacity: root.blink ? 1 : 0 }
      }
      Rectangle { width: parent.width; height: 1; color: root.low }
      Item {
        width: parent.width; height: 20
        T { height: parent.height; text: "SYS-" + String(root.count).padStart(4, "0") + "  " + root.count + (root.cmd ? " commands" : " programs") + " indexed"; color: root.dim; font.pixelSize: root.size - 2 }
        T { anchors.right: parent.right; height: parent.height; text: (root.count ? root.selectedIndex + 1 : 0) + "/" + root.count; color: root.dim; font.pixelSize: root.size - 2 }
      }
    }
  }
}
