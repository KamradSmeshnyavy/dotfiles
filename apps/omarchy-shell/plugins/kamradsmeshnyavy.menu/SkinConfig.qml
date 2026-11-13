import QtQuick
import Quickshell
import Quickshell.Io

// Which skin the menu draws itself with. Kept in a tiny JSON file rather than
// a QML property so the menu can switch itself from one of its own rows and
// the choice survives a shell restart.
Item {
  id: root

  readonly property string path: Quickshell.env("HOME") + "/.config/omarchy/extensions/menu-skin.json"
  // Skin name → the view that draws it. "list" has no view: it is the stock
  // card. The ported ones come from hamzaabde-langjk/omlauch and
  // bjarneo/omarchy-quickapps, recoloured from the active theme.
  readonly property var files: ({
    "constellation": "ConstellationView.qml",
    "terminal": "TerminalView.qml",
    "forge": "ForgeView.qml",
    "aurora": "AuroraView.qml",
    "arcade": "ArcadeView.qml",
    "stark": "StarkView.qml",
    "redroom": "RedRoomView.qml",
    "lofi": "LofiView.qml",
    "board": "BoardView.qml",
    "candy": "CandyView.qml",
    "outrun": "OutrunView.qml",
    "hexgrid": "HexgridView.qml",
    "coffee": "CoffeeView.qml",
    "zen": "ZenView.qml",
    "vaporwave": "VaporwaveView.qml",
    "tron": "TronView.qml",
    "stargate": "StargateView.qml",
    "medieval": "MedievalView.qml",
    "ironman": "IronmanView.qml",
    // Originals.
    "dotmatrix": "DotMatrixView.qml",
    // Из glyph-rice (GPL-3.0): панель по центру, сетка кругов, точечные иконки.
    "glyph": "GlyphView.qml",
    // По мотивам Vitreus (MIT, код свой): стеклянная карточка, строки с описанием.
    "liquid": "LiquidView.qml",
    "drum": "DrumView.qml",
    "tarot": "TarotView.qml",
    "metro": "MetroView.qml",
    "orrery": "OrreryView.qml",
    "matrix": "MatrixView.qml",
    "bookshelf": "BookshelfView.qml",
    "lanterns": "LanternsView.qml",
    "aquarium": "AquariumView.qml",
    "sketchbook": "SketchbookView.qml",
    // Шторка DOT-MATRIX в отделке стилей Customizer: один файл, вариант — после «drawer-».
    "drawer-flat": "DrawerView.qml",
    "drawer-glass": "DrawerView.qml",
    "drawer-fluent": "DrawerView.qml",
    "drawer-paper": "DrawerView.qml",
    "drawer-neumorph": "DrawerView.qml",
    "drawer-brutal": "DrawerView.qml",
    "drawer-retro": "DrawerView.qml",
    "drawer-neon": "DrawerView.qml",
    // Minimal terminal-style twins: same file, drawn with variant "hack".
    "drum-hack": "DrumView.qml",
    "tarot-hack": "TarotView.qml",
    "metro-hack": "MetroView.qml",
    "orrery-hack": "OrreryView.qml",
    "matrix-hack": "MatrixView.qml",
    "bookshelf-hack": "BookshelfView.qml",
    "lanterns-hack": "LanternsView.qml",
    "aquarium-hack": "AquariumView.qml",
    // Same skin, recoloured with the Terminal palette: variant "term".
    "matrix-term": "MatrixView.qml"
  })

  function variantFor(name) {
    var n = String(name || "")
    if (/-hack$/.test(n)) return "hack"
    if (/-term$/.test(n)) return "term"
    // drawer-<стиль>: шторка DOT-MATRIX в отделке стиля Customizer (DrawerView.qml).
    if (/^drawer-/.test(n)) return n.slice(7)
    return ""
  }
  readonly property var known: Object.keys(root.files).concat(["list"])

  function fileFor(name) {
    return root.files[name] || root.files["constellation"]
  }
  property string skin: "constellation"
  // How opaque the backdrop behind a skin is. Left tunable because how much
  // desktop should show through is taste, not a value worth guessing.
  property real backdrop: 0.94

  function apply(raw) {
    var value = "constellation"
    try {
      var parsed = JSON.parse(String(raw || "{}"))
      if (parsed && typeof parsed.skin === "string") value = parsed.skin.trim()
    } catch (e) {
      value = "constellation"
    }
    root.skin = root.known.indexOf(value) >= 0 ? value : "constellation"

    var backdrop = 0.94
    try {
      var config = JSON.parse(String(raw || "{}"))
      if (config && typeof config.backdrop === "number") backdrop = config.backdrop
    } catch (e) {
      backdrop = 0.94
    }
    root.backdrop = Math.max(0.2, Math.min(1, backdrop))
  }

  FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    onLoaded: root.apply(text())
    onFileChanged: reload()
    onLoadFailed: root.skin = "constellation"
  }
}
