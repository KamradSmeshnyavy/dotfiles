import QtQuick
import qs.Commons
import qs.Ui

// What every skin is handed by the menu, and what it may hand back. Menu.qml
// wires these in one place when the skin's Loader finishes, so a new skin only
// has to extend this and draw.
//
// Optional hooks a skin can define:
//   function navigate(dx, dy)  arrows move spatially instead of by list order
//                              (Left then stops meaning "back"; Backspace still does)
//   property int launchDelay   ms to hold a launch so playLaunch() can show
//   function playLaunch(index) the launch effect for row `index`
//   pageSize: N                rows on screen at once; the menu then pages with
//                              Ctrl+H/L, PgUp/PgDn (and ←→ when radial)
//   radial: true               rows sit on a ring: ↑↓ and Ctrl+J/K go round the
//                              ring of the current page instead of off its end
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
  // "" for the skin as designed, "hack" for its minimal terminal-style
  // twin (the *-hack skin names). Same layout and motion, mono drawing.
  property string variant: ""
  readonly property bool hack: root.variant === "hack"
  // Same palette as the Terminal skin: the theme accent for whatever is lit
  // or selected, the theme text colour for text, that at 55% for the rest.
  readonly property color hackInk: root.accent
  readonly property color hackText: root.foreground
  readonly property color hackDim: Util.alpha(root.foreground, 0.55)
  readonly property color hackLine: Util.alpha(root.foreground, 0.18)
  readonly property color hackBg: root.background
  // Text laid on an accent fill: themes ship both light and dark accents.
  readonly property color hackInverse: (0.299 * root.accent.r + 0.587 * root.accent.g + 0.114 * root.accent.b) > 0.5 ? root.background : root.foreground
  // A stable fake number for row i, so hex ids and pids don't flicker.
  function fakeHex(i, digits) {
    var x = Math.sin(i * 78.233 + 12.9898) * 43758.5453
    var n = Math.floor((x - Math.floor(x)) * Math.pow(16, digits))
    return n.toString(16).padStart(digits, "0")
  }
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

  // Paging. Skins that show a fixed number of rows set pageSize; the page is
  // always the one holding the selection, so the cursor never strays off it.
  property int pageSize: 0
  property bool radial: false
  readonly property int page: root.pageSize > 0 ? Math.floor(Math.max(0, root.selectedIndex) / root.pageSize) : 0
  readonly property int pages: root.pageSize > 0 ? Math.max(1, Math.ceil(root.count / root.pageSize)) : 1
  readonly property int pageStart: root.page * root.pageSize
  readonly property int pageCount: root.pageSize > 0 ? Math.max(0, Math.min(root.pageSize, root.count - root.pageStart)) : root.count
  // Radial skins add this to their ring angle: a page change turns the ring
  // in from the side it was paged towards.
  property real ringPhase: 0
  property int pendingDirection: 0
  property int lastPage: 0
  onPageChanged: {
    // A wrap from the last page to the first still turns forwards.
    var dir = root.pendingDirection !== 0 ? root.pendingDirection : (root.page > root.lastPage ? 1 : -1)
    root.pendingDirection = 0
    root.lastPage = root.page
    ringSettle.from = 0.7 * dir
    ringSettle.restart()
  }
  NumberAnimation { id: ringSettle; target: root; property: "ringPhase"; to: 0; duration: 380; easing.type: Easing.OutCubic }
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

  // Round the ring of the current page: off either end wraps to the other.
  function ringStep(delta) {
    if (root.count === 0) return
    if (root.pageSize <= 0) { root.step(delta); return }
    var slot = root.selectedIndex - root.pageStart
    var n = Math.max(1, root.pageCount)
    root.selectRequested(root.pageStart + ((slot + delta) % n + n) % n)
  }

  // To the neighbouring page, keeping the slot (clamped to a shorter last
  // page). Wraps from the last page to the first and back.
  function pageStep(delta) {
    if (root.count === 0 || root.pageSize <= 0 || root.pages <= 1) return false
    var slot = root.selectedIndex - root.pageStart
    var target = ((root.page + delta) % root.pages + root.pages) % root.pages
    var start = target * root.pageSize
    var size = Math.min(root.pageSize, root.count - start)
    root.pendingDirection = delta > 0 ? 1 : -1
    root.selectRequested(start + Math.min(slot, size - 1))
    return true
  }

  // Hover selection. Rows slide under a still pointer whenever the keyboard
  // moves the cursor, and Qt reports that as the pointer entering them; a
  // fast double step then got pulled back by the row it slid onto. So a
  // hover only selects once the pointer has really moved since the last
  // selection made any other way. Row MouseAreas call this from both
  // onEntered and onPositionChanged with mapToItem(root, mouseX, mouseY).
  property bool pointerSelecting: false
  PointerMoveGate { id: pointerGate; referenceItem: root }
  onSelectedIndexChanged: if (!root.pointerSelecting) pointerGate.reset()
  onRevisionChanged: pointerGate.reset()
  onWoke: pointerGate.reset()

  function hoverSelect(index, point) {
    if (!pointerGate.moved(root, point)) return
    root.pointerSelecting = true
    root.selectRequested(index)
    root.pointerSelecting = false
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
