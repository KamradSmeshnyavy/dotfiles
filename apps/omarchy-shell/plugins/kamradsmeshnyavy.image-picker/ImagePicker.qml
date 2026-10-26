import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons
import qs.Commons as Commons
import "ImagePickerModel.js" as ImagePickerModel

Item {
  id: root

  // Injected by omarchy-shell; defaults to the session OMARCHY_PATH.
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property string stateHome: Quickshell.env("HOME") + "/.local/state"
  property string imageDirs: Quickshell.env("OMARCHY_IMAGE_SELECTOR_DIRS") || Quickshell.env("OMARCHY_IMAGE_SELECTOR_DIR") || Quickshell.env("OMARCHY_STOCK_BACKGROUNDS_DIR") || (stateHome + "/omarchy/current/theme/backgrounds")
  property string imageRows: ""
  property string loadedImageRows: ""
  property string selectionFile: Quickshell.env("OMARCHY_IMAGE_SELECTOR_SELECTION_FILE") || Quickshell.env("OMARCHY_BACKGROUND_SELECTION_FILE")
  property string selectedImage: Quickshell.env("OMARCHY_IMAGE_SELECTOR_SELECTED")
  property int selectedIndex: 0
  property bool imagesLoaded: false
  property bool opened: false
  property bool showLabels: false
  property bool filterable: false
  property bool layoutSettled: false
  property bool requestActive: false
  property int requestSerial: 0
  property int applySerial: 0
  property string doneFile: ""
  property string filterText: ""
  property var doneFilesToRelease: []
  // Bound to the central [image-picker] section in shell.toml via Commons.Color.qml.
  // `dimColor` tints unselected slices and text outlines on top of the scrim;
  // it intentionally tracks the foundational background, not a surface role.
  property color dimColor: Commons.Color.background
  property color foreground: Commons.Color.imagePicker.text
  property color scrim: Commons.Color.imagePicker.scrim
  property color selectedBorder: Commons.Color.imagePicker.selectedBorder
  property color unselectedBorder: Commons.Color.imagePicker.unselectedBorder
  // picker: вид из ~/.config/omarchy/image-picker.json — стиль-пресет и числа поверх него.
  //   style: slices (сток) | cards | coverflow | strip | wide | polaroid
  property var pickerConfig: ({})
  readonly property var stylePresets: ({
    "slices":    { expandedWidth: 768,  expandedHeight: 475, sliceWidth: 108, sliceHeight: 432, spacing: -30,  skew: 28, radius: 0,  tilt: 0 },
    "cards":     { expandedWidth: 760,  expandedHeight: 470, sliceWidth: 150, sliceHeight: 400, spacing: 14,   skew: 0,  radius: 18, tilt: 0 },
    "coverflow": { expandedWidth: 640,  expandedHeight: 420, sliceWidth: 300, sliceHeight: 380, spacing: -210, skew: 0,  radius: 12, tilt: 55 },
    "strip":     { expandedWidth: 460,  expandedHeight: 290, sliceWidth: 300, sliceHeight: 190, spacing: 16,   skew: 0,  radius: 12, tilt: 0 },
    "wide":      { expandedWidth: 1040, expandedHeight: 585, sliceWidth: 64,  sliceHeight: 520, spacing: -18,  skew: 34, radius: 0,  tilt: 0 },
    "polaroid":  { expandedWidth: 600,  expandedHeight: 470, sliceWidth: 220, sliceHeight: 300, spacing: 18,   skew: 0,  radius: 4,  tilt: 0 }
  })
  readonly property string pickerStyle: stylePresets[pickerConfig.style] ? String(pickerConfig.style) : "slices"
  function pickerNum(key, fallback) {
    var v = Number(pickerConfig[key])
    return pickerConfig[key] !== undefined && pickerConfig[key] !== null && isFinite(v) ? v : fallback
  }
  readonly property var preset: stylePresets[pickerStyle]
  property int expandedWidth: pickerNum("expandedWidth", preset.expandedWidth)
  property int expandedHeight: pickerNum("expandedHeight", preset.expandedHeight)
  property int sliceWidth: pickerNum("sliceWidth", preset.sliceWidth)
  property int sliceHeight: pickerNum("sliceHeight", preset.sliceHeight)
  property int sliceSpacing: pickerNum("spacing", preset.spacing)
  property int skewOffset: pickerNum("skew", preset.skew)
  readonly property real cornerRadius: pickerNum("cardRadius", preset.radius)
  readonly property real tilt: pickerNum("tilt", preset.tilt)
  readonly property real dimUnselected: pickerNum("dim", 0.42)
  readonly property int selectedBorderWidth: pickerNum("selectedBorder", 3)
  readonly property int animMs: pickerNum("animMs", 160)
  readonly property real scrimAlpha: pickerNum("scrimAlpha", -1)
  readonly property bool polaroid: pickerStyle === "polaroid"
  readonly property bool labelsAlways: pickerConfig.labels === true
  readonly property bool labelsShown: showLabels || labelsAlways
  property int bottomChromeHeight: labelsShown ? (filterable ? 104 : 74) : (filterable ? 60 : 30)

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/image-picker.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var v = JSON.parse(text())
        root.pickerConfig = v && typeof v === "object" ? v : ({})
      } catch (e) {
        console.warn("image-picker.json: " + e)
      }
    }
    onLoadFailed: root.pickerConfig = ({})
  }

  onOpenedChanged: if (!opened) layoutSettled = false

  function scriptPath(name) {
    return omarchyPath + "/shell/plugins/image-picker/" + name
  }

  function focusPicker() {
    if (root.opened && root.imagesLoaded && root.layoutSettled)
      carousel.forceActiveFocus()
  }

  function revealWhenSettled(serial) {
    Qt.callLater(function() {
      if (serial === root.requestSerial && root.opened && root.imagesLoaded && root.imageArray.length > 0) {
        root.layoutSettled = true
        root.focusPicker()
      }
    })
  }

  function currentPath() {
    if (imageArray.length === 0 || !itemMatches(selectedIndex)) return ""
    return imageArray[selectedIndex].filePath
  }

  function nameForPath(path) {
    return ImagePickerModel.nameForPath(path)
  }

  function labelForPath(path) {
    return ImagePickerModel.labelForPath(path)
  }

  function currentLabel() {
    var path = currentPath()
    if (!path) return filterText ? "No matches" : ""

    return labelForPath(path)
  }

  function itemMatches(index) {
    return ImagePickerModel.itemMatches(imageArray, index, filterText)
  }

  function firstMatchingIndex() {
    return ImagePickerModel.firstMatchingIndex(imageArray, filterText)
  }

  function filteredPosition(index) {
    return ImagePickerModel.filteredPosition(imageArray, index, filterText)
  }

  function selectedFilteredPosition() {
    return ImagePickerModel.selectedFilteredPosition(imageArray, selectedIndex, filterText)
  }

  function select(index, immediate) {
    if (imageArray.length === 0) return
    if (index < 0) index = 0
    else if (index >= imageArray.length) index = imageArray.length - 1
    if (!itemMatches(index)) return
    if (index === selectedIndex && immediate !== true) return

    selectedIndex = index
  }

  function selectAdjacent(direction) {
    var count = imageArray.length
    if (count === 0) return

    var index = selectedIndex
    for (var i = 0; i < count; i++) {
      index = (index + direction + count) % count
      if (itemMatches(index)) {
        select(index)
        return
      }
    }
  }

  function updateFilter(nextFilterText) {
    filterText = nextFilterText

    if (!itemMatches(selectedIndex)) {
      var first = ImagePickerModel.nextSelectedIndexForFilter(imageArray, selectedIndex, filterText)
      if (first >= 0) selectedIndex = first
    }
  }

  function releaseNextDoneFile() {
    if (releaseProc.running || doneFilesToRelease.length === 0) return

    var path = doneFilesToRelease.shift()
    releaseProc.command = ["bash", "-c", ": > " + Util.shellQuote(path)]
    releaseProc.running = true
  }

  function finishDoneFile(path) {
    if (!path) return
    doneFilesToRelease.push(path)
    releaseNextDoneFile()
  }

  function applySelected() {
    var path = currentPath()
    if (!path || !selectionFile) {
      cancel()
      return
    }

    var activeSelectionFile = selectionFile
    var activeDoneFile = doneFile
    applySerial = requestSerial
    requestActive = false
    selectionFile = ""
    doneFile = ""

    applyProc.command = ["bash", "-c", "printf '%s\\n' " + Util.shellQuote(path) + " > " + Util.shellQuote(activeSelectionFile) + "; : > " + Util.shellQuote(activeDoneFile)]
    applyProc.running = true
  }

  function cancel() {
    if (requestActive)
      finishDoneFile(doneFile)

    requestActive = false
    selectionFile = ""
    doneFile = ""
    root.opened = false
  }

  function closeSelector(nextDoneFile) {
    requestSerial += 1

    if (requestActive)
      finishDoneFile(doneFile)

    if (nextDoneFile && nextDoneFile !== doneFile)
      finishDoneFile(nextDoneFile)

    requestActive = false
    selectionFile = ""
    doneFile = ""
    filterText = ""
    root.opened = false
  }

  function loadRows(rows, reveal) {
    var newImages = ImagePickerModel.loadRows(rows)

    root.loadedImageRows = rows
    root.selectedIndex = root.indexForSelectedImage(newImages)
    root.imageArray = newImages
    root.imagesLoaded = true

    if (reveal !== false) {
      root.opened = true
      root.revealWhenSettled(root.requestSerial)
    }
  }

  function openSelector(nextImageDirs, nextImageRows, nextSelectedImage, nextSelectionFile, nextDoneFile, nextShowLabels, nextFilterable) {
    if (requestActive && doneFile && doneFile !== nextDoneFile)
      finishDoneFile(doneFile)

    requestSerial += 1

    imageDirs = nextImageDirs
    imageRows = nextImageRows
    selectedImage = nextSelectedImage
    selectionFile = nextSelectionFile
    doneFile = nextDoneFile
    requestActive = !!doneFile
    showLabels = nextShowLabels === true || nextShowLabels === "true"
    filterable = nextFilterable === true || nextFilterable === "true"
    filterText = ""
    layoutSettled = false

    if (imageRows && imageRows === loadedImageRows && imageArray.length > 0) {
      root.select(root.selectedImageIndex(), true)
      imagesLoaded = true
      opened = true
      root.revealWhenSettled(requestSerial)
      return
    }

    if (imageRows) {
      var rowsToLoad = imageRows
      var rowsSerial = requestSerial
      imageArray = []
      selectedIndex = 0
      imagesLoaded = true
      opened = true
      Qt.callLater(function() {
        if (rowsSerial === root.requestSerial)
          root.loadRows(rowsToLoad, true)
      })
      return
    }

    imageArray = []
    selectedIndex = 0
    imagesLoaded = false
    opened = false
    startImageScan(requestSerial, imageDirs)
  }

  property var imageArray: []

  function startImageScan(serial, dirs) {
    if (loadImagesProc.running) {
      loadImagesProc.queuedSerial = serial
      loadImagesProc.queuedDirs = dirs
      return
    }

    loadImagesProc.activeSerial = serial
    loadImagesProc.queuedSerial = 0
    loadImagesProc.queuedDirs = ""
    loadImagesProc.command = [root.scriptPath("list.sh"), dirs]
    loadImagesProc.running = true
  }

  function indexForSelectedImage(images) {
    return ImagePickerModel.indexForSelectedImage(images, selectedImage)
  }

  function selectedImageIndex() {
    return indexForSelectedImage(imageArray)
  }

  Process {
    id: loadImagesProc
    property int activeSerial: 0
    property int queuedSerial: 0
    property string queuedDirs: ""
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (loadImagesProc.activeSerial === root.requestSerial)
          root.loadRows(String(text || ""), true)
      }
    }
    onExited: {
      var serial = queuedSerial
      var dirs = queuedDirs
      activeSerial = 0
      queuedSerial = 0
      queuedDirs = ""
      if (serial > 0 && serial === root.requestSerial)
        root.startImageScan(serial, dirs)
    }
  }

  // Lifecycle hooks invoked by omarchy-shell summon/hide. shell.summon(id,
  // payloadJson) hands the JSON to open() here; shell.hide(id) calls close().
  // The shell host owns the stable `image-selector` IPC target and forwards
  // those lower-level positional calls here.
  function open(payload) {
    var args = {}
    if (payload) {
      try { args = JSON.parse(payload) || {} } catch (e) { args = {} }
    }
    var dirs = String(args.imageDirs || imageDirs)
    var rows = String(args.imageRows || "")
    var sel = String(args.selectedImage || selectedImage)
    var selFile = String(args.selectionFile || "")
    var doneF = String(args.doneFile || "")
    var labels = args.showLabels === true || args.showLabels === "true"
    var filter = args.filterable === true || args.filterable === "true"
    openSelector(dirs, rows, sel, selFile, doneF, labels, filter)
  }

  function close() {
    cancel()
  }

  function preloadRows(nextImageRows, nextSelectedImage, nextShowLabels, nextFilterable) {
    // Theme/background set hooks can warm selector rows after a picker was
    // dismissed. Ignore those preloads while a user-visible request is open;
    // otherwise the preload resets layoutSettled without revealing again,
    // leaving only the fullscreen scrim.
    if (opened || requestActive) return

    requestSerial += 1
    imageRows = nextImageRows
    selectedImage = nextSelectedImage
    showLabels = nextShowLabels === true || nextShowLabels === "true"
    filterable = nextFilterable === true || nextFilterable === "true"
    filterText = ""
    layoutSettled = false

    if (imageRows && imageRows === loadedImageRows && imageArray.length > 0) {
      selectedIndex = selectedImageIndex()
      imagesLoaded = true
    } else if (imageRows) {
      loadRows(imageRows, false)
    }
  }

  Process {
    id: applyProc
    onExited: {
      if (root.applySerial === root.requestSerial)
        root.opened = false
    }
  }

  Process {
    id: releaseProc
    onExited: root.releaseNextDoneFile()
  }

  PanelWindow {
    id: panel

    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-image-selector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened && root.imagesLoaded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      visible: root.opened && root.imagesLoaded
      // picker: своя плотность затемнения фона (scrimAlpha), -1 — из темы.
      color: root.scrimAlpha >= 0 ? Util.alpha(root.scrim, root.scrimAlpha) : root.scrim
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.opened && root.imagesLoaded
      onClicked: root.cancel()
    }

    Item {
      id: card
      visible: root.opened && root.imagesLoaded && root.layoutSettled && root.imageArray.length > 0
      width: Math.min(parent.width - 80, root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing) + 40)
      height: root.expandedHeight + Style.space(30) + root.bottomChromeHeight
      anchors.centerIn: parent

        MouseArea { anchors.fill: parent; onClicked: {} }

        Item {
          id: carousel
          anchors.top: parent.top
          anchors.topMargin: Style.space(30)
          anchors.bottom: parent.bottom
          anchors.bottomMargin: root.bottomChromeHeight
          anchors.horizontalCenter: parent.horizontalCenter
          width: root.expandedWidth + 13 * (root.sliceWidth + root.sliceSpacing)
          clip: false
          focus: true

          readonly property real itemStep: root.sliceWidth + root.sliceSpacing
          readonly property real previewX: (width - root.expandedWidth) / 2

          Keys.priority: Keys.BeforeItem
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              if (root.filterText) {
                root.updateFilter("")
              } else {
                root.cancel()
              }
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.applySelected()
              event.accepted = true
            } else if (root.filterable && Util.editsFilter(event, root.filterText)) {
              root.updateFilter(Util.editedFilter(event, root.filterText))
              event.accepted = true
            } else if (event.key === Qt.Key_Left || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier) || event.key === Qt.Key_Backtab) {
              root.selectAdjacent(-1)
              event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
              root.selectAdjacent(1)
              event.accepted = true
            } else if (root.filterable && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127 && (event.modifiers === Qt.NoModifier || event.modifiers === Qt.ShiftModifier)) {
              root.updateFilter(root.filterText + event.text)
              event.accepted = true
            }
          }

          Component.onCompleted: forceActiveFocus()

          Repeater {
            model: root.imageArray.length

            delegate: Item {
              id: item
              required property int index

              readonly property var imageData: root.imageArray[index]
              readonly property string filePath: imageData ? imageData.filePath : ""
              readonly property string fileName: imageData ? imageData.fileName : ""
              readonly property string thumbnailPath: imageData ? imageData.thumbnailPath : ""

              readonly property bool matched: root.itemMatches(index)
              readonly property int relativeIndex: root.filteredPosition(index) - root.selectedFilteredPosition()
              readonly property bool selected: matched && index === root.selectedIndex
              readonly property bool nearby: matched && Math.abs(relativeIndex) <= 16
              property bool sourceActivated: nearby
              onNearbyChanged: if (nearby) sourceActivated = true

              visible: nearby
              x: selected ? carousel.previewX : (relativeIndex < 0 ? carousel.previewX + relativeIndex * carousel.itemStep : carousel.previewX + root.expandedWidth + root.sliceSpacing + (relativeIndex - 1) * carousel.itemStep)
              width: selected ? root.expandedWidth : root.sliceWidth
              height: selected ? root.expandedHeight : root.sliceHeight
              y: selected ? 0 : (root.expandedHeight - root.sliceHeight) / 2
              z: selected ? 100 : 50 - Math.min(Math.abs(relativeIndex), 40)

              // picker: плавное перелистывание и поворот соседей (coverflow).
              Behavior on x { enabled: root.animMs > 0 && root.layoutSettled; NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }
              Behavior on width { enabled: root.animMs > 0 && root.layoutSettled; NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }
              Behavior on height { enabled: root.animMs > 0 && root.layoutSettled; NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }
              Behavior on y { enabled: root.animMs > 0 && root.layoutSettled; NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }
              transform: Rotation {
                origin.x: item.width / 2
                origin.y: item.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: item.selected || root.tilt === 0 ? 0 : (item.relativeIndex < 0 ? root.tilt : -root.tilt)
                Behavior on angle { enabled: root.animMs > 0; NumberAnimation { duration: root.animMs; easing.type: Easing.OutCubic } }
              }
              // picker: polaroid — белая рамка, картинка внутри, подпись снизу.
              readonly property real framePad: root.polaroid ? 10 : 0
              readonly property real captionHeight: root.polaroid ? 34 : 0
              readonly property bool rounded: root.skewOffset === 0
              readonly property real skAbs: Math.abs(root.skewOffset)
              readonly property real topLeft: root.skewOffset >= 0 ? skAbs : 0
              readonly property real topRight: root.skewOffset >= 0 ? width : width - skAbs
              readonly property real bottomRight: root.skewOffset >= 0 ? width - skAbs : width
              readonly property real bottomLeft: root.skewOffset >= 0 ? 0 : skAbs

              Item {
                id: maskShape
                anchors.fill: parent
                visible: false
                layer.enabled: true

                // picker: без скоса — маска-скруглённый прямоугольник.
                Rectangle {
                  visible: item.rounded
                  anchors.fill: parent
                  radius: root.cornerRadius
                  color: "white"
                }

                Shape {
                  visible: !item.rounded
                  anchors.fill: parent
                  antialiasing: true
                  preferredRendererType: Shape.CurveRenderer
                  ShapePath {
                    fillColor: "white"
                    strokeColor: "transparent"
                    startX: item.topLeft; startY: 0
                    PathLine { x: item.topRight; y: 0 }
                    PathLine { x: item.bottomRight; y: item.height }
                    PathLine { x: item.bottomLeft; y: item.height }
                    PathLine { x: item.topLeft; y: 0 }
                  }
                }
              }

              Item {
                anchors.fill: parent
                layer.enabled: true
                layer.smooth: true
                layer.effect: MultiEffect {
                  maskEnabled: true
                  maskSource: maskShape
                  maskThresholdMin: 0.3
                  maskSpreadAtMin: 0.3
                }

                // picker: рамка polaroid под картинкой.
                Rectangle {
                  visible: root.polaroid
                  anchors.fill: parent
                  radius: root.cornerRadius
                  color: "#f4f1ea"
                  Text {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 8; leftMargin: 10; rightMargin: 10 }
                    text: root.labelForPath(item.filePath)
                    color: "#2b2b2b"
                    font.pixelSize: Math.max(10, Style.font.body)
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                  }
                }

                Image {
                  id: image
                  anchors.fill: parent
                  anchors.margins: item.framePad
                  anchors.bottomMargin: item.framePad + item.captionHeight
                  // Load only the initial/visited nearby images, but keep the
                  // source once activated so Qt does not tear textures down as
                  // selection moves through the carousel.
                  source: item.sourceActivated && item.thumbnailPath ? Util.fileUrl(item.thumbnailPath) : ""
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: false
                  cache: true
                  smooth: true
                }

                Rectangle {
                  anchors.fill: parent
                  color: Util.alpha(root.dimColor, item.selected ? 0 : root.dimUnselected)
                }
              }

              // picker: рамка без скоса — скруглённая.
              Rectangle {
                visible: item.rounded
                anchors.fill: parent
                radius: root.cornerRadius
                color: "transparent"
                border.width: item.selected ? root.selectedBorderWidth : 1
                border.color: item.selected ? root.selectedBorder : root.unselectedBorder
              }

              Shape {
                visible: !item.rounded
                anchors.fill: parent
                antialiasing: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                  fillColor: "transparent"
                  strokeColor: item.selected ? root.selectedBorder : root.unselectedBorder
                  strokeWidth: item.selected ? root.selectedBorderWidth : 1
                  startX: item.topLeft; startY: 0
                  PathLine { x: item.topRight; y: 0 }
                  PathLine { x: item.bottomRight; y: item.height }
                  PathLine { x: item.bottomLeft; y: item.height }
                  PathLine { x: item.topLeft; y: 0 }
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: item.selected ? root.applySelected() : root.select(index)
              }
            }
          }
        }

        Text {
          id: selectedLabel
          textFormat: Text.PlainText
          visible: root.labelsShown
          anchors.top: carousel.bottom
          anchors.topMargin: Style.space(16)
          anchors.horizontalCenter: carousel.horizontalCenter
          width: root.expandedWidth
          text: root.currentLabel()
          color: root.foreground
          style: Text.Outline
          styleColor: Util.alpha(root.dimColor, 0.7)
          font.pixelSize: Style.font.display
          font.weight: Font.DemiBold
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          visible: root.filterable && root.filterText
          anchors.top: selectedLabel.bottom
          anchors.topMargin: Style.space(8)
          anchors.horizontalCenter: carousel.horizontalCenter
          width: root.expandedWidth
          text: root.filterText
          color: root.foreground
          opacity: 0.85
          style: Text.Outline
          styleColor: Util.alpha(root.dimColor, 0.7)
          font.pixelSize: Style.font.title
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
        }
    }
  }
}
