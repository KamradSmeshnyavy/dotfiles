import QtQuick
import qs.Commons

// What every skin is handed by the menu, and what it may hand back. Menu.qml
// wires these in one place when the skin's Loader finishes, so a new skin only
// has to extend this and draw.
//
// Optional hooks a skin can define:
//   function navigate(dx, dy)  arrows move spatially instead of by list order
//                              (Left then stops meaning "back"; Backspace still does)
//   property int launchDelay   ms to hold a launch so playLaunch() can show
//   function playLaunch(index) the launch effect for row `index`
Item {
  id: root

  property var rowModel: null
  property var iconResolver: null
  property int selectedIndex: 0
  property bool cursorActive: true
  property string title: ""
  property string subtitle: ""
  property string query: ""
  // A menu change earns the full entrance; a keystroke while filtering only
  // re-settles what is already on screen.
  property bool burst: true
  property real backdrop: 0.94
  property color foreground: theme ? theme.foreground : "#cacccc"
  property color accent: theme ? theme.accent : "#cacccc"
  property color background: theme ? theme.background : "#101315"
  property string fontFamily: Style.font.menuFamily
  readonly property string mono: Style.font.family
  property var theme: null
  // Bumped by the menu whenever the rows are rebuilt, so bindings that read
  // rows through get() notice a new list of the same length.
  property int revision: 0
  // True while the menu is on screen. The view outlives a close (the Loader
  // stays put), so timers and Canvas repaints should run on this, not on
  // being instantiated.
  property bool live: true

  // Launch effect state. A skin that sets launchDelay gets playLaunch() called
  // first and the actual launch that many ms later.
  property int launchDelay: 0
  property bool launching: false
  property int launchIndex: -1

  readonly property int count: root.rowModel ? root.rowModel.count : 0
  // Upstream skins were drawn in fixed pixels for a 1080p screen; this keeps
  // them in step with `omarchy display text size` without letting a large
  // text size push the scene off a short screen.
  readonly property real u: root.height > 0 ? Math.min(Style.space(100) / 100, root.height / 1080) : Style.space(100) / 100

  signal activated(int index)
  signal selectRequested(int index)
  signal dismissRequested()
  signal backRequested()
  // Emitted each time the menu opens, for skins that replay an entrance.
  signal woke()

  function playLaunch(index) {
    root.launchIndex = index
    root.launching = true
  }

  function wake() {
    root.launching = false
    root.launchIndex = -1
    root.woke()
  }

  // The row under the cursor, or a blank one, for headers that name it.
  function rowAt(index) {
    if (!root.rowModel || index < 0 || index >= root.rowModel.count) return null
    return root.rowModel.get(index)
  }

  readonly property var current: {
    root.count
    root.revision
    root.selectedIndex
    return root.rowAt(root.selectedIndex)
  }

  function isBranch(kind) {
    return kind === "menu" || kind === "link"
  }

  function step(delta) {
    if (root.count === 0) return
    root.selectRequested((root.selectedIndex + delta + root.count) % root.count)
  }

  function clampTo(index) {
    if (root.count === 0) return
    root.selectRequested(Math.max(0, Math.min(root.count - 1, index)))
  }

  // Wheel ticks arrive in eighths of a degree; one notch is one step.
  function wheelStep(wheel) {
    var d = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
    if (d !== 0) root.step(d > 0 ? -1 : 1)
  }

  function emptyText() {
    return root.query.length > 0 ? "No matches for “" + root.query + "”" : "Nothing here yet"
  }
}
