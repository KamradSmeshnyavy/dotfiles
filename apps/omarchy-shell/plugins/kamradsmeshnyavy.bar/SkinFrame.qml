import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// Подложка бара по форме скина. Растянута на всё окно бара; `body` — видимая
// часть, в неё Bar.qml кладёт секции модулей, `hitArea` — маска ввода.
//
//   full       сток: полоса во всю сторону экрана
//   floating   полоса с отступом от краёв, скругление и рамка из скина
//   pill       floating с радиусом в полвысоты
//   islands    без общей подложки — острова рисует SkinIsland под каждой секцией
//   notch      «чёлка» у края: скруглены только углы, обращённые к экрану
//   underline  фон из скина (обычно прозрачный) + линия по внутреннему краю
//   hug        полоса во всю ширину + вогнутые углы под ней (end-4 «Hug»)
//
// autoHide: бар уезжает за край, в окне остаётся полоска hitArea в пару
// пикселей; наведение на неё (или открытая панель) выдвигает бар обратно.
//
// compact (решает Bar.qml для своего монитора): своя форма, высота и альфа.
// Виджеты остаются прежнего размера и центрируются в более тонкой подложке.
Item {
  id: frame

  required property var skin
  required property int barSize
  required property string position
  // Стоковый режим transparent (двойной клик по центру бара): фон прячем,
  // рамка и линия остаются.
  property bool transparent: false
  // Bar.qml держит true, пока бар под курсором или открыта его панель.
  property bool engaged: false
  property bool compact: false

  readonly property bool vertical: position === "left" || position === "right"

  // ── Действующие значения (обычные или compact) ────────────────────────
  readonly property string shape: compact && skin.compactShape !== "same" ? skin.compactShape : skin.shape
  readonly property int thickness: compact && skin.compactHeight > 0 ? Math.min(skin.compactHeight, barSize) : barSize
  readonly property int gap: skin.gapFor(shape)
  readonly property int margin: skin.marginFor(shape)
  readonly property real widthFraction: skin.widthFor(shape)
  readonly property int hugRadius: skin.hugRadiusFor(shape)
  readonly property color fill: compact && skin.compactAlpha >= 0
    ? skin.withAlpha(skin.backgroundColor, skin.compactAlpha) : skin.backgroundColor
  readonly property color fill2: skin.withAlpha(skin.gradientColor, fill.a)

  readonly property int shadowPad: (skin.shadow || skin.glow) && shape !== "full" && shape !== "hug" ? 10 : 0
  // Толщина окна: обычная геометрия (чтобы compact не менял размер поверхности),
  // а с compactReserve = shrink — по текущей.
  readonly property int normalExtent: barSize + skin.gap + Math.max((skin.shadow || skin.glow) && skin.shape !== "full" && skin.shape !== "hug" ? 10 : 0, skin.hugRadius)
  readonly property int currentExtent: thickness + gap + Math.max(shadowPad, hugRadius)
  readonly property int extent: compact && skin.compactShrink ? currentExtent : Math.max(normalExtent, currentExtent)
  // Сколько места бар резервирует у Hyprland: без тени и углов; авто-скрытие — ничего.
  readonly property int reserved: skin.autoHide ? 0
    : (compact && skin.compactShrink ? thickness + gap : barSize + skin.gap)

  readonly property alias body: bodyItem
  readonly property alias hitArea: hitItem
  readonly property real radius: skin.radiusFor(thickness, shape)

  // Задержка перед уездом, чтобы бар не дёргался на краю.
  property bool revealed: true
  onEngagedChanged: if (engaged) { hideTimer.stop(); revealed = true } else hideTimer.restart()
  Connections {
    target: frame.skin
    function onAutoHideChanged() { frame.revealed = !frame.skin.autoHide || frame.engaged }
  }
  Component.onCompleted: revealed = !skin.autoHide || engaged
  Timer {
    id: hideTimer
    interval: 450
    onTriggered: frame.revealed = !frame.skin.autoHide || frame.engaged
  }
  readonly property bool hidden: skin.autoHide && !revealed
  // Насколько бар уехал за край (0 — на месте).
  property real slide: hidden ? thickness + gap + 2 : 0
  Behavior on slide { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

  Item {
    id: bodyItem

    readonly property real span: frame.vertical ? frame.height - 2 * frame.margin : frame.width - 2 * frame.margin
    readonly property real length: Math.round(span * frame.widthFraction)
    // Расстояние от края экрана до подложки.
    readonly property real inset: frame.gap - frame.slide

    x: frame.vertical
      ? (frame.position === "left" ? inset : frame.width - inset - frame.thickness)
      : Math.round((frame.width - length) / 2)
    y: frame.vertical
      ? Math.round((frame.height - length) / 2)
      : (frame.position === "top" ? inset : frame.height - inset - frame.thickness)
    width: frame.vertical ? frame.thickness : length
    height: frame.vertical ? length : frame.thickness

    Behavior on width { enabled: !frame.vertical; NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on height { enabled: !frame.vertical; NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
  }

  // Маска ввода: сам бар, а у спрятанного — полоска у края экрана.
  Item {
    id: hitItem
    readonly property int strip: 3
    x: !frame.hidden ? bodyItem.x : (frame.vertical && frame.position === "right" ? frame.width - strip : 0)
    y: !frame.hidden ? bodyItem.y : (!frame.vertical && frame.position === "bottom" ? frame.height - strip : 0)
    width: !frame.hidden ? bodyItem.width : (frame.vertical ? strip : frame.width)
    height: !frame.hidden ? bodyItem.height : (frame.vertical ? frame.height : strip)
  }

  readonly property bool drawsPlate: shape !== "islands"
  readonly property bool notch: shape === "notch"

  // Чёлка: прямоугольник уходит за край экрана на радиус, окно его обрезает,
  // и скруглёнными остаются только углы со стороны экрана.
  clip: notch || skin.autoHide

  Rectangle {
    id: plate

    visible: frame.drawsPlate
    x: bodyItem.x
    width: bodyItem.width
    y: frame.notch && frame.position === "top" ? bodyItem.y - frame.radius : bodyItem.y
    height: bodyItem.height + (frame.notch ? frame.radius : 0)
    radius: frame.radius
    color: frame.transparent || frame.shape === "underline" && frame.fill.a === 0 ? "transparent" : frame.fill
    border.width: frame.shape === "underline" || frame.shape === "hug" ? 0 : frame.skin.borderWidth
    border.color: frame.skin.borderColor

    gradient: frame.skin.hasGradient && !frame.transparent ? plateGradient : null

    Gradient {
      id: plateGradient
      orientation: frame.vertical ? Gradient.Vertical : Gradient.Horizontal
      GradientStop { position: 0; color: frame.fill }
      GradientStop { position: 1; color: frame.fill2 }
    }

    layer.enabled: frame.shadowPad > 0 && !frame.transparent
    layer.effect: MultiEffect {
      shadowEnabled: true
      // glow: мягкий ореол цвета рамки вокруг всей подложки, без сдвига.
      shadowColor: frame.skin.glow ? frame.skin.borderColor : "#000000"
      shadowOpacity: frame.skin.glow ? 0.9 : 0.45
      shadowBlur: frame.skin.glow ? 1.0 : 0.6
      shadowVerticalOffset: frame.skin.glow ? 0 : (frame.position === "bottom" ? -2 : 2)
    }

    Behavior on color { ColorAnimation { duration: 280; easing.type: Easing.InOutCubic } }
  }

  // hug: вогнутые углы под полосой у левого и правого края экрана.
  Repeater {
    model: frame.shape === "hug" && !frame.vertical && !frame.transparent ? 2 : 0
    delegate: Shape {
      id: corner
      required property int index
      readonly property int r: frame.hugRadius
      width: r
      height: r
      x: index === 0 ? bodyItem.x : bodyItem.x + bodyItem.width - r
      y: frame.position === "top" ? bodyItem.y + bodyItem.height : bodyItem.y - r
      preferredRendererType: Shape.CurveRenderer
      // Левый верхний угол; остальные — отражения.
      transform: Scale {
        origin.x: corner.r / 2
        origin.y: corner.r / 2
        xScale: corner.index === 0 ? 1 : -1
        yScale: frame.position === "top" ? 1 : -1
      }
      ShapePath {
        fillColor: corner.index === 0 || !frame.skin.hasGradient ? frame.fill : frame.fill2
        strokeWidth: -1
        startX: 0
        startY: 0
        PathLine { x: corner.r; y: 0 }
        PathArc { x: 0; y: corner.r; radiusX: corner.r; radiusY: corner.r; direction: PathArc.Counterclockwise }
        PathLine { x: 0; y: 0 }
      }
    }
  }

  // underline: линия по краю бара, обращённому к рабочему столу.
  Rectangle {
    visible: frame.shape === "underline"
    readonly property int thickness: Math.max(2, frame.skin.borderWidth)
    x: bodyItem.x
    width: bodyItem.width
    height: thickness
    y: frame.position === "bottom" ? bodyItem.y : bodyItem.y + bodyItem.height - thickness
    color: frame.skin.borderColor
  }
}
