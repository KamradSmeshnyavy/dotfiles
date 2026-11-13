import QtQuick
import qs.Commons
import "glyph"

// Скин glyph — лаунчер glyph-rice (launcher/Launcher.qml и charms/Charms.qml, GPL-3.0) поверх строк меню: панель 860 по
// центру, экран гаснет; поиск-пилюля с красной кареткой и чипы быстрых режимов (apps · = calc · : charms · @ windows ·
// ! web · ; clip — горит тот, чей префикс в поиске); строки — сеткой по 6: круг 88 с иконкой точками (у выбранной —
// белый круг), подпись — совпавшие буквы белые. Charms и прочие строки с глифом — тот же круг с символом. Ответ
// калькулятора — крупно цифрами Doto. Поиск, режимы и запуск — как во всём меню (Menu.qml, Modes.js).
SkinBase {
  id: root

  readonly property int cols: 6
  readonly property var chips: [["apps", ""], ["calc", "="], ["charms", ":"], ["windows", "@"], ["web", "!"], ["clip", ";"]]
  readonly property string prefix: {
    var c = root.query.charAt(0)
    return "=:@!;".indexOf(c) >= 0 && c !== "" ? c : ""
  }
  readonly property string needle: (root.prefix ? root.query.slice(1) : root.query).trim().toLowerCase()
  readonly property bool calcView: root.prefix === "=" && !!root.current && /^= /.test(String(root.current.label))

  // стрелки — по сетке: ←→ соседняя ячейка, ↑↓ — ряд
  function navigate(dx, dy) {
    if (root.count === 0) return
    if (dx !== 0) root.step(dx)
    else root.clampTo(root.selectedIndex + dy * root.cols)
  }

  // подпоследовательность, как у glyph-rice: индексы совпавших букв
  function hl(name) {
    var q = root.needle, l = String(name || "").toLowerCase(), out = []
    if (!q) return out
    var at = l.indexOf(q)
    if (at >= 0) { for (var k = 0; k < q.length; k++) out.push(at + k); return out }
    var i = 0
    for (var j = 0; j < q.length; j++) {
      i = l.indexOf(q.charAt(j), i)
      if (i < 0) return []
      out.push(i++)
    }
    return out
  }
  function rich(name, on) {
    var marks = root.hl(name), s = String(name || ""), out = ""
    for (var i = 0; i < s.length; i++) {
      var c = s.charAt(i)
      var e = c === "<" ? "&lt;" : c === "&" ? "&amp;" : c === ">" ? "&gt;" : c
      out += marks.indexOf(i) >= 0 ? "<font color=\"" + GTheme.fg + "\">" + e + "</font>" : e
    }
    return out
  }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: GTheme.t; easing.type: Easing.BezierSpline; easing.bezierCurve: GTheme.glide } }

  Rectangle {
    anchors.fill: parent
    color: GTheme.fade(GTheme.bg, GTheme.light ? 0.8 : 0.74)
    opacity: root.t * Math.min(1, root.backdrop / 0.74)
  }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) { if (mouse.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  // холст макета 1920×1080
  readonly property real s: Math.min(width / 1920, height / 1080)
  Item {
    id: stage
    width: root.width / root.s
    height: root.height / root.s
    scale: root.s
    transformOrigin: Item.TopLeft

    Rectangle {
      id: panel
      x: (stage.width - width) / 2
      y: 140 + 24 * (1 - root.t)
      width: 860
      height: Math.min(stage.height - 280, 30 + 66 + 20 + head.height + Math.max(grid.contentHeight, calc.visible ? calc.height : 0) + 34)
      opacity: root.t
      radius: 44
      color: GTheme.s1
      border { width: 1; color: GTheme.s2 }
      MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

      // поиск: пилюля, красная каретка, чипы режимов
      Rectangle {
        id: search
        x: 34
        y: 30
        width: parent.width - 68
        height: 66
        radius: 33
        color: GTheme.s2

        Icon { id: lens; x: 24; anchors.verticalCenter: parent.verticalCenter; text: "\u{F0349}"; color: GTheme.grey; font.pixelSize: 22 }
        Row {
          anchors { left: lens.right; leftMargin: 16; right: chipRow.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
          spacing: 2
          clip: true
          Text {
            id: qtext
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.query.length ? root.query : (root.title || "Search apps")
            font { family: "Space Grotesk"; pixelSize: 22 }
            color: root.query.length ? GTheme.fg : GTheme.mute
          }
          Rectangle {
            id: caret
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 28
            color: GTheme.accent
            Timer { running: root.live; interval: 500; repeat: true; onTriggered: caret.opacity = 1 - caret.opacity }
          }
        }
        Row {
          id: chipRow
          anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
          spacing: 2
          Repeater {
            model: root.chips
            Rectangle {
              required property var modelData
              readonly property bool on: root.prefix === modelData[1]
              width: chip.width + 22
              height: chip.height + 20
              radius: height / 2
              color: on ? GTheme.fg : "transparent"
              Lb { id: chip; anchors.centerIn: parent; text: (parent.modelData[1] ? parent.modelData[1] + " " : "") + parent.modelData[0]; px: 10; color: parent.on ? GTheme.ink : GTheme.grey }
            }
          }
        }
      }

      // заголовок группы: что открыто и сколько строк
      Row {
        id: head
        anchors { left: parent.left; leftMargin: 34; top: search.bottom; topMargin: 30 }
        spacing: 14
        height: 40
        Num {
          anchors.verticalCenter: parent.verticalCenter
          visible: root.count > 0 && !root.calcView
          text: String(root.selectedIndex + 1).padStart(2, "0")
          font.pixelSize: 34
        }
        Lb {
          anchors.verticalCenter: parent.verticalCenter
          text: (root.prefix ? ({ "=": "calc", ":": "charms", "@": "windows", "!": "web", ";": "clipboard" })[root.prefix]
                 : root.query.length ? "results" : (root.title || "apps").toLowerCase()) + " · " + root.count
        }
      }

      // калькулятор: ответ крупно, Enter — скопировать
      Column {
        id: calc
        visible: root.calcView
        anchors { left: parent.left; leftMargin: 34; right: parent.right; rightMargin: 34; top: head.bottom; topMargin: 10 }
        spacing: 10
        Lb { text: "↵ copy · " + (root.current ? root.current.detail : "") ; width: parent.width; elide: Text.ElideRight }
        Num { width: parent.width; elide: Text.ElideRight; text: root.current ? String(root.current.label).slice(2) : "—"; font.pixelSize: 96 }
      }

      GridView {
        id: grid
        visible: !root.calcView
        anchors { left: parent.left; right: parent.right; top: head.bottom; bottom: parent.bottom; topMargin: 16; leftMargin: 34; rightMargin: 34; bottomMargin: 34 }
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: width / root.cols
        cellHeight: 88 + 10 + 20 + 22
        model: root.rowModel
        currentIndex: root.selectedIndex
        highlightFollowsCurrentItem: false
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

        delegate: Item {
          id: cell
          required property int index
          required property string kind
          required property string icon
          required property string iconFont
          required property string appIcon
          required property string label
          readonly property bool on: root.cursorActive && cell.index === root.selectedIndex
          readonly property bool near: Math.abs(cell.index - root.selectedIndex) < 48 || root.count <= 60
          width: grid.cellWidth
          height: grid.cellHeight

          Rectangle {
            id: disc
            anchors.horizontalCenter: parent.horizontalCenter
            width: 88
            height: 88
            radius: 44
            color: cell.on ? GTheme.fg : GTheme.s2
            Behavior on color { ColorAnimation { duration: 120 } }

            RowIcon {
              anchors.centerIn: parent
              size: cell.kind === "app" ? 44 : 40
              kind: cell.kind
              glyph: cell.icon
              glyphFont: cell.iconFont
              appIcon: cell.appIcon
              resolver: root.iconResolver
              fontFamily: "JetBrainsMono Nerd Font"
              load: cell.near
              fallback: cell.label.length > 0 ? cell.label.charAt(0).toUpperCase() : "•"
              color: cell.on ? GTheme.ink : GTheme.fg
              // иконка приложения точками, как у glyph-rice
              layer.enabled: cell.kind === "app" && cell.near
              layer.effect: Dm { step: 2.5 }
            }
          }
          Text {
            anchors { top: disc.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter }
            width: parent.width - 8
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.StyledText
            text: root.rich(cell.label, cell.on)
            font { family: "Space Grotesk"; pixelSize: 14 }
            color: cell.on ? GTheme.fg : GTheme.grey
          }
          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
            onPositionChanged: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
            onClicked: root.activated(cell.index)
          }
        }
      }

      Lb {
        visible: root.count === 0
        anchors.centerIn: grid
        text: root.emptyText()
      }
    }
  }
}
