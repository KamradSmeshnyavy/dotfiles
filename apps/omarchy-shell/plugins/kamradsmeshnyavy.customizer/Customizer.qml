import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick 6.11
import qs.Commons
import qs.Ui

// Quickshell port of scripts/bin/omarchy-customizer (the old fzf menu on
// SUPER+SHIFT+T). Three panes: categories | filterable list | preview.
// customizer.sh next to this file does the listing and applying, so the
// actions stay identical to the shell script.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string script: decodeURIComponent(String(Qt.resolvedUrl("customizer.sh")).replace(/^file:\/\//, ""))

  // key: customizer.sh category; image: preview pane shows the picture
  readonly property var categories: [
    { key: "anims",       icon: "󰔡", title: "Hyprland Animations",        hint: "Live preview while you browse · Esc reverts", image: false },
    { key: "layouts",     icon: "󰕮", title: "Shell Layouts",              hint: "~/.config/omarchy/shell-*.json",            image: false },
    { key: "themes",      icon: "󰏘", title: "Omarchy Themes",             hint: "omarchy theme set",                          image: true },
    { key: "theme-walls", icon: "󰸉", title: "Theme Wallpaper",            hint: "No recolor · current theme's backgrounds",   image: true },
    { key: "walls",       icon: "󰃣", title: "Recolor Wallpaper (Lutgen)", hint: "O folder · o image(s) from anywhere",         image: true },
    { key: "shaders",     icon: "󰍹", title: "Screen Shaders",             hint: "crt-toggle.sh",                              image: false }
  ]

  property bool opened: false
  property int categoryIndex: 0
  property int pane: 0               // 0 = categories, 1 = items
  property string filterText: ""
  property int selectedIndex: 0
  property bool loading: false
  property var cache: ({})           // category key -> rows, dropped on every open
  property var items: []             // rows of the current category, unfiltered
  property bool animPreviewing: false
  property string previewText: ""
  property bool filtering: false     // "/" pressed: printable keys go to the filter
  property bool pendingG: false      // first "g" of "gg"

  readonly property var category: categories[categoryIndex]
  property var selectedRow: null     // set by selectionChanged(); ListModel.get() isn't reactive

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property var borderSpec: Border.surfaceSpec("menu", "border", border, Math.max(1, Style.space(2)))
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property color accent: Color.accent
  readonly property int cornerRadius: Style.cornerRadius
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int contentSpacing: Style.spacing.md
  property int rowHeight: Math.max(Style.space(30), Style.font.title + Style.spacing.controlPaddingY * 2)
  property int cardWidth: Math.min(Style.space(1180), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(680), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.cache = ({})
    root.filtering = false
    root.opened = true
    root.pane = 0
    root.setCategory(root.categoryIndex, true)
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.revertAnimPreview()
    root.opened = false
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "kamradsmeshnyavy.customizer")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function revertAnimPreview() {
    animTimer.stop()
    if (!root.animPreviewing) return
    root.animPreviewing = false
    Quickshell.execDetached([root.script, "anim-restore"])
  }

  function setCategory(index, force) {
    if (index < 0 || index >= categories.length) return
    if (index === root.categoryIndex && !force) return
    root.revertAnimPreview()
    root.categoryIndex = index
    root.filtering = false
    root.filterText = ""
    root.selectedIndex = 0
    var key = categories[index].key
    if (root.cache[key]) {
      root.items = root.cache[key]
      root.selectedIndex = root.currentIndexOf(root.items)
      root.rebuild()
    } else {
      root.items = []
      root.rebuild()
      root.loading = true
      lister.running = false
      lister.category = key
      lister.running = true
    }
  }

  function loadRows(key, raw) {
    var rows = []
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i]) continue
      var f = lines[i].split("\t")
      rows.push({ label: f[0] || "", value: f[1] || "", preview: f[2] || "", current: f[3] === "1", note: f[4] || "" })
    }
    var next = ({})
    for (var k in root.cache) next[k] = root.cache[k]
    next[key] = rows
    root.cache = next
    if (key !== root.category.key) return
    root.loading = false
    root.items = rows
    root.selectedIndex = root.currentIndexOf(rows)
    root.rebuild()
  }

  // Open a list on the entry that is in use.
  function currentIndexOf(rows) {
    for (var i = 0; i < rows.length; i++) if (rows[i].current) return i
    return 0
  }

  function rebuild() {
    var needle = root.filterText.toLowerCase()
    displayModel.clear()
    for (var i = 0; i < root.items.length; i++) {
      var row = root.items[i]
      if (needle && row.label.toLowerCase().indexOf(needle) === -1) continue
      displayModel.append(row)
    }
    if (root.selectedIndex >= displayModel.count) root.selectedIndex = Math.max(0, displayModel.count - 1)
    Qt.callLater(function() {
      if (displayModel.count > 0) itemList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    })
    root.selectionChanged()
  }

  function setFilter(text) {
    root.filterText = text
    root.selectedIndex = 0
    root.pane = 1
    root.rebuild()
  }

  function toCategories() {
    if (root.pane !== 1) return
    root.revertAnimPreview()
    root.pane = 0
  }

  // Rows that fit in the list, halved: the Ctrl+D / Ctrl+U step.
  function halfPage() {
    return Math.max(1, Math.floor(itemList.height / root.rowHeight / 2))
  }

  // Jump to a row (-1 = last); in the category pane, to a category.
  function moveTo(index) {
    if (root.pane === 0) {
      root.setCategory(index < 0 ? categories.length - 1 : index)
      return
    }
    if (displayModel.count === 0) return
    root.move((index < 0 ? displayModel.count - 1 : index) - root.selectedIndex)
  }

  // Shift+J / Shift+K: scroll the text preview by five lines, like yazi.
  function scrollPreview(dir) {
    var step = previewLabel.font.pixelSize * 1.4 * 5
    var maxY = Math.max(0, previewFlick.contentHeight - previewFlick.height)
    previewFlick.contentY = Math.max(0, Math.min(maxY, previewFlick.contentY + dir * step))
  }

  function move(delta) {
    if (root.pane === 0) {
      var n = categories.length
      root.setCategory(Math.abs(delta) === 1 ? (root.categoryIndex + delta + n) % n
        : Math.max(0, Math.min(n - 1, root.categoryIndex + delta)))
      return
    }
    if (displayModel.count === 0) return
    root.selectedIndex = Math.max(0, Math.min(displayModel.count - 1, root.selectedIndex + delta))
    itemList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    root.selectionChanged()
  }

  // Called whenever the highlighted row may have changed.
  function selectionChanged() {
    previewFlick.contentY = 0
    var row = root.selectedIndex >= 0 && root.selectedIndex < displayModel.count
      ? displayModel.get(root.selectedIndex) : null
    root.selectedRow = row ? { label: row.label, value: row.value, preview: row.preview, current: row.current, note: row.note } : null
    previewFile.path = (row && !root.category.image) ? row.preview : ""
    if (!row || root.category.image) root.previewText = ""
    if (root.category.key === "anims" && root.pane === 1 && row) animTimer.restart()
  }

  function activate() {
    if (root.pane === 0) {
      root.pane = 1
      root.selectionChanged()
      return
    }
    if (root.selectedRow) root.run(root.selectedRow.value)
  }

  // Apply <value> in the current category. The overlay closes first: it holds
  // exclusive keyboard focus on the overlay layer, so a zenity picker opened by
  // customizer.sh would otherwise sit underneath it.
  function run(value) {
    var key = root.category.key
    // Apply owns active_animations.lua from here, so no revert on close.
    if (key === "anims") { animTimer.stop(); root.animPreviewing = false }
    root.dismiss()
    Quickshell.execDetached([root.script, "apply", key, value])
  }

  function fileUrl(path) {
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  // The old fzf preview for shaders showed just the header comments and consts.
  function formatPreview(text) {
    if (root.category.key !== "shaders") return text
    return text.split("\n").filter(function(l) { return /^(\/\/|const)/.test(l) }).join("\n")
  }

  ListModel { id: displayModel }

  Timer { id: gTimer; interval: 700; onTriggered: root.pendingG = false }

  Process {
    id: lister
    property string category: ""
    command: [root.script, "list", category]
    stdout: StdioCollector {
      onStreamFinished: root.loadRows(lister.category, text)
    }
  }

  FileView {
    id: previewFile
    blockLoading: false
    printErrors: false
    onLoaded: root.previewText = root.formatPreview(text())
    onLoadFailed: root.previewText = ""
  }

  // Live animation preview, debounced so scrolling doesn't reload Hyprland per row.
  Timer {
    id: animTimer
    interval: 300
    onTriggered: {
      var row = root.selectedRow
      if (!row || !root.opened || root.category.key !== "anims") return
      root.animPreviewing = true
      Quickshell.execDetached([root.script, "anim-preview", row.value])
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-customizer"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle { anchors.fill: parent; color: root.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        // Yazi-style keys. Normal mode: letters are commands; "/" starts a
        // filter, Enter/Esc leave it. Arrows, Tab and PageUp/Down work too.
        Keys.onPressed: function(event) {
          var k = event.key
          var ctrl = event.modifiers & Qt.ControlModifier
          var t = event.text
          var printable = t && t.length === 1 && t.charCodeAt(0) >= 32 && t.charCodeAt(0) !== 127
          var pendingG = root.pendingG
          root.pendingG = false

          if (root.filtering) {
            if (k === Qt.Key_Escape) { root.filtering = false; root.setFilter("") }
            else if (k === Qt.Key_Return || k === Qt.Key_Enter) root.filtering = false
            else if (k === Qt.Key_Backspace && !root.filterText) root.filtering = false
            else if (Util.editsFilter(event, root.filterText)) root.setFilter(Util.editedFilter(event, root.filterText))
            else if (k === Qt.Key_Up || (ctrl && (k === Qt.Key_K || k === Qt.Key_P))) root.move(-1)
            else if (k === Qt.Key_Down || (ctrl && (k === Qt.Key_J || k === Qt.Key_N))) root.move(1)
            else if (printable && !ctrl) root.setFilter(root.filterText + t)
            else return
            event.accepted = true
            return
          }

          if (ctrl && root.category.key === "walls" && k === Qt.Key_O) root.run("pick-files")
          else if (ctrl && (k === Qt.Key_D)) root.move(root.halfPage())
          else if (ctrl && (k === Qt.Key_U)) root.move(-root.halfPage())
          else if (ctrl && (k === Qt.Key_F)) root.move(root.halfPage() * 2)
          else if (ctrl && (k === Qt.Key_B)) root.move(-root.halfPage() * 2)
          else if (ctrl && (k === Qt.Key_N)) root.move(1)
          else if (ctrl && (k === Qt.Key_P)) root.move(-1)
          else if (k === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else if (root.pane === 1) root.toCategories()
            else root.dismiss()
          }
          else if (k === Qt.Key_Return || k === Qt.Key_Enter) root.activate()
          else if (k === Qt.Key_Up) root.move(-1)
          else if (k === Qt.Key_Down) root.move(1)
          else if (k === Qt.Key_PageUp) root.move(-root.halfPage() * 2)
          else if (k === Qt.Key_PageDown) root.move(root.halfPage() * 2)
          else if (k === Qt.Key_Home) root.moveTo(0)
          else if (k === Qt.Key_End) root.moveTo(-1)
          else if (k === Qt.Key_Left || k === Qt.Key_Backtab) root.toCategories()
          else if (k === Qt.Key_Right || k === Qt.Key_Tab) { if (root.pane === 0) root.activate() }
          else if (ctrl || !printable) return
          else if (t === "j") root.move(1)
          else if (t === "k") root.move(-1)
          else if (t === "h") root.toCategories()
          else if (t === "l") { if (root.pane === 0) root.activate() }
          else if (t === "g") { if (pendingG) root.moveTo(0); else { root.pendingG = true; gTimer.restart() } }
          else if (t === "G") root.moveTo(-1)
          else if (t === "J") root.scrollPreview(1)
          else if (t === "K") root.scrollPreview(-1)
          else if (t === "/") { root.filtering = true; root.pane = 1; root.selectionChanged() }
          else if (t === "q") root.dismiss()
          else if (root.category.key === "walls" && t === "o") root.run("pick-files")
          else if (root.category.key === "walls" && t === "O") root.run("pick-dir")
          else if (t >= "1" && t <= String(root.categories.length)) {
            root.setCategory(Number(t) - 1)
            root.activate()
          }
          else return
          event.accepted = true
        }
      }

      Row {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        // ── Categories ───────────────────────────────────────────────
        Column {
          id: catColumn
          width: Style.space(260)
          height: parent.height
          spacing: Style.space(2)

          Text {
            text: "Customizer"
            color: root.selectedText
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            font.bold: true
            height: root.rowHeight
            verticalAlignment: Text.AlignVCenter
            leftPadding: Style.space(8)
          }

          Repeater {
            model: root.categories
            delegate: Rectangle {
              required property int index
              required property var modelData
              readonly property bool active: index === root.categoryIndex

              width: catColumn.width
              height: root.rowHeight
              radius: root.cornerRadius
              color: active ? root.selectedBackground : "transparent"
              border.width: active && root.pane === 0 ? 1 : 0
              border.color: root.selectedText

              Text {
                anchors.fill: parent
                anchors.leftMargin: Style.space(8)
                anchors.rightMargin: Style.space(8)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                textFormat: Text.PlainText
                text: (index + 1) + "  " + modelData.icon + "  " + modelData.title
                color: parent.active ? root.selectedText : root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.setCategory(index); root.pane = 1; root.selectionChanged() }
              }
            }
          }
        }

        Rectangle { width: 1; height: parent.height; color: Util.alpha(root.foreground, 0.12) }

        // ── Items ────────────────────────────────────────────────────
        Column {
          id: listColumn
          width: Style.space(340)
          height: parent.height
          spacing: root.contentSpacing

          Text {
            width: parent.width
            height: root.rowHeight
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            text: root.filtering ? "/" + root.filterText + "▏"
              : root.filterText ? "/" + root.filterText + "   (Esc clears)"
              : "/ filter · j k gg G · ^d ^u · J K preview · q"
            color: root.foreground
            opacity: root.filtering || root.filterText ? 1 : 0.5
            font.family: root.fontFamily
            font.pixelSize: Style.font.heading
            elide: Text.ElideRight
          }

          Item {
            width: parent.width
            height: parent.height - root.rowHeight - root.contentSpacing

            ListView {
              id: itemList
              anchors.fill: parent
              model: displayModel
              clip: true
              boundsBehavior: Flickable.StopAtBounds

              delegate: Rectangle {
                required property int index
                required property string label
                required property bool current

                readonly property bool hasCursor: index === root.selectedIndex

                width: itemList.width
                height: root.rowHeight
                radius: root.cornerRadius
                color: hasCursor ? root.selectedBackground : "transparent"
                border.width: hasCursor && root.pane === 1 ? 1 : 0
                border.color: root.selectedText

                Text {
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(8)
                  anchors.rightMargin: Style.space(8)
                  verticalAlignment: Text.AlignVCenter
                  elide: Text.ElideMiddle
                  textFormat: Text.PlainText
                  text: (parent.current ? "● " : "  ") + parent.label
                  color: parent.hasCursor ? root.selectedText : (parent.current ? root.accent : root.foreground)
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.pane = 1
                    root.selectedIndex = index
                    root.selectionChanged()
                    root.activate()
                  }
                  // Hover follows only inside the list pane, so a pointer that
                  // happens to rest over the card can't start an animation preview.
                  onContainsMouseChanged: if (containsMouse && root.pane === 1 && root.selectedIndex !== index) {
                    root.selectedIndex = index
                    root.selectionChanged()
                  }
                }
              }
            }

            Text {
              anchors.centerIn: parent
              visible: displayModel.count === 0
              textFormat: Text.PlainText
              text: root.loading ? "Loading…" : (root.filterText ? "No matches for “" + root.filterText + "”" : "Nothing here")
              color: root.foreground
              opacity: 0.6
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
            }
          }
        }

        Rectangle { width: 1; height: parent.height; color: Util.alpha(root.foreground, 0.12) }

        // ── Preview ──────────────────────────────────────────────────
        Column {
          width: parent.width - catColumn.width - listColumn.width - 2 - root.contentSpacing * 4
          height: parent.height
          spacing: root.contentSpacing

          Text {
            width: parent.width
            height: root.rowHeight
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            text: root.category.hint
            color: root.foreground
            opacity: 0.5
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            elide: Text.ElideRight
          }

          Item {
            id: previewBox
            width: parent.width
            height: parent.height - root.rowHeight - root.contentSpacing
            clip: true

            Image {
              anchors.fill: parent
              visible: root.category.image
              source: root.category.image && root.selectedRow && root.selectedRow.preview ? root.fileUrl(root.selectedRow.preview) : ""
              sourceSize.width: Math.max(1, previewBox.width)
              sourceSize.height: Math.max(1, previewBox.height)
              fillMode: Image.PreserveAspectFit
              asynchronous: true
              cache: false
            }

            Flickable {
              id: previewFlick
              anchors.fill: parent
              visible: !root.category.image
              contentHeight: previewLabel.implicitHeight
              boundsBehavior: Flickable.StopAtBounds

              Text {
                id: previewLabel
                width: parent.width
                wrapMode: Text.WrapAnywhere
                textFormat: Text.PlainText
                text: root.previewText || (root.category.key === "shaders" && root.selectedRow
                  ? "Toggle: on/off (last used shader) / next shader in the list" : "")
                color: root.foreground
                opacity: 0.85
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }
            }

            Text {
              anchors.centerIn: parent
              visible: root.category.image && root.selectedRow && !root.selectedRow.preview
              width: parent.width * 0.8
              horizontalAlignment: Text.AlignHCenter
              wrapMode: Text.WordWrap
              text: root.selectedRow && root.selectedRow.note ? root.selectedRow.note : "No preview image"
              color: root.foreground
              opacity: 0.5
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
            }
          }
        }
      }
    }
  }
}
