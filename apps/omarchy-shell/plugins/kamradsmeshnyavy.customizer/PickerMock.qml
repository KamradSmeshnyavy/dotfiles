import QtQuick
import qs.Commons

// Макет карусели theme switcher для превью Customizer: те же пресеты, что в
// kamradsmeshnyavy.image-picker (держать в согласии), в масштабе превью.
// Скос — сдвиговой матрицей, coverflow — поворотом соседей по Y.
Item {
  id: mock

  property string style: "slices"
  property var config: ({})
  property var images: []          // пути превью тем; выбранная — посередине

  readonly property var presets: ({
    "slices":    { expandedWidth: 768,  expandedHeight: 475, sliceWidth: 108, sliceHeight: 432, spacing: -30,  skew: 28, radius: 0,  tilt: 0 },
    "cards":     { expandedWidth: 760,  expandedHeight: 470, sliceWidth: 150, sliceHeight: 400, spacing: 14,   skew: 0,  radius: 18, tilt: 0 },
    "coverflow": { expandedWidth: 640,  expandedHeight: 420, sliceWidth: 300, sliceHeight: 380, spacing: -210, skew: 0,  radius: 12, tilt: 55 },
    "strip":     { expandedWidth: 460,  expandedHeight: 290, sliceWidth: 300, sliceHeight: 190, spacing: 16,   skew: 0,  radius: 12, tilt: 0 },
    "wide":      { expandedWidth: 1040, expandedHeight: 585, sliceWidth: 64,  sliceHeight: 520, spacing: -18,  skew: 34, radius: 0,  tilt: 0 },
    "polaroid":  { expandedWidth: 600,  expandedHeight: 470, sliceWidth: 220, sliceHeight: 300, spacing: 18,   skew: 0,  radius: 4,  tilt: 0 }
  })
  readonly property var preset: presets[style] || presets.slices
  function num(key, fallback) {
    var v = Number(config ? config[key] : undefined)
    return config && config[key] !== undefined && config[key] !== null && isFinite(v) ? v : fallback
  }
  readonly property real ew: num("expandedWidth", preset.expandedWidth)
  readonly property real eh: num("expandedHeight", preset.expandedHeight)
  readonly property real sw: num("sliceWidth", preset.sliceWidth)
  readonly property real sh: num("sliceHeight", preset.sliceHeight)
  readonly property real gap: num("spacing", preset.spacing)
  readonly property real skew: num("skew", preset.skew)
  readonly property real radius: num("cardRadius", preset.radius)
  readonly property real dim: num("dim", 0.42)
  readonly property bool polaroid: style === "polaroid"

  readonly property int count: Math.max(1, images.length)
  readonly property int center: Math.floor(count / 2)
  // Полная ширина карусели в «настоящих» пикселях → масштаб под превью.
  readonly property real fullWidth: ew + (count - 1) * (sw + gap)
  readonly property real k: Math.min(width / Math.max(1, fullWidth), height / Math.max(1, eh)) * 0.95

  Item {
    width: mock.fullWidth * mock.k
    height: mock.eh * mock.k
    anchors.centerIn: parent

    Repeater {
      model: mock.images
      delegate: Item {
        id: card
        required property int index
        required property string modelData
        readonly property int rel: index - mock.center
        readonly property bool selected: rel === 0
        readonly property real step: (mock.sw + mock.gap) * mock.k
        readonly property real previewX: mock.center * step
        x: selected ? previewX : (rel < 0 ? previewX + rel * step : previewX + (mock.ew + mock.gap) * mock.k + (rel - 1) * step)
        width: (selected ? mock.ew : mock.sw) * mock.k
        height: (selected ? mock.eh : mock.sh) * mock.k
        y: (mock.eh * mock.k - height) / 2
        z: selected ? 100 : 50 - Math.abs(rel)

        transform: [
          Matrix4x4 {
            // Скос как у ломтиков: верх сдвинут вправо на skew.
            readonly property real s: -mock.skew * mock.k / Math.max(1, card.height)
            matrix: Qt.matrix4x4(1, s, 0, -s * card.height, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
          },
          Rotation {
            origin.x: card.width / 2
            origin.y: card.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: card.selected ? 0 : (card.rel < 0 ? mock.preset.tilt : -mock.preset.tilt)
          }
        ]

        Rectangle {
          anchors.fill: parent
          radius: mock.radius * mock.k
          color: mock.polaroid ? "#f4f1ea" : "transparent"
          clip: true

          Image {
            anchors.fill: parent
            anchors.margins: mock.polaroid ? 10 * mock.k : 0
            anchors.bottomMargin: mock.polaroid ? 34 * mock.k : 0
            source: card.modelData ? "file://" + card.modelData : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 400
            asynchronous: true
          }
          Rectangle {
            anchors.fill: parent
            color: Color.background
            opacity: card.selected ? 0 : mock.dim
          }
        }
        Rectangle {
          anchors.fill: parent
          radius: mock.radius * mock.k
          color: "transparent"
          border.width: card.selected ? 2 : 1
          border.color: card.selected ? Color.accent : Qt.rgba(1, 1, 1, 0.2)
        }
      }
    }
  }
}
