import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons

// surface-wide — широкий лаунчер «Programs» по мотивам dock/WideDrawer.qml из surface-dots (snes19xx; README разрешает
// брать со ссылкой; код свой): карточка у левого нижнего угла над таскбаром. Сверху — «Programs» шрифтом с засечками и
// аватар с именем; дальше — сетка 6 столбцов: значок и подпись в скруглённой плитке, выбранная — с рамкой акцентом;
// внизу — поле «Search apps and features…» и переключатель Apps / Shaders. Во вкладке Shaders — шейдеры экрана
// Customizer (crt-toggle.sh list): клик включает / выключает, текущий — залит акцентом.
// Открывать сразу списком приложений: omarchy-shell shell summon omarchy.menu '{"menu":"apps","browse":true,"skin":"surface-wide"}'.
SkinBase {
  id: root

  readonly property real k: root.u
  readonly property color ink: root.foreground
  readonly property bool dark: 0.299 * root.background.r + 0.587 * root.background.g + 0.114 * root.background.b < 0.5
  function mix(a, b, t) { return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1) }
  readonly property color card: dark ? mix(root.background, root.foreground, 0.04) : mix(root.background, Qt.color("#000000"), 0.03)
  readonly property color tile: dark ? mix(root.background, root.foreground, 0.08) : Qt.rgba(0, 0, 0, 0.05)
  readonly property string serif: Qt.fontFamilies().indexOf("Newsreader") !== -1 ? "Newsreader" : "serif"
  readonly property string sans: Qt.fontFamilies().indexOf("Manrope") !== -1 ? "Manrope" : root.fontFamily
  readonly property int cols: 6

  property string tab: "apps"
  readonly property string toggleScript: Quickshell.env("HOME") + "/.config/omarchy/plugins/kamradsmeshnyavy.customizer/scripts/crt-toggle.sh"
  property var shaders: []
  property string currentShader: ""
  Process {
    id: shList
    command: ["bash", "-c", "\"$1\" list 2>/dev/null; echo ---; cat \"$HOME/.local/state/hypr/screen-shader\" 2>/dev/null", "_", root.toggleScript]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = String(text || "").split("---")
        root.shaders = (parts[0] || "").split("\n").filter(function(l) { return l.trim() !== "" })
        root.currentShader = String(parts[1] || "").trim().split(" ")[0] || ""
      }
    }
  }
  function toggleShader(path) {
    var n = path.replace(/^.*\//, "").replace(/\.frag$/, "")
    Quickshell.execDetached([root.toggleScript, n])
    root.currentShader = root.currentShader === path ? "" : path
  }

  function navigate(dx, dy) { root.step(dy !== 0 ? dy * root.cols : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1; tab = "apps" }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  Rectangle {
    id: win
    x: Math.round(8 * k)
    y: parent.height - height - Math.round(8 * k) + Math.round((1 - root.t) * 30 * k)
    opacity: root.t
    width: Math.round(Math.min(parent.width - 16 * k, 560 * k))
    height: Math.round(Math.min(parent.height * 0.62, 350 * k))
    radius: 10 * k
    color: root.card
    border { width: 1; color: Util.alpha(root.ink, 0.08) }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // заголовок
    Text {
      x: 18 * k; y: 12 * k
      text: root.tab === "apps" ? "Programs" : "Shaders"
      color: root.ink
      font { family: root.serif; pixelSize: 22 * k }
    }
    Row {
      anchors { right: parent.right; rightMargin: 16 * k; top: parent.top; topMargin: 16 * k }
      spacing: 6 * k
      Item {
        width: 20 * k; height: 20 * k
        anchors.verticalCenter: parent.verticalCenter
        Image { id: face; anchors.fill: parent; source: "file://" + Quickshell.env("HOME") + "/.face"; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(64, 64); visible: false; layer.enabled: true }
        Rectangle { id: faceMask; anchors.fill: parent; radius: width / 2; visible: false; layer.enabled: true }
        MultiEffect { anchors.fill: parent; source: face; visible: face.status === Image.Ready; maskEnabled: true; maskSource: faceMask; maskThresholdMin: 0.5 }
        Rectangle { anchors.fill: parent; radius: width / 2; visible: face.status !== Image.Ready; color: root.tile
          Text { anchors.centerIn: parent; text: (Quickshell.env("USER") || "u").charAt(0).toUpperCase(); color: root.accent; font { family: root.sans; pixelSize: 10 * k; weight: Font.Bold } } }
      }
      Text { anchors.verticalCenter: parent.verticalCenter; text: Quickshell.env("USER") || ""; color: root.ink; font { family: root.sans; pixelSize: 10 * k } }
    }

    // приложения
    GridView {
      id: grid
      visible: root.tab === "apps"
      anchors { left: parent.left; right: parent.right; top: parent.top; bottom: bottomBar.top; leftMargin: 14 * k; rightMargin: 14 * k; topMargin: 48 * k; bottomMargin: 8 * k }
      clip: true
      cellWidth: Math.floor(width / root.cols)
      cellHeight: 62 * k
      model: root.rowModel
      currentIndex: root.selectedIndex
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
      delegate: Item {
        id: cell
        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: grid.cellWidth; height: grid.cellHeight
        Rectangle {
          anchors { fill: parent; margins: 3 * root.k }
          radius: 6 * root.k
          color: cell.on ? Util.alpha(root.accent, 0.22) : ca.containsMouse ? Util.alpha(root.ink, 0.1) : root.tile
          border { width: cell.on ? 1 : 0; color: root.accent }
          RowIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 7 * root.k
            size: 28 * root.k
            kind: cell.kind
            glyph: cell.icon
            glyphFont: cell.iconFont
            appIcon: cell.appIcon
            resolver: root.iconResolver
            fontFamily: root.sans
            load: Math.abs(cell.index - root.selectedIndex) < 60
            fallback: cell.label.length ? cell.label.charAt(0).toUpperCase() : "•"
            color: root.ink
          }
          Text {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 5 * root.k; leftMargin: 3 * root.k; rightMargin: 3 * root.k }
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: cell.label
            color: root.ink
            font { family: root.sans; pixelSize: 8 * root.k }
          }
        }
        MouseArea {
          id: ca
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
          onPositionChanged: root.hoverSelect(cell.index, mapToItem(root, mouseX, mouseY))
          onClicked: root.activated(cell.index)
        }
      }
    }
    Text {
      visible: root.tab === "apps" && root.count === 0
      anchors.centerIn: grid
      text: root.emptyText()
      color: Util.alpha(root.ink, 0.5)
      font { family: root.sans; pixelSize: 12 * k }
    }

    // шейдеры экрана
    GridView {
      id: shGrid
      visible: root.tab === "shaders"
      anchors.fill: grid
      clip: true
      cellWidth: Math.floor(width / root.cols)
      cellHeight: 62 * k
      model: root.shaders
      delegate: Item {
        id: sc
        required property string modelData
        readonly property bool on: root.currentShader === modelData
        width: shGrid.cellWidth; height: shGrid.cellHeight
        Rectangle {
          anchors { fill: parent; margins: 3 * root.k }
          radius: 6 * root.k
          color: sc.on ? root.accent : sm.containsMouse ? Util.alpha(root.ink, 0.1) : root.tile
          Text { anchors.horizontalCenter: parent.horizontalCenter; y: 9 * root.k; text: "\uf0d0"; color: sc.on ? root.background : root.ink; font { family: "JetBrainsMono Nerd Font"; pixelSize: 22 * root.k } }
          Text {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 5 * root.k; leftMargin: 3 * root.k; rightMargin: 3 * root.k }
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: sc.modelData.replace(/^.*\//, "").replace(/\.frag$/, "")
            color: sc.on ? root.background : root.ink
            font { family: root.sans; pixelSize: 8 * root.k }
          }
        }
        MouseArea { id: sm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleShader(sc.modelData) }
      }
    }

    // поиск и вкладки
    Item {
      id: bottomBar
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 14 * k; rightMargin: 14 * k; bottomMargin: 12 * k }
      height: 30 * k
      Rectangle {
        anchors { left: parent.left; right: tabs.left; rightMargin: 10 * k; top: parent.top; bottom: parent.bottom }
        radius: 6 * k
        color: root.tile
        Row {
          x: 10 * k; anchors.verticalCenter: parent.verticalCenter
          spacing: 2 * k
          Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.query.length ? root.query : "Search apps and features…"
            color: root.query.length ? root.ink : Util.alpha(root.ink, 0.45)
            font { family: root.sans; pixelSize: 10 * k }
          }
          Rectangle {
            visible: root.query.length > 0
            anchors.verticalCenter: parent.verticalCenter
            width: 1.5 * k; height: 13 * k
            color: root.ink
            opacity: blink.on ? 0.9 : 0
            QtObject { id: blink; property bool on: true }
            Timer { interval: 530; repeat: true; running: root.live; onTriggered: blink.on = !blink.on }
          }
        }
      }
      Rectangle {
        id: tabs
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: 126 * k
        radius: 6 * k
        color: root.tile
        Row {
          anchors { fill: parent; margins: 3 * k }
          Repeater {
            model: [["apps", "Apps"], ["shaders", "Shaders"]]
            Rectangle {
              required property var modelData
              readonly property bool on: root.tab === modelData[0]
              width: parent.width / 2; height: parent.height
              radius: 5 * k
              color: on ? root.accent : "transparent"
              Text { anchors.centerIn: parent; text: parent.modelData[1]; color: parent.on ? root.background : root.ink; font { family: root.sans; pixelSize: 10 * k } }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.tab = parent.modelData[0]; if (root.tab === "shaders" && !shList.running) shList.running = true }
              }
            }
          }
        }
      }
    }
  }
}
