import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.Commons

// Макет бара для превью Customizer: форма, цвета и раскладка рисуются по тем же
// правилам, что и в kamradsmeshnyavy.bar (BarSkin.qml / SkinFrame.qml), только
// виджеты — значки-заглушки. Ширина макета = ширина превью, а не экрана, так
// что поля и доли ширины масштабируются по `scaleX`.
Item {
  id: mock

  property var skin: ({})          // содержимое bar-skin.json
  property var bar: ({})           // shell.json .bar или пресет раскладки
  property var palette: ({})       // colors.toml темы: имя -> #hex
  property string fontFamily: Style.font.family
  property real screenWidth: 1440

  readonly property real scaleX: width / Math.max(1, screenWidth)

  function val(key, def) {
    var v = skin ? skin[key] : undefined
    return v === undefined || v === null ? def : v
  }
  function num(key, def) {
    var n = Number(val(key, def))
    return isFinite(n) ? n : def
  }
  function col(spec, fallback) {
    var s = String(spec === undefined || spec === null ? "" : spec)
    if (s === "" || s === "bar") return fallback
    if (s.charAt(0) === "#") return s
    if (s === "background") return Color.background
    if (s === "foreground") return Color.foreground
    if (s === "accent") return Color.accent
    if (s === "muted") return Color.muted
    if (s === "urgent") return Color.urgent
    return palette && palette[s] ? palette[s] : fallback
  }
  function alpha(c, a) {
    var q = Qt.color(c)
    return Qt.rgba(q.r, q.g, q.b, Math.max(0, Math.min(1, a)))
  }

  readonly property string position: bar && bar.position ? String(bar.position) : "top"
  readonly property bool vertical: position === "left" || position === "right"
  readonly property bool transparent: bar && bar.transparent === true
  readonly property string shape: {
    var s = String(val("shape", "full"))
    if (["full", "floating", "pill", "islands", "notch", "underline", "hug"].indexOf(s) === -1) s = "full"
    if (vertical && s === "hug") return "full"
    return vertical && s !== "full" ? "floating" : s
  }
  readonly property int barSize: num("height", 0) > 0 ? num("height", 0) : (vertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal)
  readonly property int gap: shape === "full" || shape === "underline" || shape === "notch" || shape === "hug" ? 0 : num("gap", 0)
  readonly property real margin: shape === "full" || shape === "underline" || shape === "hug" ? 0 : num("margin", 0) * scaleX
  readonly property real widthFraction: shape === "pill" || shape === "notch" || shape === "floating"
    ? Math.max(0.2, Math.min(1, num("width", 1))) : 1
  readonly property real radius: shape === "pill" ? barSize / 2 : shape === "hug" ? 0 : Math.max(0, Math.min(num("radius", 0), barSize / 2))
  readonly property int hugRadius: shape === "hug" ? Math.max(8, num("radius", 0)) : 0
  readonly property string moduleStyle: String(val("moduleStyle", "plain"))
  readonly property color moduleColor: alpha(col(val("moduleBackground", "foreground"), Color.foreground), num("moduleAlpha", 0.08))
  readonly property bool glow: val("glow", false) === true && shape !== "full" && shape !== "hug"
  readonly property real padding: num("padding", -1) >= 0 ? num("padding", -1) : Style.space(8)

  readonly property color textColor: col(val("text", "bar"), Color.bar.text)
  readonly property color activeColor: col(val("active", "bar"), Color.bar.active)
  readonly property color fill: {
    var c = col(val("background", "bar"), Color.bar.background)
    var a = num("backgroundAlpha", -1)
    return a < 0 ? Qt.color(c) : alpha(c, a)
  }
  readonly property bool hasGradient: String(val("gradient", "")) !== ""
  readonly property color fill2: alpha(col(val("gradient", ""), fill), fill.a)
  readonly property color borderColor: alpha(col(val("border", "accent"), Color.accent), num("borderAlpha", 1))
  readonly property int borderWidth: num("borderWidth", 0)
  readonly property bool shadow: val("shadow", false) === true && shape !== "full" && shape !== "hug"
  readonly property string barFont: String(val("font", "")) || fontFamily

  function entries(section) {
    var l = bar && bar.layout ? bar.layout[section] : null
    return Array.isArray(l) ? l : []
  }

  // Workspaces в стиле скина (те же наборы, что в SkinWorkspaces.qml), 1–2 заняты, 1 активен.
  readonly property var wsSets: ({
    "numbers": "1234567890", "circled": "①②③④⑤", "circled-filled": "❶❷❸❹❺", "circled-sans": "➀➁➂➃➄",
    "circled-sans-filled": "➊➋➌➍➎", "parens": "⑴⑵⑶⑷⑸", "fullwidth": "１２３４５", "superscript": "¹²³⁴⁵",
    "roman": "ⅠⅡⅢⅣⅤ", "roman-small": "ⅰⅱⅲⅳⅴ", "kanji": "一二三四五", "greek": "αβγδε", "cyrillic": "абвгд",
    "braille": "⠁⠃⠉⠙⠑"
  })
  readonly property var wsShapes: ({
    "dots": "●○", "squares": "■□", "diamonds": "◆◇", "stars": "★☆", "triangles": "▲△",
    "hearts": "♥♡", "hexagons": "⬢⬡", "bars": "━─"
  })
  function workspacesText() {
    var style = String(val("wsLabelStyle", "omarchy"))
    var icons = val("wsWindowIcons", false) === true
    var iconStyle = String(val("wsIconStyle", "color"))
    var icon = iconStyle === "glyph" ? "\uF120" : iconStyle === "letter" ? "K" : iconStyle === "dots" ? "•"
      : iconStyle === "count" ? "¹" : "▣"
    var showEmpty = val("wsShowEmpty", true) !== false
    var n = Math.max(1, Math.min(10, Number(val("wsShown", 5))))
    var out = []
    for (var i = 1; i <= n; i++) {
      var occupied = i <= 2
      if (!showEmpty && !occupied) continue
      var label = style === "none" ? ""
        : wsShapes[style] ? (style === "bars" && i === 1 ? "━━━" : wsShapes[style].charAt(occupied ? 0 : 1))
        : wsSets[style] ? Array.from(wsSets[style])[(i - 1) % Array.from(wsSets[style]).length]
        : (i === 1 ? "\uDB85\uDCFB" : String(i % 10))
      out.push(label + (icons && occupied ? " " + icon : ""))
    }
    return out.join("  ")
  }

  // Значок-заглушка для виджета.
  function glyph(id) {
    var short = String(id || "").replace(/^[a-z]+\./, "")
    if (short === "workspaces") return mock.workspacesText()
    var map = {
      "menu": "󰣇", "workspaces": "1 2 3 4 5", "clock": "12:34", "tray": "󰅁", "indicators": "󰂚",
      "system-update": "󰚰", "agents": "󰚩", "network": "󰖩", "bluetooth": "󰂯", "audio": "󰕾",
      "power": "󰁹", "tailscale": "󰖂", "media": "󰎆 Song", "weather": "󰖐 12°", "active-window": "kitty",
      "keyboard-layout": "EN", "microphone": "󰍬", "monitor": "󰃠", "spacer": " ", "dropbox": "󰇣"
    }
    return map[short] !== undefined ? map[short] : "•"
  }

  // ── Подложка ───────────────────────────────────────────────────────
  Item {
    id: body
    readonly property real span: mock.vertical ? mock.height - 2 * mock.margin : mock.width - 2 * mock.margin
    readonly property real length: Math.round(span * mock.widthFraction)
    x: mock.vertical ? (mock.position === "left" ? mock.gap : mock.width - mock.gap - mock.barSize) : Math.round((mock.width - length) / 2)
    y: mock.vertical ? Math.round((mock.height - length) / 2) : (mock.position === "top" ? mock.gap : mock.height - mock.gap - mock.barSize)
    width: mock.vertical ? mock.barSize : length
    height: mock.vertical ? length : mock.barSize
  }

  Item {
    anchors.fill: parent
    clip: mock.shape === "notch"

    Rectangle {
      id: plate
      visible: mock.shape !== "islands"
      x: body.x
      width: body.width
      y: mock.shape === "notch" && mock.position === "top" ? body.y - mock.radius : body.y
      height: body.height + (mock.shape === "notch" ? mock.radius : 0)
      radius: mock.radius
      color: mock.transparent || mock.shape === "underline" && mock.fill.a === 0 ? "transparent" : mock.fill
      border.width: mock.shape === "underline" || mock.shape === "hug" ? 0 : mock.borderWidth
      border.color: mock.borderColor
      gradient: mock.hasGradient && !mock.transparent ? plateGradient : null
      Gradient {
        id: plateGradient
        orientation: mock.vertical ? Gradient.Vertical : Gradient.Horizontal
        GradientStop { position: 0; color: mock.fill }
        GradientStop { position: 1; color: mock.fill2 }
      }
      layer.enabled: (mock.shadow || mock.glow) && !mock.transparent
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: mock.glow ? mock.borderColor : "#000000"
        shadowOpacity: mock.glow ? 0.9 : 0.45
        shadowBlur: mock.glow ? 1.0 : 0.6
        shadowVerticalOffset: mock.glow ? 0 : 2
      }
    }

    // hug: вогнутые углы под полосой.
    Repeater {
      model: mock.shape === "hug" && !mock.transparent ? 2 : 0
      delegate: Shape {
        id: corner
        required property int index
        readonly property int r: mock.hugRadius
        width: r
        height: r
        x: index === 0 ? body.x : body.x + body.width - r
        y: mock.position === "top" ? body.y + body.height : body.y - r
        preferredRendererType: Shape.CurveRenderer
        // Левый верхний угол; остальные — отражения.
        transform: Scale {
          origin.x: corner.r / 2
          origin.y: corner.r / 2
          xScale: corner.index === 0 ? 1 : -1
          yScale: mock.position === "top" ? 1 : -1
        }
        ShapePath {
          fillColor: corner.index === 0 || !mock.hasGradient ? mock.fill : mock.fill2
          strokeWidth: -1
          startX: 0
          startY: 0
          PathLine { x: corner.r; y: 0 }
          PathArc { x: 0; y: corner.r; radiusX: corner.r; radiusY: corner.r; direction: PathArc.Counterclockwise }
          PathLine { x: 0; y: 0 }
        }
      }
    }

    Rectangle {
      visible: mock.shape === "underline"
      readonly property int thickness: Math.max(2, mock.borderWidth)
      x: body.x
      width: body.width
      height: thickness
      y: mock.position === "bottom" ? body.y : body.y + body.height - thickness
      color: mock.borderColor
    }
  }

  // ── Секции ─────────────────────────────────────────────────────────
  // Без inline-компонентов: они не видят id этого файла.
  Item {
    id: sections
    x: body.x
    y: body.y
    width: body.width
    height: body.height
    clip: true

    Repeater {
      model: ["left", "center", "right"]
      delegate: Item {
        id: section
        required property string modelData
        required property int index
        anchors.fill: parent

        readonly property var items: mock.entries(modelData)
        readonly property int pad: Math.max(Number(mock.val("islandGap", 0)), 6)

        // Остров под секцией (форма islands).
        Rectangle {
          visible: mock.shape === "islands" && section.items.length > 0
          x: mock.vertical ? 0 : row.x - section.pad
          y: mock.vertical ? row.y - section.pad : 0
          width: mock.vertical ? parent.width : row.width + 2 * section.pad
          height: mock.vertical ? row.height + 2 * section.pad : parent.height
          radius: mock.radius
          color: mock.transparent ? "transparent" : mock.fill
          border.width: mock.borderWidth
          border.color: mock.borderColor
        }

        Grid {
          id: row
          columns: mock.vertical ? 1 : Math.max(1, section.items.length)
          columnSpacing: Style.space(10) + Number(mock.val("spacing", 0))
          rowSpacing: Style.space(6) + Number(mock.val("spacing", 0))
          x: mock.vertical ? (parent.width - width) / 2
            : section.index === 0 ? mock.padding
            : section.index === 1 ? (parent.width - width) / 2
            : parent.width - width - mock.padding
          y: !mock.vertical ? (parent.height - height) / 2
            : section.index === 0 ? mock.padding
            : section.index === 1 ? (parent.height - height) / 2
            : parent.height - height - mock.padding

          Repeater {
            model: section.items
            delegate: Text {
              required property var modelData
              // Подложка модуля (pills); hover в макете не показать — рисуем как pills.
              Rectangle {
                z: -1
                visible: mock.moduleStyle === "pills"
                anchors.fill: parent
                anchors.margins: -Style.space(4)
                anchors.topMargin: -Style.space(2)
                anchors.bottomMargin: -Style.space(2)
                radius: height / 2
                color: mock.moduleColor
              }
              text: mock.glyph(modelData.id)
              color: /update|indicators/.test(modelData.id) ? mock.activeColor : mock.textColor
              font.family: mock.barFont
              font.pixelSize: Style.font.body
            }
          }
        }
      }
    }
  }
}
