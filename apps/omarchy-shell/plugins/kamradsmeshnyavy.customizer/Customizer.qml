import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick 6.11
import QtQuick.Effects
import qs.Commons
import qs.Ui
// TransitionEffect — тот же шейдер переходов, что у обоев (превью Wallpaper FX).
import "../kamradsmeshnyavy.background"

// Quickshell port of scripts/bin/omarchy-customizer (the old fzf menu on
// SUPER+SHIFT+T). Header with what is in use now, then three panes:
// categories | filterable list | preview, and a key-hint footer.
// customizer.sh next to this file does the listing and applying, so the
// actions stay identical to the shell script.
Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string thumbDir: Quickshell.env("XDG_CACHE_HOME") ? Quickshell.env("XDG_CACHE_HOME") + "/omarchy-customizer/thumbs"
    : Quickshell.env("HOME") + "/.cache/omarchy-customizer/thumbs"
  readonly property string script: decodeURIComponent(String(Qt.resolvedUrl("customizer.sh")).replace(/^file:\/\//, ""))

  // key: customizer.sh category; image: preview pane shows the picture;
  // live: hovering a row previews it, Esc / leaving the category reverts;
  // bar: preview pane draws a bar mock (BarMock.qml); tweak: h/l step the row's value.
  readonly property var categories: [
    { key: "anims",       icon: "󰔡", title: "Animations",   hint: "Live preview while you browse",       image: false, live: true },
    { key: "themes",      icon: "󰏘", title: "Theme",        hint: "omarchy theme set",                    image: true,  live: false },
    { key: "theme-walls", icon: "󰸉", title: "Wallpaper",    hint: "Категории как в SUPER+CTRL+SPACE",      image: true,  live: false },
    { key: "walls",       icon: "󰃣", title: "Recolor",      hint: "Lutgen · O folder · o image(s)",       image: true,  live: false },
    { key: "shaders",     icon: "󰍹", title: "Shader",       hint: "crt-toggle.sh",                        image: false, live: false },
    { key: "opacity",     icon: "󰂵", title: "Transparency", hint: "Live preview · SUPER+ALT+O cycles",    image: false, live: true },
    { key: "blur",        icon: "󰂷", title: "Blur",         hint: "Live preview · SUPER+ALT+U cycles",    image: false, live: true },
    { key: "bar-skins",   icon: "󰉼", title: "Bar Skin",     hint: "Live preview · form, colors, glass",   image: false, live: true,  bar: true },
    { key: "bar-layouts", icon: "󰕮", title: "Bar Layout",   hint: "Sections & edge · shell.json",         image: false, live: false, bar: true },
    { key: "bar-tweaks",  icon: "󰒓", title: "Bar Tweaks",   hint: "h l / − + change · ⏎ custom color",    image: false, live: false, bar: true, tweak: true },
    { key: "lock",        icon: "󰌾", title: "Lock",         hint: "p — показать вживую · T — превью",     image: true,  live: false },
    { key: "lock-tweaks", icon: "󰷛", title: "Lock Tweaks",  hint: "h l change · p — показать",             image: false, live: false, tweak: true },
    { key: "wallpaper-fx", icon: "󰸉", title: "Wallpaper FX", hint: "Переходы обоев · p — проиграть",         image: false, live: false, fx: true },
    { key: "theme-switcher", icon: "󰸌", title: "Theme Switcher", hint: "Стиль пикера · ⚡ кэш · p — открыть", image: false, live: false, picker: true }
  ]

  // Tweaks rows whose ⏎ opens a picker (color, text, file) instead of stepping.
  readonly property var colorTweaks: ["background", "gradient", "border", "text", "active", "moduleBackground", "wsActiveColor", "ownerMessage", "avatar"]

  // Header chips: status key -> category key it opens.
  readonly property var statusChips: [
    { key: "theme",     icon: "󰏘", category: "themes" },
    { key: "wallpaper", icon: "󰸉", category: "theme-walls" },
    { key: "anims",     icon: "󰔡", category: "anims" },
    { key: "shader",    icon: "󰍹", category: "shaders" },
    { key: "opacity",   icon: "󰂵", category: "opacity" },
    { key: "blur",      icon: "󰂷", category: "blur" },
    { key: "bar-skin",  icon: "󰉼", category: "bar-skins" },
    { key: "lock",      icon: "󰌾", category: "lock" }
  ]

  property bool opened: false
  property int categoryIndex: 0
  property int pane: 0               // 0 = categories, 1 = items
  property string filterText: ""
  property int selectedIndex: 0
  property bool loading: false
  property var cache: ({})           // category key -> rows, dropped on every open
  property var items: []             // rows of the current category, unfiltered
  property string previewing: ""     // category key with a live preview applied
  property string previewText: ""
  property bool filtering: false     // "/" pressed: printable keys go to the filter
  property bool pendingG: false      // first "g" of "gg"
  property bool helpOpen: false
  property var status: ({})
  property var lastPointer: null     // window coords of the last hover event
  property string keepValue: ""      // row (by value) to stay on when a list reloads after a tweak
  property string wallPath: ""       // Wallpaper: папка-категория внутри ~/.config/omarchy/backgrounds/<тема>
  property string pendingTweak: ""   // a step that came in while the previous one ran (held key)
  property bool reloadQueued: false  // a reload asked for while the lister was busy
  property var themePalette: ({})    // colors.toml of the current theme, for the bar mock
  property var activeSkin: ({})      // ~/.config/omarchy/bar-skin.json
  property var activeBar: ({})       // ~/.config/omarchy/shell.json .bar
  property var activeFx: ({})        // ~/.config/omarchy/wallpaper-transition.json
  property var activePicker: ({})    // ~/.config/omarchy/image-picker.json

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
  readonly property color muted: Util.alpha(foreground, 0.55)
  readonly property color faint: Util.alpha(foreground, 0.08)
  readonly property color hairline: Util.alpha(foreground, 0.10)
  readonly property int cornerRadius: Style.cornerRadius
  readonly property int innerRadius: Math.max(4, cornerRadius - 2)
  property string fontFamily: Style.font.menuFamily
  property int contentMargin: Style.spacing.panelPadding
  property int contentSpacing: Style.spacing.md
  property int rowHeight: Math.max(Style.space(30), Style.font.title + Style.spacing.controlPaddingY * 2)
  readonly property int thumbRowHeight: Math.round(rowHeight * 1.7)
  property int cardWidth: Math.min(Style.space(1240), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(720), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.cache = ({})
    root.filtering = false
    root.helpOpen = false
    root.lastPointer = null
    root.opened = true
    root.pane = 0
    root.setCategory(root.categoryIndex, true)
    statusProc.running = false
    statusProc.running = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.revertPreview()
    root.opened = false
    root.syncBarPreview()
  }

  // Пока открыты категории бара, бар держится развёрнутым — иначе compact прячет
  // правки формы, высоты и цвета; на строках «Compact: …» бар показывает compact.
  property string barPreviewMode: ""
  function syncBarPreview() {
    var mode = "off"
    var k = root.category.key
    if (root.opened && (k === "bar-skins" || k === "bar-tweaks" || k === "bar-layouts")) {
      var row = root.selectedRow
      mode = row && root.isTweakRow(row) && /^compact/.test(root.tweakKey(row)) ? "compact" : "expanded"
    }
    if (mode === root.barPreviewMode) return
    root.barPreviewMode = mode
    Quickshell.execDetached(["omarchy-shell", "barskin", "preview", mode])
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

  function revertPreview() {
    previewTimer.stop()
    var key = root.previewing
    if (!key) return
    root.previewing = ""
    Quickshell.execDetached([root.script, key === "anims" ? "anim-restore" : key + "-restore"])
  }

  function setCategory(index, force) {
    if (index < 0 || index >= categories.length) return
    if (index === root.categoryIndex && !force) return
    root.revertPreview()
    root.categoryIndex = index
    root.pendingTweak = ""
    root.reloadQueued = false
    root.keepValue = ""
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

  function categoryIndexOf(key) {
    for (var i = 0; i < categories.length; i++) if (categories[i].key === key) return i
    return -1
  }

  function loadRows(key, raw) {
    var rows = []
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i]) continue
      var f = lines[i].split("\t")
      rows.push({ label: f[0] || "", value: f[1] || "", preview: f[2] || "", current: f[3] === "1",
        note: (f[4] || "").replace(/\\n/g, "\n"), sub: f[5] || "" })
    }
    var next = ({})
    for (var k in root.cache) next[k] = root.cache[k]
    next[key] = rows
    root.cache = next
    // Fill the thumbnail cache in the background; rows fall back to the source until then.
    var cat = categories[root.categoryIndexOf(key)]
    if (cat && cat.image) Quickshell.execDetached([root.script, "thumbs", key, key === "theme-walls" ? root.wallPath : ""])
    if (key !== root.category.key) return
    root.loading = false
    root.items = rows
    root.selectedIndex = root.keepValue ? root.indexOfValue(rows, root.keepValue) : root.currentIndexOf(rows)
    root.keepValue = ""
    root.rebuild()
    if (root.reloadQueued) { root.reloadQueued = false; root.reloadCategory() }
  }

  function indexOfValue(rows, value) {
    for (var i = 0; i < rows.length; i++) if (rows[i].value === value) return i
    return root.currentIndexOf(rows)
  }

  function loadStatus(raw) {
    var s = ({})
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var tab = lines[i].indexOf("\t")
      if (tab > 0) s[lines[i].slice(0, tab)] = lines[i].slice(tab + 1)
    }
    root.status = s
  }

  function statusText(key) {
    var v = root.status[key] || ""
    if (key === "wallpaper") v = v.replace(/^.*\//, "").replace(/\.[^.]+$/, "")
    return v || "—"
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
    root.revertPreview()
    root.pane = 0
  }

  // Rows that fit in the list, halved: the Ctrl+D / Ctrl+U step.
  function halfPage() {
    return Math.max(1, Math.floor(itemList.height / root.listRowHeight() / 2))
  }

  function listRowHeight() {
    if (root.category.image) return root.thumbRowHeight
    return root.category.tweak ? Math.round(root.rowHeight * 1.5) : root.rowHeight
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
    itemList.currentIndex = root.selectedIndex
    var row = root.selectedIndex >= 0 && root.selectedIndex < displayModel.count
      ? displayModel.get(root.selectedIndex) : null
    root.selectedRow = row ? { label: row.label, value: row.value, preview: row.preview, current: row.current, note: row.note } : null
    previewFile.path = (row && !root.category.image) ? row.preview : ""
    if (!row || root.category.image || !row.preview) root.previewText = ""
    if (root.category.live && root.pane === 1 && row) previewTimer.restart()
    root.syncBarPreview()
  }

  // Wallpaper: зайти в папку-категорию (или выйти по ".."), не закрывая overlay.
  // focusValue — строка, на которой встать после загрузки (папка, из которой вышли).
  function openWallDir(path, focusValue) {
    root.wallPath = path
    root.filterText = ""
    root.filtering = false
    root.reloadCategory()
    root.keepValue = focusValue || ""
  }

  // h / ← / Esc внутри папки: на уровень выше, курсор — на папку, из которой вышли.
  function wallUp() {
    if (root.category.key !== "theme-walls" || root.pane !== 1 || root.wallPath === "") return false
    var from = root.wallPath
    var cut = from.lastIndexOf("/")
    root.openWallDir(cut < 0 ? "" : from.slice(0, cut), "dir:" + from)
    return true
  }

  function activate() {
    if (root.pane === 0) {
      root.pane = 1
      root.selectionChanged()
      return
    }
    if (!root.selectedRow) return
    if (root.category.key === "theme-walls" && /^dir:/.test(root.selectedRow.value)) {
      var target = root.selectedRow.value.slice(4)
      // ".." ведёт к родителю — встать на папку, из которой вышли.
      if (target.length < root.wallPath.length && root.wallPath.indexOf(target) === 0) root.wallUp()
      else root.openWallDir(target, "")
      return
    }
    if (root.isTweakRow(root.selectedRow) && root.colorTweaks.indexOf(root.tweakKey(root.selectedRow)) === -1) root.tweak("+")
    else root.run(root.selectedRow.value)
  }

  // Bar Tweaks: step the selected parameter and reload the list on the same row.
  // The overlay stays open; the bar behind it and the mock follow bar-skin.json.
  // A held key autorepeats faster than customizer.sh runs: the latest step waits
  // in pendingTweak and runs when the previous one exits, and the list is only
  // re-read once the steps stop. Killing a running lister to restart it used to
  // deliver its partial output and drop the selection back to the first row.
  // Строка-настройка: вся категория tweak или строка "tweak:<key>" внутри галереи.
  function isTweakRow(row) {
    return row !== null && (root.category.tweak === true || /^tweak:/.test(row.value))
  }
  function tweakKey(row) { return String(row.value).replace(/^tweak:/, "") }

  function tweak(dir) {
    if (root.pane !== 1 || !root.selectedRow || !root.isTweakRow(root.selectedRow)) return
    if (tweaker.running) { root.pendingTweak = dir; return }
    tweaker.key = root.tweakKey(root.selectedRow)
    tweaker.command = [root.script, "tweak", tweaker.key, dir]
    tweaker.running = true
  }

  function tweakDone() {
    var next = root.pendingTweak
    root.pendingTweak = ""
    if (next && root.selectedRow && root.isTweakRow(root.selectedRow) && root.tweakKey(root.selectedRow) === tweaker.key) {
      tweaker.command = [root.script, "tweak", tweaker.key, next]
      tweaker.running = true
      return
    }
    root.reloadCategory()
  }

  function reloadCategory() {
    if (lister.running) { root.reloadQueued = true; return }
    var key = root.category.key
    var next = ({})
    for (var k in root.cache) if (k !== key) next[k] = root.cache[k]
    root.cache = next
    root.keepValue = root.selectedRow ? root.selectedRow.value : ""
    lister.category = key
    lister.running = true
  }

  function parseJson(text) {
    try {
      var v = JSON.parse(String(text || ""))
      return v && typeof v === "object" ? v : ({})
    } catch (e) {
      return ({})
    }
  }

  function parsePalette(text) {
    var out = ({})
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var m = lines[i].match(/^\s*([A-Za-z0-9_]+)\s*=\s*["'](#[0-9A-Fa-f]{6})["']/)
      if (m) out[m[1]] = m[2]
    }
    root.themePalette = out
  }

  // What the bar mock draws: the row's own skin / layout, the live one otherwise.
  function mockSkin() {
    if (root.category.key === "bar-skins" && root.previewText) return root.parseJson(root.previewText)
    return root.activeSkin
  }

  function mockBar() {
    if (root.category.key !== "bar-layouts" || !root.previewText) {
      if (root.category.key !== "bar-skins" || !root.previewText) return root.activeBar
      var b = ({})
      for (var k in root.activeBar) b[k] = root.activeBar[k]
      b.transparent = root.parseJson(root.previewText).transparent === true
      return b
    }
    var preset = root.parseJson(root.previewText)
    preset.transparent = root.activeBar.transparent === true
    return preset
  }

  // Rows "r" may land on: no picker / toggle actions, and not the one in use.
  function randomCandidates() {
    var out = []
    for (var i = 0; i < displayModel.count; i++) {
      var r = displayModel.get(i)
      if (/^(pick-|toggle$|next$|save$|regen-thumbs$|tweak:|cache$|prune$|none$|dir:)/.test(r.value) || r.current || i === root.selectedIndex) continue
      out.push(i)
    }
    return out
  }

  function randomPick() {
    if (root.category.key === "walls") return   // a random Lutgen run is too slow to be a toy
    if (root.category.tweak) return
    if (root.pane === 0) { root.pane = 1 }
    var c = root.randomCandidates()
    if (c.length === 0) return
    root.selectedIndex = c[Math.floor(Math.random() * c.length)]
    itemList.positionViewAtIndex(root.selectedIndex, ListView.Center)
    root.selectionChanged()
    root.run(root.selectedRow.value)
  }

  // Apply <value> in the current category. The overlay closes first: it holds
  // exclusive keyboard focus on the overlay layer, so a zenity picker opened by
  // customizer.sh would otherwise sit underneath it.
  function run(value) {
    var key = root.category.key
    // Apply owns the previewed setting from here, so no revert on close.
    if (root.previewing === key) { previewTimer.stop(); root.previewing = "" }
    root.dismiss()
    Quickshell.execDetached([root.script, "apply", key, value])
  }

  // Lock: показать дизайн по-настоящему (окно превью экрана блокировки поверх
  // всего). Overlay закрывается первым, иначе превью окажется под ним.
  function previewLock() {
    var id = root.category.key === "lock" && root.selectedRow ? root.selectedRow.value : ""
    if (id === "regen-thumbs") return
    root.dismiss()
    Quickshell.execDetached([root.script, "lock-preview", id])
  }

  // Wallpaper FX: выбрать эффект строки (если это эффект) и проиграть его на рабочем столе.
  function playFx() {
    var row = root.selectedRow
    var effect = row && !root.isTweakRow(row) ? row.value : ""
    root.dismiss()
    Quickshell.execDetached(["bash", "-c", (effect ? '"$0" apply wallpaper-fx "$1" && ' : "") + 'sleep 0.3; "$0" fx-replay',
      root.script, effect])
  }

  function thumbUrl(path) {
    return root.fileUrl(root.thumbDir + "/" + Qt.md5(path) + ".jpg")
  }

  function fileUrl(path) {
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  // The old fzf preview for shaders showed just the header comments and consts.
  function formatPreview(text) {
    if (root.category.key !== "shaders") return text
    return text.split("\n").filter(function(l) { return /^(\/\/|const)/.test(l) }).join("\n")
  }

  // Theme rows carry "#bg #fg #accent #red …" in the note column.
  function paletteOf(note) {
    return /^#[0-9a-fA-F]{3,8}( |$)/.test(note || "") ? note.split(" ") : []
  }

  // Numbers out of a note or status value, e.g. "size 6 passes 3 …" -> [6, 3, …].
  function numbersOf(text) {
    return (String(text || "").match(/\d+(\.\d+)?/g) || []).map(Number)
  }

  // What the preview stage shows: the row under the cursor for its own
  // setting, the saved preset for the other one.
  function stageOpacity() {
    var n = root.numbersOf(root.category.key === "opacity" && root.selectedRow ? root.selectedRow.note : root.status["opacity-values"])
    return n.length >= 2 ? [n[0], n[1]] : [1, 0.9]
  }

  // Hyprland blur size × passes squeezed into MultiEffect's 0..1 range.
  function stageBlur() {
    var n = root.numbersOf(root.category.key === "blur" && root.selectedRow ? root.selectedRow.note : root.status["blur-values"])
    if (n.length < 2 || n[0] === 0) return 0
    return Math.min(1, n[0] * n[1] / 48)
  }

  function keyHints() {
    if (root.filtering) return [["⏎", "keep filter"], ["Esc", "clear"], ["↑↓", "move"]]
    if (root.pane === 0) return [["j k", "category"], ["l ⏎", "open"], ["1–9 0", "jump"], ["/", "search"], ["?", "keys"], ["q", "close"]]
    if (root.category.key === "lock-tweaks") return [["j k", "move"], ["h l  − +", "change (hold)"], ["x", "default"], ["⏎", "step · pick"], ["p", "preview"], ["Esc", "back"]]
    if (root.category.tweak) return [["j k", "move"], ["h l  − +", "change (hold)"], ["x", "default"], ["⏎", "step · pick color"], ["Esc", "back"], ["?", "keys"]]
    if (root.category.fx || root.category.picker) {
      var tw = root.isTweakRow(root.selectedRow)
      return tw ? [["j k", "move"], ["h l  − +", "change (hold)"], ["x", "default"], ["p", root.category.fx ? "play" : "open"], ["Esc", "back"]]
        : [["j k", "move"], ["⏎", "apply"], ["p", root.category.fx ? "play on desktop" : "open switcher"], ["/", "search"], ["h", "back"], ["?", "keys"]]
    }
    if (root.category.key === "lock") return [["j k", "move"], ["⏎", "apply"], ["p", "preview live"], ["T", "refresh previews"], ["/", "search"], ["h", "back"], ["?", "keys"]]
    var h = [["j k", "move"], ["⏎", "apply"], ["/", "search"], ["h", "back"]]
    if (root.category.key !== "walls") h.push(["r", "random"])
    else h.push(["o O", "pick"])
    if (!root.category.image && !root.category.bar && root.category.key !== "opacity" && root.category.key !== "blur") h.push(["J K", "scroll"])
    h.push(["?", "keys"])
    return h
  }

  ListModel { id: displayModel }

  Timer { id: gTimer; interval: 700; onTriggered: root.pendingG = false }

  Process {
    id: lister
    property string category: ""
    command: [root.script, "list", category, category === "theme-walls" ? root.wallPath : ""]
    stdout: StdioCollector {
      onStreamFinished: root.loadRows(lister.category, text)
    }
  }

  Process {
    id: statusProc
    command: [root.script, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.loadStatus(text)
    }
  }

  FileView {
    id: previewFile
    blockLoading: false
    printErrors: false
    // Bar Tweaks rows all preview bar-skin.json, which changes under them.
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.previewText = root.formatPreview(text())
    onLoadFailed: root.previewText = ""
  }

  Process {
    id: tweaker
    property string key: ""
    onExited: root.tweakDone()
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/bar-skin.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.activeSkin = root.parseJson(text())
    onLoadFailed: root.activeSkin = ({})
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/wallpaper-transition.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.activeFx = root.parseJson(text())
    onLoadFailed: root.activeFx = ({})
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/image-picker.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.activePicker = root.parseJson(text())
    onLoadFailed: root.activePicker = ({})
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/shell.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.activeBar = root.parseJson(text()).bar || ({})
  }

  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.parsePalette(text())
  }

  // Live preview, debounced so scrolling doesn't reload Hyprland per row.
  Timer {
    id: previewTimer
    interval: 250
    onTriggered: {
      var row = root.selectedRow
      var key = root.category.key
      if (!row || !root.opened || !root.category.live) return
      root.previewing = key
      Quickshell.execDetached([root.script, key === "anims" ? "anim-preview" : key + "-preview", row.value])
    }
  }

  // ── Small building blocks ──────────────────────────────────────────

  // Inline components cannot see ids of this file, so only singletons here.
  component Keycap: Rectangle {
    property string label: ""
    implicitWidth: Math.max(height, capText.implicitWidth + Style.space(10))
    implicitHeight: Style.font.caption + Style.space(8)
    radius: Style.space(4)
    color: Util.alpha(Color.menu.text, 0.08)
    border.width: 1
    border.color: Util.alpha(Color.menu.text, 0.10)
    Text {
      id: capText
      anchors.centerIn: parent
      text: parent.label
      color: Color.menu.text
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
      font.bold: true
    }
  }

  component Hint: Row {
    property string keys: ""
    property string label: ""
    spacing: Style.space(6)
    Keycap { label: parent.keys; anchors.verticalCenter: parent.verticalCenter }
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: parent.label
      color: Util.alpha(Color.menu.text, 0.55)
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
    }
  }

  component Pill: Rectangle {
    property string label: ""
    property color tone: Color.accent
    implicitWidth: pillText.implicitWidth + Style.space(14)
    implicitHeight: Style.font.caption + Style.space(8)
    radius: height / 2
    color: Util.alpha(tone, 0.16)
    border.width: 1
    border.color: Util.alpha(tone, 0.45)
    Text {
      id: pillText
      anchors.centerIn: parent
      text: parent.label
      color: parent.tone
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 0.6
    }
  }

  // ── Window ─────────────────────────────────────────────────────────

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-customizer"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
      opacity: root.opened ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 160 } }
    }
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

      // Pop in on open.
      opacity: root.opened ? 1 : 0
      scale: root.opened ? 1 : 0.97
      Behavior on opacity { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

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

          if (root.helpOpen) {
            if (k === Qt.Key_Escape || t === "?" || t === "q") root.helpOpen = false
            event.accepted = true
            return
          }

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

          var tweaking = root.pane === 1 && !ctrl && root.isTweakRow(root.selectedRow)
          if (tweaking && (t === "h" || t === "-" || k === Qt.Key_Left)) root.tweak("-")
          else if (tweaking && (t === "l" || t === "+" || t === "=" || k === Qt.Key_Right)) root.tweak("+")
          else if (tweaking && t === "x") root.tweak("reset")
          else if (!ctrl && t === "p" && (root.category.key === "lock" || root.category.key === "lock-tweaks")) root.previewLock()
          else if (!ctrl && t === "T" && root.category.key === "lock") root.run("regen-thumbs")
          else if (!ctrl && t === "p" && root.category.key === "wallpaper-fx") root.playFx()
          else if (!ctrl && t === "p" && root.category.key === "theme-switcher") { root.dismiss(); Quickshell.execDetached([root.script, "picker-open"]) }
          else if (ctrl && root.category.key === "walls" && k === Qt.Key_O) root.run("pick-files")
          else if (ctrl && (k === Qt.Key_D)) root.move(root.halfPage())
          else if (ctrl && (k === Qt.Key_U)) root.move(-root.halfPage())
          else if (ctrl && (k === Qt.Key_F)) root.move(root.halfPage() * 2)
          else if (ctrl && (k === Qt.Key_B)) root.move(-root.halfPage() * 2)
          else if (ctrl && (k === Qt.Key_N)) root.move(1)
          else if (ctrl && (k === Qt.Key_P)) root.move(-1)
          else if (k === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else if (root.pane === 1) { if (!root.wallUp()) root.toCategories() }
            else root.dismiss()
          }
          else if (k === Qt.Key_Return || k === Qt.Key_Enter) root.activate()
          else if (k === Qt.Key_Up) root.move(-1)
          else if (k === Qt.Key_Down) root.move(1)
          else if (k === Qt.Key_PageUp) root.move(-root.halfPage() * 2)
          else if (k === Qt.Key_PageDown) root.move(root.halfPage() * 2)
          else if (k === Qt.Key_Home) root.moveTo(0)
          else if (k === Qt.Key_End) root.moveTo(-1)
          else if (k === Qt.Key_Left || k === Qt.Key_Backtab) { if (!root.wallUp()) root.toCategories() }
          else if (k === Qt.Key_Right || k === Qt.Key_Tab) { if (root.pane === 0) root.activate() }
          else if (ctrl || !printable) return
          else if (t === "j") root.move(1)
          else if (t === "k") root.move(-1)
          else if (t === "h") { if (!root.wallUp()) root.toCategories() }
          else if (t === "l") { if (root.pane === 0) root.activate() }
          else if (t === "g") { if (pendingG) root.moveTo(0); else { root.pendingG = true; gTimer.restart() } }
          else if (t === "G") root.moveTo(-1)
          else if (t === "J") root.scrollPreview(1)
          else if (t === "K") root.scrollPreview(-1)
          else if (t === "/") { root.filtering = true; root.pane = 1; root.selectionChanged() }
          else if (t === "?") root.helpOpen = true
          else if (t === "q") root.dismiss()
          else if (t === "r") root.randomPick()
          else if (root.category.key === "walls" && t === "o") root.run("pick-files")
          else if (root.category.key === "walls" && t === "O") root.run("pick-dir")
          else if (t >= "0" && t <= "9" && (t === "0" ? 9 : Number(t) - 1) < root.categories.length) {
            root.setCategory(t === "0" ? 9 : Number(t) - 1)
            root.activate()
          }
          else return
          event.accepted = true
        }
      }

      Item {
        id: content
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset

        // ── Header ─────────────────────────────────────────────────
        Item {
          id: header
          anchors { top: parent.top; left: parent.left; right: parent.right }
          height: Math.round(root.rowHeight * 1.6)

          Rectangle {
            id: logo
            anchors.verticalCenter: parent.verticalCenter
            width: Math.round(header.height * 0.82)
            height: width
            radius: root.innerRadius + 2
            gradient: Gradient {
              orientation: Gradient.Vertical
              GradientStop { position: 0; color: Util.alpha(root.accent, 0.95) }
              GradientStop { position: 1; color: Util.alpha(root.accent, 0.55) }
            }
            Text {
              anchors.centerIn: parent
              text: "󰸌"
              color: root.background
              font.family: root.fontFamily
              font.pixelSize: Math.round(parent.height * 0.5)
            }
          }

          Column {
            anchors.left: logo.right
            anchors.leftMargin: Style.space(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)
            Text {
              text: "Customizer"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
              font.bold: true
            }
            Text {
              text: "Look & feel · Hyprland × Omarchy"
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.letterSpacing: 0.8
            }
          }

          // What is in use right now; clicking a chip opens its category.
          Row {
            id: chips
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(6)

            Repeater {
              model: root.statusChips
              delegate: Rectangle {
                required property var modelData
                readonly property bool hot: root.category.key === modelData.category
                height: Style.font.body + Style.space(14)
                width: Math.min(Style.space(190), chipRow.implicitWidth + Style.space(18))
                radius: height / 2
                color: hot ? Util.alpha(root.accent, 0.16) : root.faint
                border.width: 1
                border.color: hot ? Util.alpha(root.accent, 0.5) : root.hairline
                Behavior on color { ColorAnimation { duration: 140 } }

                Row {
                  id: chipRow
                  anchors.centerIn: parent
                  spacing: Style.space(6)
                  width: Math.min(implicitWidth, parent.width - Style.space(18))
                  Text {
                    id: chipIcon
                    text: modelData.icon
                    color: root.accent
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                  }
                  Text {
                    width: Math.min(implicitWidth, Style.space(190) - Style.space(18) - chipIcon.width - Style.space(6))
                    text: root.statusText(modelData.key)
                    elide: Text.ElideRight
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.bodySmall
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    var i = root.categoryIndexOf(modelData.category)
                    if (i < 0) return
                    root.setCategory(i)
                    root.pane = 1
                    root.selectionChanged()
                  }
                }
              }
            }
          }
        }

        Rectangle {
          id: headerRule
          anchors { top: header.bottom; topMargin: root.contentSpacing; left: parent.left; right: parent.right }
          height: 1
          color: root.hairline
        }

        // ── Footer: contextual key hints ───────────────────────────
        Item {
          id: footer
          anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
          height: Style.font.caption + Style.space(12)

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(16)
            Repeater {
              model: root.keyHints()
              delegate: Hint {
                required property var modelData
                keys: modelData[0]
                label: modelData[1]
              }
            }
          }

          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.category.icon + "  " + root.category.hint
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        Rectangle {
          id: footerRule
          anchors { bottom: footer.top; bottomMargin: Style.space(8); left: parent.left; right: parent.right }
          height: 1
          color: root.hairline
        }

        // ── Body ───────────────────────────────────────────────────
        Item {
          id: body
          anchors {
            top: headerRule.bottom; topMargin: root.contentSpacing
            bottom: footerRule.top; bottomMargin: root.contentSpacing
            left: parent.left; right: parent.right
          }

          // Categories — прокручиваются, когда не влезают (активная всегда видна).
          Flickable {
            id: catFlick
            width: Style.space(250)
            height: parent.height
            contentHeight: catColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            function ensureVisible(item) {
              var y = item.y
              if (y < contentY) contentY = y
              else if (y + item.height > contentY + height) contentY = y + item.height - height
            }

          Column {
            id: catColumn
            width: catFlick.width
            spacing: Style.space(4)

            Text {
              text: "CATEGORIES"
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.4
              leftPadding: Style.space(6)
              bottomPadding: Style.space(4)
            }

            Repeater {
              model: root.categories
              delegate: Rectangle {
                id: catRow
                required property int index
                required property var modelData
                readonly property bool active: index === root.categoryIndex
                readonly property bool focused: active && root.pane === 0
                onActiveChanged: if (active) Qt.callLater(catFlick.ensureVisible, catRow)

                width: catColumn.width
                height: Math.round(root.rowHeight * 1.45)
                radius: root.innerRadius
                color: active ? root.selectedBackground : (catHover.containsMouse ? root.faint : "transparent")
                border.width: focused ? 1 : 0
                border.color: Util.alpha(root.accent, 0.6)
                Behavior on color { ColorAnimation { duration: 120 } }

                Rectangle {
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  width: 3
                  height: catRow.active ? parent.height * 0.5 : 0
                  radius: 2
                  color: root.accent
                  Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                }

                Rectangle {
                  id: badge
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(10)
                  anchors.verticalCenter: parent.verticalCenter
                  width: Math.round(parent.height * 0.62)
                  height: width
                  radius: root.innerRadius
                  color: Util.alpha(root.accent, catRow.active ? 0.22 : 0.08)
                  Behavior on color { ColorAnimation { duration: 140 } }
                  Text {
                    anchors.centerIn: parent
                    text: catRow.modelData.icon
                    color: catRow.active ? root.accent : root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.iconLarge
                  }
                }

                Column {
                  anchors.left: badge.right
                  anchors.leftMargin: Style.space(10)
                  anchors.right: numCap.left
                  anchors.rightMargin: Style.space(6)
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(1)
                  Text {
                    width: parent.width
                    text: catRow.modelData.title
                    elide: Text.ElideRight
                    color: catRow.active ? root.selectedText : root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.title
                    font.bold: catRow.active
                  }
                  Text {
                    width: parent.width
                    text: catRow.modelData.hint
                    elide: Text.ElideRight
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }
                }

                Keycap {
                  id: numCap
                  anchors.right: parent.right
                  anchors.rightMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter
                  label: catRow.index < 10 ? String((catRow.index + 1) % 10) : ""
                  visible: catRow.index < 10
                  opacity: catRow.active ? 1 : 0.6
                }

                MouseArea {
                  id: catHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: { root.setCategory(catRow.index); root.pane = 1; root.selectionChanged() }
                }
              }
            }
          }

          }

          Rectangle {
            id: rule1
            anchors.left: catFlick.right
            anchors.leftMargin: root.contentSpacing
            width: 1; height: parent.height; color: root.hairline
          }

          // Items
          Item {
            id: listColumn
            anchors.left: rule1.right
            anchors.leftMargin: root.contentSpacing
            width: Style.space(360)
            height: parent.height

            Rectangle {
              id: search
              width: parent.width
              height: root.rowHeight
              radius: height / 2
              color: root.faint
              border.width: 1
              border.color: root.filtering ? Util.alpha(root.accent, 0.7) : root.hairline
              Behavior on border.color { ColorAnimation { duration: 140 } }

              Text {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍉"
                color: root.filtering ? root.accent : root.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
              }

              Text {
                anchors.left: searchIcon.right
                anchors.leftMargin: Style.space(8)
                anchors.right: count.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                text: root.filtering ? root.filterText + "▏"
                  : root.filterText ? root.filterText
                  : root.category.key === "theme-walls" && root.wallPath ? "󰉋 " + root.wallPath + "  ( / )"
                  : "Search " + root.category.title.toLowerCase() + "…  ( / )"
                color: root.filtering || root.filterText ? root.foreground : root.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideLeft
              }

              Text {
                id: count
                anchors.right: parent.right
                anchors.rightMargin: Style.space(12)
                anchors.verticalCenter: parent.verticalCenter
                text: displayModel.count ? (root.selectedIndex + 1) + " / " + displayModel.count : ""
                color: root.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }
            }

            ListView {
              id: itemList
              anchors { top: search.bottom; topMargin: root.contentSpacing; bottom: parent.bottom; left: parent.left; right: parent.right }
              model: displayModel
              clip: true
              spacing: Style.space(2)
              boundsBehavior: Flickable.StopAtBounds
              highlightFollowsCurrentItem: true
              highlightMoveDuration: 120
              highlightResizeDuration: 0
              highlight: Rectangle {
                radius: root.innerRadius
                color: root.selectedBackground
                border.width: root.pane === 1 ? 1 : 0
                border.color: Util.alpha(root.accent, 0.6)
              }

              delegate: Item {
                id: itemRow
                required property int index
                required property string label
                required property string preview
                required property string note
                required property string sub
                required property bool current

                readonly property bool hasCursor: index === root.selectedIndex
                readonly property var palette: root.paletteOf(note)

                width: itemList.width
                // Длинные подписи переносятся (до двух строк) — строка растёт под них.
                height: root.category.image ? root.listRowHeight()
                  : Math.max(root.listRowHeight(), rowText.implicitHeight + Style.space(12))

                ClippingRectangle {
                  id: thumb
                  visible: root.category.image
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(6)
                  anchors.verticalCenter: parent.verticalCenter
                  width: visible ? Math.round(height * 1.6) : 0
                  height: parent.height - Style.space(10)
                  radius: root.innerRadius - 1
                  color: root.faint

                  Image {
                    // Cached thumbnail first; the full image only while the cache fills.
                    property bool fallback: false
                    anchors.fill: parent
                    source: !thumb.visible || !itemRow.preview ? ""
                      : fallback ? root.fileUrl(itemRow.preview) : root.thumbUrl(itemRow.preview)
                    onStatusChanged: if (status === Image.Error && !fallback) fallback = true
                    sourceSize.width: Math.max(1, thumb.width * 2)
                    sourceSize.height: Math.max(1, thumb.height * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                  }
                  Text {
                    anchors.centerIn: parent
                    visible: !itemRow.preview
                    text: /^pick-dir/.test(itemRow.label) || itemRow.label.indexOf("folder") >= 0 ? "󰉋" : "󰋩"
                    color: root.accent
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.iconLarge
                  }
                }

                Text {
                  id: rowIcon
                  visible: !root.category.image
                  anchors.left: parent.left
                  anchors.leftMargin: Style.space(12)
                  anchors.verticalCenter: parent.verticalCenter
                  width: visible ? implicitWidth : 0
                  text: itemRow.current ? "󰄬" : root.category.icon
                  color: itemRow.current ? root.accent : Util.alpha(root.foreground, itemRow.hasCursor ? 0.8 : 0.35)
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                }

                Column {
                  id: rowText
                  anchors.left: root.category.image ? thumb.right : rowIcon.right
                  anchors.leftMargin: Style.space(10)
                  anchors.right: activePill.visible ? activePill.left : parent.right
                  anchors.rightMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(4)

                  Text {
                    width: parent.width
                    // Имена файлов — одной строкой с многоточием в середине, остальное переносится.
                    wrapMode: root.category.image ? Text.NoWrap : Text.Wrap
                    maximumLineCount: root.category.image ? 1 : 2
                    elide: root.category.image ? Text.ElideMiddle : Text.ElideRight
                    textFormat: Text.PlainText
                    text: itemRow.label
                    color: itemRow.hasCursor ? root.selectedText : (itemRow.current ? root.accent : root.foreground)
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.title
                    font.bold: itemRow.current
                  }

                  // Second line, e.g. a Bar Tweaks default.
                  Text {
                    visible: itemRow.sub !== ""
                    width: parent.width
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    text: itemRow.sub
                    color: root.muted
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                  }

                  // Theme palette dots.
                  Row {
                    visible: itemRow.palette.length > 0
                    spacing: Style.space(3)
                    Repeater {
                      model: itemRow.palette
                      delegate: Rectangle {
                        required property string modelData
                        width: Style.space(10); height: width; radius: width / 2
                        color: modelData
                        border.width: 1
                        border.color: root.hairline
                      }
                    }
                  }
                }

                Pill {
                  id: activePill
                  visible: itemRow.current
                  anchors.right: parent.right
                  anchors.rightMargin: Style.space(8)
                  anchors.verticalCenter: parent.verticalCenter
                  label: "ACTIVE"
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.pane = 1
                    root.selectedIndex = itemRow.index
                    root.selectionChanged()
                    root.activate()
                  }
                  // Only a pointer that actually moves takes the cursor. Qt also sends
                  // hover events when rows are created or scrolled under a resting
                  // pointer, which would steal the selection (and start a live
                  // preview) as soon as a list loads; those keep the same window position.
                  onPositionChanged: function(mouse) {
                    var p = mapToItem(null, mouse.x, mouse.y)
                    var last = root.lastPointer
                    root.lastPointer = { x: p.x, y: p.y }
                    if (!last || (Math.abs(p.x - last.x) < 1 && Math.abs(p.y - last.y) < 1)) return
                    if (root.pane === 1 && root.selectedIndex !== itemRow.index) {
                      root.selectedIndex = itemRow.index
                      root.selectionChanged()
                    }
                  }
                }
              }
            }

            Column {
              anchors.centerIn: itemList
              visible: displayModel.count === 0
              spacing: Style.space(6)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.loading ? "󰔟" : "󰈈"
                color: root.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.displayLarge
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                textFormat: Text.PlainText
                text: root.loading ? "Loading…" : (root.filterText ? "No matches for “" + root.filterText + "”" : "Nothing here")
                color: root.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
              }
            }
          }

          Rectangle {
            id: rule2
            anchors.left: listColumn.right
            anchors.leftMargin: root.contentSpacing
            width: 1; height: parent.height; color: root.hairline
          }

          // Preview
          Item {
            id: previewColumn
            anchors.left: rule2.right
            anchors.leftMargin: root.contentSpacing
            anchors.right: parent.right
            height: parent.height

            Item {
              id: previewHead
              width: parent.width
              height: Math.max(root.rowHeight, headTitle.implicitHeight)

              Text {
                id: headTitle
                anchors.left: parent.left
                anchors.right: headPill.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                text: root.selectedRow ? root.selectedRow.label : root.category.title
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.heading
                font.bold: true
              }

              Pill {
                id: headPill
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.selectedRow !== null && (root.selectedRow.current || root.previewing === root.category.key)
                label: root.selectedRow && root.selectedRow.current ? "IN USE" : "LIVE PREVIEW"
                tone: root.selectedRow && root.selectedRow.current ? root.accent : Color.urgent
              }
            }

            ClippingRectangle {
              id: previewBox
              anchors { top: previewHead.bottom; topMargin: root.contentSpacing; bottom: actions.top; bottomMargin: root.contentSpacing; left: parent.left; right: parent.right }
              radius: root.innerRadius + 2
              color: root.faint
              border.width: 1
              border.color: root.hairline

              // Pictures: crop wallpapers to fill, keep theme screenshots whole.
              Image {
                id: previewImage
                anchors.fill: parent
                visible: root.category.image
                source: root.category.image && root.selectedRow && root.selectedRow.preview ? root.fileUrl(root.selectedRow.preview) : ""
                sourceSize.width: Math.max(1, previewBox.width * 2)
                sourceSize.height: Math.max(1, previewBox.height * 2)
                fillMode: root.category.key === "themes" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                opacity: status === Image.Ready ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
              }

              // Theme palette strip along the bottom edge.
              Row {
                id: paletteStrip
                visible: root.category.key === "themes" && root.selectedRow !== null && root.paletteOf(root.selectedRow.note).length > 0
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: Style.space(30)
                Repeater {
                  model: root.selectedRow ? root.paletteOf(root.selectedRow.note) : []
                  delegate: Rectangle {
                    required property string modelData
                    width: paletteStrip.width / Math.max(1, root.paletteOf(root.selectedRow ? root.selectedRow.note : "").length)
                    height: paletteStrip.height
                    color: modelData
                  }
                }
              }

              Column {
                anchors.centerIn: parent
                visible: root.category.image && root.selectedRow !== null && !root.selectedRow.preview
                width: parent.width * 0.8
                spacing: Style.space(8)
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: "󰋩"
                  color: root.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.displayLarge * 2
                }
                Text {
                  width: parent.width
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                  text: root.selectedRow && root.selectedRow.note ? root.selectedRow.note : "No preview image"
                  color: root.muted
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                }
              }

              // Transparency / blur: two mock windows over the current wallpaper.
              // Like Hyprland with xray on, each window blurs the wallpaper
              // behind it and lays its own background on top at its opacity.
              Item {
                id: opacityStage
                anchors.fill: parent
                visible: (root.category.key === "opacity" || root.category.key === "blur") && root.selectedRow !== null
                readonly property var values: root.stageOpacity()
                readonly property real blurAmount: root.stageBlur()
                readonly property url wallpaper: visible && root.status.wallpaper ? root.fileUrl(root.status.wallpaper) : ""

                Image {
                  anchors.fill: parent
                  source: opacityStage.wallpaper
                  sourceSize.width: Math.max(1, previewBox.width)
                  sourceSize.height: Math.max(1, previewBox.height)
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                }

                Repeater {
                  model: [
                    { name: "inactive", x: 0.08, y: 0.12, w: 0.55, h: 0.55, value: 1 },
                    { name: "active",   x: 0.36, y: 0.34, w: 0.56, h: 0.54, value: 0 }
                  ]
                  delegate: Item {
                    id: mockWindow
                    required property var modelData
                    readonly property bool isActive: modelData.name === "active"
                    readonly property real level: opacityStage.values[modelData.value]
                    x: opacityStage.width * modelData.x
                    y: opacityStage.height * modelData.y
                    width: opacityStage.width * modelData.w
                    height: opacityStage.height * modelData.h

                    ClippingRectangle {
                      anchors.fill: parent
                      radius: root.innerRadius
                      color: "transparent"

                      Image {
                        x: -mockWindow.x
                        y: -mockWindow.y
                        width: opacityStage.width
                        height: opacityStage.height
                        source: opacityStage.wallpaper
                        sourceSize.width: Math.max(1, previewBox.width)
                        sourceSize.height: Math.max(1, previewBox.height)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: opacityStage.blurAmount > 0
                        layer.enabled: visible
                        layer.effect: MultiEffect {
                          blurEnabled: true
                          blur: opacityStage.blurAmount
                          blurMax: 48
                          autoPaddingEnabled: false
                        }
                      }
                    }

                    Rectangle {
                      anchors.fill: parent
                      radius: root.innerRadius
                      color: Util.alpha(Color.background, mockWindow.level)
                      border.width: 2
                      border.color: mockWindow.isActive ? root.accent : Util.alpha(root.foreground, 0.25)
                      Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Column {
                      anchors.fill: parent
                      anchors.margins: Style.space(14)
                      spacing: Style.space(8)
                      Row {
                        spacing: Style.space(6)
                        Repeater {
                          model: 3
                          delegate: Rectangle {
                            width: Style.space(9); height: width; radius: width / 2
                            color: Util.alpha(root.foreground, 0.35)
                          }
                        }
                      }
                      Text {
                        text: (mockWindow.isActive ? "active" : "inactive") + "  " + mockWindow.level.toFixed(2)
                        color: Color.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.heading
                        font.bold: true
                      }
                      Repeater {
                        model: [0.9, 0.7, 0.8, 0.5]
                        delegate: Rectangle {
                          required property real modelData
                          width: (opacityStage.width * 0.4) * modelData
                          height: Style.space(6)
                          radius: 3
                          color: Util.alpha(Color.foreground, 0.3)
                        }
                      }
                    }
                  }
                }

                // Which preset each half of the stage comes from.
                Pill {
                  anchors.left: parent.left
                  anchors.bottom: parent.bottom
                  anchors.margins: Style.space(12)
                  tone: Color.foreground
                  label: "opacity " + (root.category.key === "opacity" && root.selectedRow ? root.selectedRow.value : root.status.opacity || "—")
                    + "  ·  blur " + (root.category.key === "blur" && root.selectedRow ? root.selectedRow.value : root.status.blur || "—")
                }
              }

              // Bar: a mock of kamradsmeshnyavy.bar over the wallpaper, then the row's note.
              Item {
                id: barStage
                anchors.fill: parent
                visible: root.category.bar === true && root.selectedRow !== null
                readonly property url wallpaper: visible && root.status.wallpaper ? root.fileUrl(root.status.wallpaper) : ""
                readonly property var bar: root.mockBar()
                readonly property bool vertical: bar.position === "left" || bar.position === "right"

                ClippingRectangle {
                  id: barScreen
                  anchors { top: parent.top; left: parent.left; right: parent.right; margins: Style.space(12) }
                  // A strip of the screen: the edge the bar sits on and a bit of desktop.
                  height: barStage.vertical ? parent.height * 0.62 : Math.max(Style.space(90), parent.height * 0.32)
                  radius: root.innerRadius
                  color: "transparent"

                  Image {
                    anchors.fill: parent
                    source: barStage.wallpaper
                    sourceSize.width: Math.max(1, previewBox.width)
                    sourceSize.height: Math.max(1, previewBox.height)
                    fillMode: Image.PreserveAspectCrop
                    verticalAlignment: barStage.bar.position === "bottom" ? Image.AlignBottom : Image.AlignTop
                    asynchronous: true
                  }

                  BarMock {
                    anchors.fill: parent
                    skin: root.mockSkin()
                    bar: barStage.bar
                    palette: root.themePalette
                    screenWidth: panel.screen ? panel.screen.width : 1440
                  }
                }

                Flickable {
                  anchors { top: barScreen.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: Style.space(14) }
                  contentHeight: barNote.implicitHeight
                  boundsBehavior: Flickable.StopAtBounds
                  clip: true
                  Text {
                    id: barNote
                    width: parent.width
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    lineHeight: 1.2
                    text: !root.selectedRow ? ""
                      : root.selectedRow.note + (root.category.key === "bar-skins" && root.previewText ? "\n\n" + root.previewText : "")
                    color: root.foreground
                    opacity: 0.85
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }
                }
              }

              // Wallpaper FX: выбранный эффект крутится между текущими и следующими обоями.
              Item {
                id: fxStage
                anchors.fill: parent
                visible: root.category.fx === true && root.selectedRow !== null
                readonly property string effect: {
                  var row = root.selectedRow
                  var e = row && !root.isTweakRow(row) ? row.value : String(root.activeFx.type || "slant")
                  return e === "none" || e === "random" ? "fade" : e
                }
                readonly property int duration: Math.max(150, Number(root.activeFx.duration) || 420)

                ClippingRectangle {
                  id: fxScreen
                  anchors { top: parent.top; left: parent.left; right: parent.right; margins: Style.space(12) }
                  height: width * 0.5625
                  radius: root.innerRadius
                  color: "transparent"

                  Image {
                    id: fxFrom
                    anchors.fill: parent
                    source: fxStage.visible && root.status["wallpaper-next"] ? root.fileUrl(root.status["wallpaper-next"]) : ""
                    sourceSize.width: Math.max(1, fxScreen.width)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                  }
                  Image {
                    id: fxTo
                    anchors.fill: parent
                    source: fxStage.visible && root.status.wallpaper ? root.fileUrl(root.status.wallpaper) : ""
                    sourceSize.width: Math.max(1, fxScreen.width)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                  }
                  TransitionEffect {
                    id: fxEffect
                    anchors.fill: parent
                    visible: fxStage.visible && fxFrom.status === Image.Ready && fxTo.status === Image.Ready
                    fromItem: fxFrom
                    toItem: fxTo
                    effect: fxStage.effect
                    angleDegrees: Number(root.activeFx.angle || 0)
                    softness: root.activeFx.softness !== undefined ? Number(root.activeFx.softness) : 0.02
                    origin: Qt.point(0.5, 0.5)
                    // Цикл: переход (длительность из настроек), пауза, заново.
                    SequentialAnimation on progress {
                      running: fxEffect.visible
                      loops: Animation.Infinite
                      NumberAnimation { from: 0; to: 1; duration: fxStage.duration * 2; easing.type: Easing.InOutCubic }
                      PauseAnimation { duration: 700 }
                    }
                  }
                }

                Flickable {
                  anchors { top: fxScreen.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: Style.space(14) }
                  contentHeight: fxNote.implicitHeight
                  boundsBehavior: Flickable.StopAtBounds
                  clip: true
                  Text {
                    id: fxNote
                    width: parent.width
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    lineHeight: 1.2
                    text: (root.selectedRow ? root.selectedRow.note : "") + "\n\nВ превью переход замедлен вдвое."
                    color: root.foreground
                    opacity: 0.85
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }
                }
              }

              // Theme Switcher: макет карусели в выбранном (или текущем) стиле.
              Item {
                id: pickerStage
                anchors.fill: parent
                visible: root.category.picker === true && root.selectedRow !== null
                readonly property string style: {
                  var row = root.selectedRow
                  return row && /^style:/.test(row.value) ? row.value.slice(6) : String(root.activePicker.style || "slices")
                }

                Rectangle {
                  id: pickerScreen
                  anchors { top: parent.top; left: parent.left; right: parent.right; margins: Style.space(12) }
                  height: width * 0.42
                  radius: root.innerRadius
                  color: Util.alpha(Color.background, 0.9)
                  clip: true
                  PickerMock {
                    anchors.fill: parent
                    anchors.margins: Style.space(10)
                    style: pickerStage.style
                    config: root.activePicker
                    images: root.status["picker-previews"] ? String(root.status["picker-previews"]).split("|") : []
                  }
                }

                Flickable {
                  anchors { top: pickerScreen.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: Style.space(14) }
                  contentHeight: pickerNote.implicitHeight
                  boundsBehavior: Flickable.StopAtBounds
                  clip: true
                  Text {
                    id: pickerNote
                    width: parent.width
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    lineHeight: 1.2
                    text: root.selectedRow ? root.selectedRow.note : ""
                    color: root.foreground
                    opacity: 0.85
                    font.family: Style.font.family
                    font.pixelSize: Style.font.body
                  }
                }
              }

              // Text previews (animations, layouts, shaders) as a code block.
              Flickable {
                id: previewFlick
                anchors.fill: parent
                anchors.margins: Style.space(14)
                visible: !root.category.image && !opacityStage.visible && !barStage.visible && !fxStage.visible && !pickerStage.visible
                contentHeight: previewLabel.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Text {
                  id: previewLabel
                  width: parent.width
                  wrapMode: Text.WrapAnywhere
                  textFormat: Text.PlainText
                  text: root.previewText || (root.selectedRow && root.selectedRow.note) || (root.category.key === "shaders" && root.selectedRow
                    ? "Toggle: on/off (last used shader) / next shader in the list" : "")
                  color: root.foreground
                  opacity: 0.85
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  lineHeight: 1.15
                }
              }
            }

            // Action buttons
            Row {
              id: actions
              anchors.bottom: parent.bottom
              anchors.right: parent.right
              height: root.rowHeight
              spacing: Style.space(8)

              Rectangle {
                visible: root.category.key !== "walls"
                height: parent.height
                width: randomRow.implicitWidth + Style.space(24)
                radius: height / 2
                color: randomHover.containsMouse ? Util.alpha(root.foreground, 0.14) : root.faint
                border.width: 1
                border.color: root.hairline
                Row {
                  id: randomRow
                  anchors.centerIn: parent
                  spacing: Style.space(8)
                  Text { text: "󰒝"; color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.body; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: "Surprise me"; color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.body; anchors.verticalCenter: parent.verticalCenter }
                  Keycap { label: "r"; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { id: randomHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.randomPick() }
              }

              Rectangle {
                height: parent.height
                width: applyRow.implicitWidth + Style.space(28)
                radius: height / 2
                enabled: root.selectedRow !== null
                opacity: enabled ? 1 : 0.4
                color: applyHover.containsMouse ? Qt.lighter(root.accent, 1.12) : root.accent
                Row {
                  id: applyRow
                  anchors.centerIn: parent
                  spacing: Style.space(8)
                  Text { text: "Apply"; color: root.background; font.family: root.fontFamily; font.pixelSize: Style.font.body; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: "⏎"; color: Util.alpha(root.background, 0.7); font.family: root.fontFamily; font.pixelSize: Style.font.body; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                  id: applyHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: if (root.selectedRow) root.run(root.selectedRow.value)
                }
              }
            }
          }
        }

        // ── Key help overlay ("?") ─────────────────────────────────
        Rectangle {
          anchors.fill: parent
          visible: opacity > 0
          opacity: root.helpOpen ? 1 : 0
          Behavior on opacity { NumberAnimation { duration: 140 } }
          color: Util.alpha(root.background, 0.94)
          radius: root.innerRadius

          MouseArea { anchors.fill: parent; enabled: root.helpOpen; onClicked: root.helpOpen = false }

          Column {
            anchors.centerIn: parent
            spacing: Style.space(14)

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "Keys"
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.display
              font.bold: true
            }

            Grid {
              columns: 2
              columnSpacing: Style.space(48)
              rowSpacing: Style.space(10)
              Repeater {
                model: [
                  ["j k  ↑ ↓", "move"], ["h l  ← →", "categories ⇄ list"],
                  ["gg  G", "first / last"], ["^d ^u  ^f ^b", "half / full page"],
                  ["⏎", "apply"], ["r", "random pick (not Recolor)"],
                  ["/", "search, ⏎ keeps, Esc clears"], ["J K", "scroll text preview"],
                  ["1 – 9  0", "jump to category"], ["o  O  ^o", "Recolor: image(s) / folder"],
                  ["h l  − +", "Bar Tweaks: change (hold)"], ["x", "Bar Tweaks: reset to default"],
                  ["⏎", "Bar Tweaks: step · pick color"], ["●", "Bar Tweaks: changed from default"],
                  ["p", "Lock: show design live (Esc closes)"], ["T", "Lock: refresh previews"],
                  ["p", "Wallpaper FX: play · Theme Switcher: open"], ["h l", "FX / Switcher: settings rows"],
                  ["Esc", "back · revert live preview"], ["q", "close"]
                ]
                delegate: Row {
                  required property var modelData
                  spacing: Style.space(12)
                  Keycap { label: modelData[0]; width: Style.space(120) }
                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData[1]
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                  }
                }
              }
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "Press ? or Esc to close"
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }
}
