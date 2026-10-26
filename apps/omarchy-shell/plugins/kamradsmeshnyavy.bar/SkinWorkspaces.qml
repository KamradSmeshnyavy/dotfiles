import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Замена omarchy.workspaces в kamradsmeshnyavy.bar (подставляет Bar.qml). С
// дефолтами скина выглядит как сток; bar-skin.json добавляет:
//   wsLabelStyle    как подписан workspace (omarchy, numbers, roman, dots, …)
//   wsWindowIcons   иконки окон внутри workspace
//   wsIconStyle     как рисуются иконки окон (color, mono, tinted, glyph, …)
//   wsMaxIcons      сколько иконок на workspace, остальное — «+N»
//   wsDedupe        одно приложение — одна иконка
//   wsShown         сколько workspace всегда видно (занятые до 10 — всегда)
//   wsShowEmpty     показывать пустые из первых wsShown
//   wsActivePill    плашка под активным (цвет — wsActiveColor)
//   wsActiveColor   цвет текущего workspace: роль темы или #hex
// Колесо мыши листает workspace.
BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var skin: bar && bar.skin ? bar.skin : null
  function opt(key, def) {
    var v = skin && skin.raw ? skin.raw[key] : undefined
    return v === undefined || v === null ? def : v
  }

  readonly property string labelStyle: String(opt("wsLabelStyle", "omarchy"))
  readonly property bool windowIcons: opt("wsWindowIcons", false) === true
  readonly property string iconStyle: String(opt("wsIconStyle", "color"))
  readonly property int maxIcons: Math.max(1, Number(opt("wsMaxIcons", 3)))
  readonly property bool dedupe: opt("wsDedupe", true) !== false
  readonly property int shown: Math.max(1, Math.min(10, Number(opt("wsShown", 5))))
  readonly property bool showEmpty: opt("wsShowEmpty", true) !== false
  readonly property bool activePill: opt("wsActivePill", false) === true

  readonly property color fg: bar ? bar.barForeground : Commons.Color.foreground
  readonly property color accent: Commons.Color.accent
  // wsActiveColor: цвет текущего workspace (роль темы или #hex); пусто — как в стиле:
  // omarchy — цвет текста, остальные стили — accent.
  readonly property string activeSpec: String(opt("wsActiveColor", "") || "")
  readonly property bool customActive: activeSpec !== "" && activeSpec !== "default"
  readonly property color activeColor: customActive && skin ? skin.resolve(activeSpec, accent) : accent
  readonly property string font: bar ? bar.fontFamily : Style.font.family
  readonly property int iconSize: Math.round(Style.font.body * 1.25)

  // ── Подписи ──────────────────────────────────────────────────────────
  // Наборы по номеру 1..10. Фигурные стили зависят от состояния, см. label().
  readonly property var sets: ({
    "numbers":          ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
    "circled":          ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩"],
    "circled-filled":   ["❶", "❷", "❸", "❹", "❺", "❻", "❼", "❽", "❾", "❿"],
    "circled-sans":     ["➀", "➁", "➂", "➃", "➄", "➅", "➆", "➇", "➈", "➉"],
    "circled-sans-filled": ["➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒", "➓"],
    "parens":           ["⑴", "⑵", "⑶", "⑷", "⑸", "⑹", "⑺", "⑻", "⑼", "⑽"],
    "fullwidth":        ["１", "２", "３", "４", "５", "６", "７", "８", "９", "０"],
    "superscript":      ["¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "⁰"],
    "roman":            ["Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ"],
    "roman-small":      ["ⅰ", "ⅱ", "ⅲ", "ⅳ", "ⅴ", "ⅵ", "ⅶ", "ⅷ", "ⅸ", "ⅹ"],
    "kanji":            ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"],
    "greek":            ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ"],
    "cyrillic":         ["а", "б", "в", "г", "д", "е", "ж", "з", "и", "к"],
    "braille":          ["⠁", "⠃", "⠉", "⠙", "⠑", "⠋", "⠛", "⠓", "⠊", "⠚"]
  })
  // Фигуры: [активный/занятый, пустой].
  readonly property var shapes: ({
    "dots":      ["●", "○"],
    "squares":   ["■", "□"],
    "diamonds":  ["◆", "◇"],
    "stars":     ["★", "☆"],
    "triangles": ["▲", "△"],
    "hearts":    ["♥", "♡"],
    "hexagons":  ["⬢", "⬡"],
    "bars":      ["━", "─"]
  })

  function label(id, focused, occupied) {
    var i = (id - 1) % 10
    var s = root.labelStyle
    if (s === "none") return ""
    if (root.shapes[s]) {
      var g = root.shapes[s][focused || occupied ? 0 : 1]
      return s === "bars" && focused ? g + g + g : g
    }
    if (root.sets[s]) return root.sets[s][i]
    // omarchy: как в стоке — номер, у активного свой значок.
    return focused ? "󱓻" : (id === 10 ? "0" : String(id))
  }

  // ── Workspace ────────────────────────────────────────────────────────
  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) if (values[i].id === id) return values[i]
    return null
  }

  function workspaceIds() {
    var ids = []
    for (var n = 1; n <= root.shown; n++) ids.push(n)
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }
    if (!root.showEmpty) {
      ids = ids.filter(function(id) {
        var w = root.workspaceById(id)
        var focused = Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === id
        return focused || (w !== null && w.toplevels.values.length > 0)
      })
    }
    ids.sort(function(a, b) { return a - b })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  // ── Окна ─────────────────────────────────────────────────────────────
  function appIdOf(toplevel) {
    if (!toplevel) return ""
    if (toplevel.wayland && toplevel.wayland.appId) return String(toplevel.wayland.appId)
    var ipc = toplevel.lastIpcObject
    return ipc && ipc["class"] ? String(ipc["class"]) : ""
  }

  // Что показать внутри workspace: [{ app, count }], не больше maxIcons + «ещё».
  function windowsOf(workspace) {
    if (!workspace || !root.windowIcons) return []
    var list = workspace.toplevels.values
    var out = []
    var seen = ({})
    for (var i = 0; i < list.length; i++) {
      var app = root.appIdOf(list[i])
      if (root.dedupe && seen[app] !== undefined) { out[seen[app]].count++; continue }
      seen[app] = out.length
      out.push({ app: app, count: 1 })
    }
    return out
  }

  function iconSource(app) {
    if (!app) return Quickshell.iconPath("application-x-executable", true)
    var entry = DesktopEntries.heuristicLookup(app)
    var name = entry && entry.icon ? entry.icon : app
    if (String(name).charAt(0) === "/") return "file://" + name
    var path = Quickshell.iconPath(name, true)
    if (!path) path = Quickshell.iconPath(String(app).toLowerCase(), true)
    return path || Quickshell.iconPath("application-x-executable", true)
  }

  // Nerd Font значки для стиля glyph (по подстроке appId), иначе общий «окно».
  readonly property var glyphs: [
    ["kitty", ""], ["ghostty", ""], ["alacritty", ""], ["foot", ""], ["terminal", ""],
    ["firefox", ""], ["chrom", ""], ["helium", ""], ["brave", ""],
    ["code", "󰨞"], ["neovide", ""], ["nvim", ""],
    ["telegram", ""], ["discord", "󰙯"], ["vesktop", "󰙯"], ["slack", ""],
    ["spotify", ""], ["steam", ""], ["mpv", ""], ["vlc", ""],
    ["nautilus", ""], ["thunar", ""], ["dolphin", ""], ["yazi", ""],
    ["obsidian", ""], ["gimp", ""], ["inkscape", ""], ["libreoffice", ""]
  ]
  function glyphFor(app) {
    var a = String(app || "").toLowerCase()
    for (var i = 0; i < root.glyphs.length; i++) if (a.indexOf(root.glyphs[i][0]) !== -1) return root.glyphs[i][1]
    return ""
  }

  readonly property var superDigits: ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
  function superscript(n) {
    return String(n).split("").map(function(d) { return root.superDigits[Number(d)] }).join("")
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  implicitWidth: (root.vertical ? root.barSize : cells.implicitWidth + trailingGap)
  implicitHeight: root.vertical ? cells.implicitHeight : root.barSize

  WheelHandler {
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: function(event) {
      if (!root.bar) return
      var dir = event.angleDelta.y > 0 ? "-1" : "+1"
      root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"e" + dir + "\" })"))
    }
  }

  Grid {
    id: cells
    anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
    anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
    columns: root.vertical ? 1 : Math.max(1, ids.count)
    columnSpacing: Style.space(1)
    rowSpacing: Style.space(2)

    Repeater {
      id: ids
      model: root.workspaceIds()

      delegate: Item {
        id: cell
        required property int modelData
        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
        readonly property var windows: root.windowsOf(workspace)
        readonly property var visibleWindows: windows.slice(0, root.maxIcons)
        readonly property int extra: windows.length - visibleWindows.length
        readonly property string text: root.label(modelData, focused, occupied)
        readonly property bool shaped: root.shapes[root.labelStyle] !== undefined
        readonly property bool plainStock: root.labelStyle === "omarchy"

        implicitWidth: root.vertical ? root.barSize
          : (visibleWindows.length === 0 && root.labelStyle !== "none" ? Style.space(20) : content.implicitWidth + Style.space(12))
        implicitHeight: root.vertical ? content.implicitHeight + Style.space(10) : root.barSize
        width: implicitWidth
        height: implicitHeight
        opacity: occupied || focused ? 1 : 0.5

        Rectangle {
          visible: root.activePill && cell.focused
          anchors.centerIn: parent
          width: root.vertical ? parent.width - Style.space(6) : parent.width - Style.space(2)
          height: root.vertical ? parent.height - Style.space(2) : parent.height - Style.space(8)
          radius: Math.min(width, height) / 2
          color: Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.22)
          border.width: 1
          border.color: Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.6)
        }

        Rectangle {
          visible: hover.hovered && !(root.activePill && cell.focused)
          anchors.centerIn: parent
          width: root.vertical ? parent.width - Style.space(6) : parent.width - Style.space(2)
          height: root.vertical ? parent.height - Style.space(2) : parent.height - Style.space(8)
          radius: Math.min(width, height) / 2
          color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.08)
        }

        Grid {
          id: content
          anchors.centerIn: parent
          columns: root.vertical ? 1 : 2 + cell.visibleWindows.length
          columnSpacing: Style.space(4)
          rowSpacing: Style.space(3)
          horizontalItemAlignment: Grid.AlignHCenter
          verticalItemAlignment: Grid.AlignVCenter

          Text {
            visible: cell.text !== ""
            text: cell.text
            color: cell.focused && (root.customActive || !cell.plainStock) ? root.activeColor : root.fg
            font.family: root.font
            font.pixelSize: cell.shaped ? Math.round(Style.font.body * 0.9) : Style.font.body
            font.bold: cell.focused && !cell.plainStock && !cell.shaped
          }

          Repeater {
            model: cell.visibleWindows
            delegate: Item {
              id: win
              required property var modelData
              readonly property string style: root.iconStyle
              readonly property bool textual: style === "glyph" || style === "letter" || style === "dots" || style === "count"
              width: textual ? glyph.implicitWidth : root.iconSize
              height: root.iconSize

              // bubble: иконка в кружке.
              Rectangle {
                visible: win.style === "bubble"
                anchors.centerIn: parent
                width: root.iconSize + Style.space(4)
                height: width
                radius: width / 2
                color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.14)
              }

              Image {
                id: icon
                visible: !win.textual
                anchors.centerIn: parent
                width: win.style === "bubble" ? root.iconSize - Style.space(2) : root.iconSize
                height: width
                sourceSize.width: width * 2
                sourceSize.height: height * 2
                // Синхронно: асинхронные темированные иконки в двух видах роняли шелл.
                asynchronous: false
                source: win.textual ? "" : root.iconSource(win.modelData.app)
                opacity: win.style === "faded" && !cell.focused ? 0.45 : 1
                layer.enabled: win.style === "mono" || win.style === "tinted" || win.style === "accent"
                layer.effect: MultiEffect {
                  saturation: win.style === "mono" ? -1 : 0
                  colorization: win.style === "tinted" || win.style === "accent" ? 1 : 0
                  colorizationColor: win.style === "accent" ? root.accent : root.fg
                }
              }

              Text {
                id: glyph
                visible: win.textual
                anchors.centerIn: parent
                color: root.fg
                font.family: root.font
                font.pixelSize: win.style === "dots" ? Math.round(Style.font.body * 0.8) : Style.font.body
                text: win.style === "glyph" ? root.glyphFor(win.modelData.app)
                  : win.style === "letter" ? String(win.modelData.app || "?").replace(/^.*\./, "").charAt(0).toUpperCase()
                  : win.style === "dots" ? Array(win.modelData.count + 1).join("•")
                  : root.superscript(win.modelData.count)
              }
            }
          }

          Text {
            visible: cell.extra > 0
            text: "+" + cell.extra
            color: root.fg
            opacity: 0.7
            font.family: root.font
            font.pixelSize: Style.font.caption
          }
        }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: root.focusWorkspace(cell.modelData) }
      }
    }
  }
}
