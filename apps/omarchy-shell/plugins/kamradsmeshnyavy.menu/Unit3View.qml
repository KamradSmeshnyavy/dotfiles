import QtQuick
import Quickshell
import qs.Commons

// unit3 — лаунчер по мотивам меню Unit-3 (samyns/Unit-3, MIT, Copyright (c) 2026 samyns — widgets/Menu.qml; облик и
// размеры оттуда, код переписан под меню Omarchy): бежевый экран поверх стола (#b8af93 на 55 %), по центру лист NieR
// 780 × 540 #d6cfb5 с рамкой чернилами #463f2e и тонкой сеткой 20 px; шапка «SYSTEM — システム» с бегущей строкой
// «время · N ROWS» и «SESSION 0471»; слева колонка: название текущего меню (тёмная плашка), «◂ BACK», счётчик «n/m NODES»
// с качающейся красной чертой; справа «▸ поиск» и список: номер, квадрат со значком, имя и подпись, справа — вид строки
// и «▸»; выбранная строка — чернилами, с красной кромкой слева и сдвигом вправо; снизу TERMINAL · FILES · LOCK · SHUTDOWN
// (у него — выключение сразу, здесь — меню выключения) и подсказки клавиш. Открытие — лист въезжает справа за шторкой,
// по нему пробегает красная строка развёртки.
SkinBase {
  id: root

  readonly property color paper: "#d6cfb5"
  readonly property color ink: "#463f2e"
  readonly property color inkStrong: "#2e2a1f"
  readonly property color inkSoft: "#7a7358"
  readonly property color lineSoft: Qt.rgba(70 / 255, 63 / 255, 46 / 255, 0.25)
  readonly property color lineVsoft: Qt.rgba(70 / 255, 63 / 255, 46 / 255, 0.12)
  readonly property color red: "#6e2a2a"
  readonly property color litInk: Qt.rgba(214 / 255, 207 / 255, 181 / 255, 1)
  function litInkA(a) { return Qt.rgba(214 / 255, 207 / 255, 181 / 255, a) }
  readonly property string nier: Qt.fontFamilies().indexOf("Share Tech Mono") !== -1 ? "Share Tech Mono" : root.mono
  readonly property int lw: 780
  readonly property int lh: 540

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  // значок-символ по имени, как у него (Menu.qml: ico)
  function glyph(label, detail, kind) {
    var n = String(label).toLowerCase(), d = String(detail).toLowerCase()
    if (/terminal|kitty|alacritty|ghostty|console/.test(n + " " + d)) return "▸"
    if (/firefox|chromium|chrome|browser|helium/.test(n + " " + d)) return "○"
    if (/nvim|vim|editor|code|helix|zed/.test(n + " " + d)) return "⌥"
    if (/file|yazi|ranger|nautilus/.test(n + " " + d)) return "▤"
    if (/btop|htop|monitor/.test(n)) return "▲"
    if (/music|audio|pulse|spotify|sound/.test(n + " " + d)) return "♪"
    if (/video|mpv|vlc|player|obs/.test(n + " " + d)) return "▶"
    if (/lock|password|bitwarden|keepass/.test(n + " " + d)) return "⬡"
    if (/libre|office|calc|writer|book|calibre|document/.test(n + " " + d)) return "≡"
    if (/gimp|inkscape|image|photo|draw|krita/.test(n + " " + d)) return "⬜"
    if (/chat|discord|telegram|signal|slack|mail/.test(n + " " + d)) return "○"
    if (/setting|system|config/.test(n + " " + d)) return "◈"
    return root.isBranch(kind) ? "◈" : "·"
  }

  property string clock: Qt.formatTime(new Date(), "HH:mm:ss")
  Timer { interval: 1000; repeat: true; running: root.live; onTriggered: root.clock = Qt.formatTime(new Date(), "HH:mm:ss") }

  // въезд листа справа за шторкой, потом строка развёртки
  property real slide: 0
  property real curtain: 0
  onWoke: { slide = 0; curtain = 0; enter.restart() }
  Component.onCompleted: enter.restart()
  SequentialAnimation {
    id: enter
    ParallelAnimation {
      NumberAnimation { target: root; property: "slide"; from: 0; to: 1; duration: 440; easing.type: Easing.OutExpo }
      NumberAnimation { target: root; property: "curtain"; from: 0; to: 1; duration: 340; easing.type: Easing.OutExpo }
    }
    ScriptAction { script: scan.restart() }
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(184 / 255, 175 / 255, 147 / 255, 0.55)
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
    }
  }

  Item {
    id: host
    width: root.lw
    height: root.lh
    x: (root.width - root.lw) / 2 + (1 - root.slide) * (root.lw + 2)
    y: (root.height - root.lh) / 2
    clip: true

    Rectangle {
      id: sheet
      anchors.fill: parent
      color: root.paper
      border.color: root.ink
      border.width: 1
      MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

      // сетка 20 px
      Repeater { model: Math.floor(root.lw / 20) + 1; Rectangle { x: index * 20; width: 1; height: root.lh; color: root.lineVsoft } }
      Repeater { model: Math.floor(root.lh / 20) + 1; Rectangle { y: index * 20; width: root.lw; height: 1; color: root.lineVsoft } }

      // строка развёртки
      Rectangle {
        id: scanLine
        width: root.lw; height: 2; z: 20; opacity: 0
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 0.5; color: root.red }
          GradientStop { position: 1.0; color: "transparent" }
        }
        NumberAnimation on y { id: scan; from: 0; to: root.lh; duration: 700; running: false; onStarted: scanLine.opacity = 1; onFinished: scanLine.opacity = 0 }
      }

      // ── шапка ──
      Item {
        id: header
        width: parent.width; height: 52
        Row {
          x: 28; anchors.verticalCenter: parent.verticalCenter
          spacing: 14
          Text { text: "SYSTEM"; font { family: root.nier; pixelSize: 11; letterSpacing: 3.5; weight: Font.Medium } color: root.inkStrong }
          Rectangle { width: 24; height: 1; color: root.inkSoft; anchors.verticalCenter: parent.verticalCenter }
          Text { text: "システム"; font { pixelSize: 10; letterSpacing: 2 } color: root.inkSoft }
        }
        Row {
          anchors { right: parent.right; rightMargin: 28; verticalCenter: parent.verticalCenter }
          spacing: 14
          Item {
            width: 120; height: 16; clip: true
            Text {
              id: tick
              y: 2
              text: root.clock + " · " + root.count + " ROWS · "
              font { family: root.nier; pixelSize: 9; letterSpacing: 1.5 }
              color: root.inkSoft
              NumberAnimation on x { from: 120; to: -tick.implicitWidth; duration: 12000; loops: Animation.Infinite; running: root.live }
            }
          }
          Text { text: "SESSION 0471"; font { family: root.nier; pixelSize: 9; letterSpacing: 2.5 } color: root.inkSoft }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineSoft }
      }

      // ── тело ──
      Item {
        id: body
        anchors { top: header.bottom; bottom: footer.top; left: parent.left; right: parent.right }

        // колонка слева: текущее меню, назад, счётчик
        Item {
          id: side
          width: 160; height: parent.height
          Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: root.lineSoft }
          Column {
            y: 16; width: parent.width
            Item {
              width: 160; height: 34
              Rectangle { anchors.fill: parent; color: root.ink }
              Row {
                x: 22; anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle { width: 10; height: 1; color: root.paper; anchors.verticalCenter: parent.verticalCenter }
                Text {
                  width: 104; elide: Text.ElideRight
                  text: String(root.title || "MENU").toUpperCase()
                  font { family: root.nier; pixelSize: 10; letterSpacing: 2 }
                  color: root.paper
                }
              }
            }
            Item {
              width: 160; height: 34
              Rectangle { anchors.fill: parent; color: backMA.containsMouse ? Qt.rgba(70 / 255, 63 / 255, 46 / 255, 0.07) : "transparent" }
              Row {
                x: 22; anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle { width: backMA.containsMouse ? 10 : 4; height: 1; color: root.inkSoft; anchors.verticalCenter: parent.verticalCenter; Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } } }
                Text { text: "◂ BACK"; font { family: root.nier; pixelSize: 10; letterSpacing: 2 } color: backMA.containsMouse ? root.inkStrong : root.inkSoft }
              }
              MouseArea { id: backMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.backRequested() }
            }
            Item {
              width: 160; height: 56
              Column {
                x: 22; anchors.bottom: parent.bottom; anchors.bottomMargin: 6
                spacing: 4
                Text { text: (root.count > 0 ? root.selectedIndex + 1 : 0) + "/" + root.count + " NODES"; font { family: root.nier; pixelSize: 8; letterSpacing: 2 } color: root.inkSoft; opacity: 0.6 }
                Rectangle {
                  width: 72; height: 2; color: root.lineSoft
                  Rectangle {
                    height: parent.height; color: root.red
                    SequentialAnimation on x { running: root.live; loops: Animation.Infinite
                      NumberAnimation { from: 0; to: 44; duration: 1400; easing.type: Easing.InOutSine }
                      NumberAnimation { from: 44; to: 0; duration: 1400; easing.type: Easing.InOutSine } }
                    SequentialAnimation on width { running: root.live; loops: Animation.Infinite
                      NumberAnimation { from: 10; to: 28; duration: 1400; easing.type: Easing.InOutSine }
                      NumberAnimation { from: 28; to: 10; duration: 1400; easing.type: Easing.InOutSine } }
                  }
                }
              }
            }
          }
        }

        // справа: поиск и список
        Item {
          anchors { left: side.right; right: parent.right; top: parent.top; bottom: parent.bottom }
          Item {
            id: search
            width: parent.width; height: 46
            Row {
              x: 24; anchors.verticalCenter: parent.verticalCenter
              spacing: 10
              Text { text: "▸"; font.pixelSize: 12; color: root.red; anchors.verticalCenter: parent.verticalCenter }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                text: root.query.length ? root.query : "search application..."
                font { family: root.nier; pixelSize: 13; letterSpacing: 0.5; italic: !root.query.length }
                color: root.query.length ? root.inkStrong : root.inkSoft
                opacity: root.query.length ? 1 : 0.5
              }
              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1; height: 15; color: root.inkStrong
                opacity: blink.on ? 1 : 0
                QtObject { id: blink; property bool on: true }
                Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
              }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineSoft }
          }

          ListView {
            id: list
            anchors { top: search.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            clip: true
            model: root.rowModel
            currentIndex: root.selectedIndex
            highlightFollowsCurrentItem: false
            boundsBehavior: Flickable.StopAtBounds
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
            delegate: Item {
              id: row
              required property int index
              required property string kind
              required property string icon
              required property string iconFont
              required property string label
              required property string detail
              readonly property bool on: (root.cursorActive && index === root.selectedIndex) || rowMA.containsMouse
              width: list.width; height: 46
              Rectangle { anchors.fill: parent; color: root.ink; opacity: row.on ? 1 : 0; Behavior on opacity { NumberAnimation { duration: 120 } } }
              Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: 2; color: root.red; opacity: row.on ? 1 : 0; Behavior on opacity { NumberAnimation { duration: 120 } } }
              Rectangle { anchors.bottom: parent.bottom; visible: row.index < root.count - 1; x: 24; width: parent.width - 48; height: 1; color: root.lineSoft; opacity: 0.5 }
              Row {
                anchors.verticalCenter: parent.verticalCenter
                x: row.on ? 32 : 24
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }
                spacing: 14
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  width: 22
                  text: String(row.index + 1).padStart(2, "0")
                  font { family: root.nier; pixelSize: 9; letterSpacing: 1.5 }
                  color: row.on ? root.litInkA(0.5) : root.inkSoft
                }
                Rectangle {
                  anchors.verticalCenter: parent.verticalCenter
                  width: 28; height: 28; color: "transparent"
                  border.width: 1; border.color: row.on ? root.litInkA(0.8) : root.ink
                  Text {
                    anchors.centerIn: parent
                    text: root.glyph(row.label, row.detail, row.kind)
                    font.family: root.nier
                    font.pixelSize: 12
                    color: row.on ? root.litInkA(0.9) : root.ink
                  }
                }
                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  width: list.width - 24 - 22 - 28 - 3 * 14 - 110
                  spacing: 2
                  Text { width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.label; font { family: root.nier; pixelSize: 12; letterSpacing: 1.2; weight: Font.Medium } color: row.on ? root.litInk : root.ink }
                  Text { visible: row.detail !== ""; width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.detail; font { family: root.nier; pixelSize: 9; letterSpacing: 1.5 } color: row.on ? root.litInkA(0.5) : root.inkSoft }
                }
              }
              Row {
                anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
                spacing: 14
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: (root.isBranch(row.kind) ? "MENU" : String(row.kind || "APP")).toUpperCase()
                  font { family: root.nier; pixelSize: 9; letterSpacing: 2 }
                  color: row.on ? root.litInkA(0.4) : root.inkSoft
                }
                Text { anchors.verticalCenter: parent.verticalCenter; text: "▸"; font.pixelSize: 14; color: root.red; opacity: row.on ? 1 : 0 }
              }
              MouseArea {
                id: rowMA
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
            text: "▸ NO RESULTS"
            font { family: root.nier; pixelSize: 10; letterSpacing: 3 }
            color: root.inkSoft; opacity: 0.5
          }
        }
      }

      // ── низ ──
      Item {
        id: footer
        anchors.bottom: parent.bottom
        width: parent.width; height: 44
        Rectangle { width: parent.width; height: 1; color: root.lineSoft }
        Row {
          x: 28; height: parent.height
          Repeater {
            model: [
              { l: "TERMINAL", cmd: ["xdg-terminal-exec"] },
              { l: "FILES", cmd: ["xdg-terminal-exec", "yazi"] },
              { l: "LOCK", cmd: ["omarchy-system-lock"] },
              { l: "SHUTDOWN", cmd: ["omarchy-shell", "widgets", "togglePower"], danger: true }
            ]
            delegate: Item {
              required property var modelData
              required property int index
              height: 44; width: fl.implicitWidth + 24
              Rectangle { visible: index > 0; width: 1; height: parent.height; color: root.lineSoft }
              Text {
                id: fl
                anchors.centerIn: parent
                text: modelData.l
                font { family: root.nier; pixelSize: 9; letterSpacing: 2.5 }
                color: fma.containsMouse ? (modelData.danger === true ? root.red : root.inkStrong) : root.inkSoft
                Behavior on color { ColorAnimation { duration: 150 } }
              }
              Rectangle {
                anchors { bottom: parent.bottom; bottomMargin: 6; horizontalCenter: parent.horizontalCenter }
                width: fma.containsMouse ? fl.implicitWidth : 0; height: 1; color: root.red
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
              }
              MouseArea {
                id: fma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.dismissRequested(); Quickshell.execDetached(modelData.cmd) }
              }
            }
          }
        }
        Row {
          anchors { right: parent.right; rightMargin: 28; verticalCenter: parent.verticalCenter }
          spacing: 14
          Repeater {
            model: [["↑↓", "NAV"], ["↵", "OPEN"], ["ESC", "CLOSE"]]
            Row {
              required property var modelData
              spacing: 5
              anchors.verticalCenter: parent.verticalCenter
              Rectangle {
                width: kb.implicitWidth + 8; height: 16; color: "transparent"
                border.width: 1; border.color: root.lineSoft
                Text { id: kb; anchors.centerIn: parent; text: modelData[0]; font { family: root.nier; pixelSize: 9; letterSpacing: 1 } color: root.ink }
              }
              Text { anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; font { family: root.nier; pixelSize: 9; letterSpacing: 2 } color: root.inkSoft }
            }
          }
        }
      }
    }

    // шторка: уходит вправо, открывая лист
    Rectangle {
      x: root.curtain * (root.lw - 2)
      width: root.curtain >= 1 ? 0 : root.lw - root.curtain * (root.lw - 2)
      height: root.lh
      color: root.ink
      z: 30
    }
  }
}
