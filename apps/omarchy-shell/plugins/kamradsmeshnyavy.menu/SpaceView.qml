import QtQuick
import Quickshell
import qs.Commons

// space — лаунчер по мотивам стиля Space из elifouts/Dotfiles (GPL-3.0 — его Space/launcher/Launcher.qml и анимация
// с его space/launcher.gif; код свой, «расшифровка» — его decode.js): «маленький терминал под баром». Окно 620 px
// выезжает сверху и подстраивает высоту под число строк, фон темы на 80 %, полоса 3 px акцентом слева. Строка
// «~/run $ запрос█» (Tab — «~/cmd $»: команды лаунчера, префикс «>»), ниже до 7 строк «N  Имя // описание» — каждая
// проступает через шум при смене результатов, ступенькой сверху вниз; выбранная — подложкой акцентом и «›».
// Колесо, стрелки, Enter — как у остальных видов (SkinBase).
SkinBase {
  id: root

  readonly property string mono: Qt.fontFamilies().indexOf("JetBrainsMono Nerd Font") !== -1 ? "JetBrainsMono Nerd Font" : root.fontFamily
  readonly property int rowH: 22
  readonly property int rows: 7
  readonly property bool tabCmd: true  // Menu.qml: Tab — переключить «~/run» ↔ «~/cmd» (префикс «>»)
  readonly property bool cmd: root.query.charAt(0) === ">"
  readonly property string typed: cmd ? root.query.slice(1) : root.query
  function a(c, k) { return Qt.rgba(c.r, c.g, c.b, k) }

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  // его decode.js: строка проступает слева направо через шум
  readonly property string noise: "#$%&*+=<>/\\|01"
  function frame(from, to, k) {
    if (k >= 1) return to
    var n = Math.max(from.length, to.length), lead = k * (n + 5), out = ""
    for (var i = 0; i < n; i++) {
      var t = to[i] || "", f = from[i] || ""
      if (i < lead - 5) out += t
      else if (i < lead) out += /\s/.test(t || f) ? (t || f) : noise[Math.floor(Math.random() * noise.length)]
      else out += f
    }
    return out.replace(/\s+$/, "")
  }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Text {
    anchors.horizontalCenter: win.horizontalCenter
    anchors.bottom: win.top
    anchors.bottomMargin: -4
    opacity: root.t
    text: "SPACE"
    color: root.a(root.accent, 0.8)
    font { family: root.mono; pixelSize: 18; letterSpacing: 2; weight: Font.Medium }
  }

  readonly property int shownRows: Math.min(root.rows, root.count)
  Rectangle {
    id: win
    anchors.horizontalCenter: parent.horizontalCenter
    // выезжает сверху (у него y: -h + (rest + h)·t)
    y: -height + (46 + height) * root.t
    width: 620
    // высота — под число строк, плавно
    height: 12 + 22 + 3 + Math.max(root.count === 0 && root.query !== "" ? 1 : 0, root.shownRows) * (root.rowH + 3) + 12
    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    color: root.a(root.background, 0.8)
    border.width: 1
    border.color: root.a(root.accent, 0.3)
    clip: true
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }
    Rectangle { width: 3; height: parent.height; color: root.accent }

    // приглашение
    Row {
      x: 18; y: 12
      height: 22
      spacing: 8
      Text {
        id: prompt
        anchors.verticalCenter: parent.verticalCenter
        property string target: root.cmd ? "~/cmd" : "~/run"
        property string from: target
        property real k: 1
        onTargetChanged: { from = text; k = 0; pk.restart() }
        NumberAnimation { id: pk; target: prompt; property: "k"; to: 1; duration: 180 }
        text: root.frame(from, target, k)
        color: root.accent
        font { family: root.mono; pixelSize: 13 }
      }
      Text { anchors.verticalCenter: parent.verticalCenter; text: "$"; color: root.a(root.foreground, 0.5); font { family: root.mono; pixelSize: 13 } }
      Text { id: q; anchors.verticalCenter: parent.verticalCenter; textFormat: Text.PlainText; text: root.typed; color: root.foreground; font { family: root.mono; pixelSize: 14 } }
      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 8; height: 15
        color: root.accent
        opacity: blink.on ? 1 : 0
        QtObject { id: blink; property bool on: true }
        Timer { interval: 500; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
      }
    }

    ListView {
      id: list
      x: 18; y: 12 + 22 + 3
      width: parent.width - 36
      height: root.rows * (root.rowH + 3)
      spacing: 3
      clip: true
      interactive: false
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
        // строка проступает через шум; ступенька — по месту в списке (его 220 + 35·i мс)
        readonly property string target: label + (detail ? "  // " + detail : "")
        property string from: ""
        property real k: 0
        Component.onCompleted: morph.start()
        onTargetChanged: { from = shown; k = 0; morph.restart() }
        NumberAnimation { id: morph; target: row; property: "k"; to: 1; duration: 220 + Math.min(row.index, 8) * 35 }
        readonly property string shown: root.frame(from, target, k)

        Rectangle { anchors.fill: parent; color: root.a(root.accent, row.on ? 0.14 : 0) }
        Row {
          x: 6
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8
          Text {
            width: 12
            text: row.on ? "›" : String(row.index + 1)
            color: row.on ? root.accent : root.a(root.foreground, 0.3)
            font { family: root.mono; pixelSize: 12 }
          }
          Text {
            width: list.width - 34
            elide: Text.ElideRight
            textFormat: Text.StyledText
            // имя — ярко, «// описание» — тускло (как у него)
            text: {
              var cut = row.label.length
              var esc = function(s) { return s.replace(/&/g, "&amp;").replace(/</g, "&lt;") }
              return esc(row.shown.slice(0, cut)) + "<font color='" + root.a(root.foreground, 0.5) + "'>" + esc(row.shown.slice(cut)) + "</font>"
            }
            color: row.on ? root.foreground : root.a(root.foreground, 0.8)
            font { family: root.mono; pixelSize: 13 }
          }
        }
        MouseArea {
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
      visible: root.count === 0 && root.query !== ""
      x: 24; y: 12 + 22 + 3 + 3
      text: root.cmd ? "command not found" : root.emptyText()
      color: Util.alpha(root.foreground, 0.4)
      font { family: root.mono; pixelSize: 13 }
    }
  }
}
