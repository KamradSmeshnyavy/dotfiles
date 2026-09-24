import QtQuick
import Quickshell
import qs.Commons

// Desktop entries read straight from Quickshell. The host hands cloned plugins
// a scoped shell whose appLibrary is null, so the menu cannot rely on it for
// the Apps list.
Item {
  id: root

  signal appsChanged()

  function entries() {
    var values = []
    try { values = DesktopEntries.applications.values || [] } catch (e) { values = [] }

    var out = []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      if (!entry || entry.noDisplay === true) continue
      out.push(entry)
    }

    out.sort(function(a, b) {
      var an = String(a.name || "").toLowerCase()
      var bn = String(b.name || "").toLowerCase()
      if (an < bn) return -1
      if (an > bn) return 1
      return 0
    })
    return out
  }

  function iconFor(icon) {
    var value = String(icon || "")
    if (value.length === 0) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    var themed = Quickshell.iconPath(value, true)
    if (themed.length > 0) return themed
    return Quickshell.iconPath("application-x-executable", true)
  }

  // Keeping the .desktop suffix matters: ids like org.telegram.desktop don't
  // resolve without it.
  function launch(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    Util.execDetached("uwsm-app -- gtk-launch " + Util.shellQuote(id + ".desktop"))
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { root.appsChanged() }
  }
}
