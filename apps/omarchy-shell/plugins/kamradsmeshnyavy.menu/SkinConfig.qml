import QtQuick
import Quickshell
import Quickshell.Io

// Which skin the menu draws itself with. Kept in a tiny JSON file rather than
// a QML property so the menu can switch itself from one of its own rows and
// the choice survives a shell restart.
Item {
  id: root

  readonly property string path: Quickshell.env("HOME") + "/.config/omarchy/extensions/menu-skin.json"
  readonly property var known: ["constellation", "terminal", "list"]
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
