import QtQuick
import QtQuick.Shapes
import qs.Commons as Commons

// Украшения основ тем Vitreus (по мотивам natepayn3/Vitreus, MIT; код и рисунки свои) — на больших панелях (StyleCard
// decor: дашборд, настройки, меню выключения). Retro рисует сам StyleCard (язычок, прорези, винт). Здесь:
//   cyber  — яркие уголки-скобки со свечением снаружи углов, линейка рисок под низом, «терминальный» код внизу справа
//            (три значения сменяются, блочный курсор мигает);
//   paper  — две полоски скотча (washi) держат лист за верхние углы;
//   uwu    — кошачьи уши на верхних углах, усы у нижних, три мерцающих звезды сверху, два покачивающихся сердечка;
//   proxy  — наклонная плита сверху слева с полосой здоровья (зелёная → жёлтая, под ней розовая) и номером, плашка
//            данных с синим значком сверху справа, полосатая «опасная» направляющая внизу;
//   doodle — второй контур, дрожащий как от руки.
// Слитые с баром / рамкой края (card.mergeEdges) украшений не получают.
Item {
  id: d

  required property var card
  readonly property string b: card.style.base
  readonly property bool on: card.material === "liquid" && card.decor
  readonly property color ink: Commons.Color.foreground
  readonly property color bg: Commons.Color.background
  readonly property color acc: Commons.Color.accent
  readonly property color accHi: Qt.lighter(acc, 1.35)
  readonly property bool topFree: !card.merged("top")
  readonly property bool botFree: !card.merged("bottom")
  readonly property bool leftFree: !card.merged("left")
  readonly property bool rightFree: !card.merged("right")
  readonly property real w: width
  readonly property real h: height

  anchors.fill: parent
  visible: on && ["cyber", "paper", "uwu", "proxy", "doodle"].indexOf(b) !== -1

  // общий такт анимаций (только пока видно)
  property int tick: 0
  Timer { interval: 140; repeat: true; running: d.visible && (d.b === "cyber" || d.b === "uwu"); onTriggered: d.tick++ }

  // ── cyber ──────────────────────────────────────────────────────────
  Item {
    anchors.fill: parent
    visible: d.b === "cyber"
    Repeater {
      model: [[0, 0], [1, 0], [0, 1], [1, 1]]
      Shape {
        id: br
        required property var modelData
        readonly property int sx: modelData[0] ? 1 : -1
        readonly property int sy: modelData[1] ? 1 : -1
        // угол без скобки, если хоть одна из его сторон слита
        visible: (modelData[1] ? d.botFree : d.topFree) && (modelData[0] ? d.rightFree : d.leftFree)
        x: modelData[0] ? d.w + 7 : -7
        y: modelData[1] ? d.h + 7 : -7
        width: 1; height: 1
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          strokeColor: Qt.rgba(d.acc.r, d.acc.g, d.acc.b, 0.16); strokeWidth: 5; fillColor: "transparent"; capStyle: ShapePath.FlatCap
          PathMove { x: 0; y: -br.sy * 15 }
          PathLine { x: 0; y: 0 }
          PathLine { x: -br.sx * 15; y: 0 }
        }
        ShapePath {
          strokeColor: d.accHi; strokeWidth: 1.7; fillColor: "transparent"; capStyle: ShapePath.FlatCap
          PathMove { x: 0; y: -br.sy * 15 }
          PathLine { x: 0; y: 0 }
          PathLine { x: -br.sx * 15; y: 0 }
        }
      }
    }
    // линейка рисок под низом
    Repeater {
      model: d.botFree ? 14 : 0
      Rectangle {
        required property int index
        x: 22 + index * 6; y: d.h + 8
        width: 1.1; height: index % 4 === 0 ? 6 : 3
        color: d.acc; opacity: 0.7
      }
    }
    // код внизу справа и мигающий курсор
    Text {
      readonly property var codes: ["SYS 2B6D·F418", "SYS E90C·57A3", "SYS 30D8·B166"]
      anchors { right: parent.right; rightMargin: 22; bottom: parent.bottom; bottomMargin: 4 }
      text: codes[d.tick % 3]
      font.family: "monospace"
      font.pixelSize: 10
      font.weight: Font.Medium
      color: d.accHi
      opacity: 0.85
    }
    Rectangle {
      anchors { right: parent.right; rightMargin: 12; bottom: parent.bottom; bottomMargin: 6 }
      width: 5; height: 10
      color: d.accHi
      opacity: Math.floor(d.tick / 2) % 2 === 0 ? 0.9 : 0
    }
  }

  // ── paper: скотч ───────────────────────────────────────────────────
  Item {
    anchors.fill: parent
    visible: d.b === "paper" && d.topFree
    component Tape: Item {
      property color tint
      width: 60; height: 19
      Rectangle { anchors.fill: parent; color: parent.tint; opacity: 0.86 }
      Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Qt.rgba(d.ink.r, d.ink.g, d.ink.b, 0.22) }
      Rectangle { x: 0; y: 4; width: parent.width; height: 1.2; color: "white"; opacity: 0.3 }
      // зубчатые торцы
      Repeater {
        model: 2
        Column {
          required property int index
          x: index ? parent.width - 1 : -2
          Repeater { model: 5; Rectangle { width: 3; height: 3.8; color: d.bg; rotation: 45; opacity: 0.9 } }
        }
      }
    }
    Tape { x: 0; y: -11; width: 60; tint: "#e9dba8"; rotation: -11 }
    Tape { x: d.w - 93; y: -5; width: 70; tint: "#c9d8ec"; rotation: 3 }
  }

  // ── uwu ────────────────────────────────────────────────────────────
  Item {
    anchors.fill: parent
    visible: d.b === "uwu"
    // уши
    Repeater {
      model: d.topFree ? [-1, 1] : []
      Shape {
        id: ear
        required property var modelData
        readonly property int sg: modelData
        x: sg < 0 ? 50 : d.w - 50
        y: 0
        width: 1; height: 1
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          fillColor: d.bg; strokeColor: d.ink; strokeWidth: 3; joinStyle: ShapePath.RoundJoin
          PathMove { x: -23; y: 8 }
          PathLine { x: ear.sg * 13; y: -30 }
          PathLine { x: 23; y: 8 }
        }
        ShapePath {
          fillColor: "#ff8fc8"; strokeWidth: -1
          PathMove { x: -14; y: 5 }
          PathLine { x: ear.sg * 9; y: -19 }
          PathLine { x: 14; y: 5 }
        }
      }
    }
    // усы у нижних углов
    Repeater {
      model: d.botFree ? 6 : 0
      Item {
        id: wh
        required property int index
        readonly property int s: index < 3 ? -1 : 1
        readonly property int k: index % 3 - 1
        x: index < 3 ? 0 : d.w
        y: d.h - 20 + k * 7
        Rectangle { x: wh.s < 0 ? -26 : -6; y: -2; width: 32; height: 4; radius: 2; color: d.ink; rotation: -wh.s * wh.k * 11 }
        Rectangle { x: wh.s < 0 ? -25 : -5; y: -0.9; width: 30; height: 1.8; radius: 1; color: "white"; rotation: -wh.s * wh.k * 11 }
      }
    }
    // звёзды сверху
    Repeater {
      model: d.topFree ? 3 : 0
      Shape {
        id: st
        required property int index
        readonly property real r: index === 1 ? 10 : 7.5
        x: d.w / 2 + (index - 1) * 44
        y: 12
        width: 1; height: 1
        scale: 1 + 0.22 * Math.sin((d.tick * 0.14 * 160 + index * 120) * Math.PI / 180)
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          strokeColor: d.ink; strokeWidth: 1.6; joinStyle: ShapePath.RoundJoin
          fillColor: ["#ffe27a", "#ffffff", "#7fd3ff"][st.index]
          PathPolyline {
            readonly property real r: st.r
            path: [Qt.point(0, -r), Qt.point(0.3 * r, -0.3 * r), Qt.point(r, 0), Qt.point(0.3 * r, 0.3 * r), Qt.point(0, r),
                   Qt.point(-0.3 * r, 0.3 * r), Qt.point(-r, 0), Qt.point(-0.3 * r, -0.3 * r), Qt.point(0, -r)]
          }
        }
      }
    }
    // сердечки внизу слева
    Repeater {
      model: d.botFree ? 2 : 0
      Text {
        required property int index
        x: 18 + index * 22
        y: d.h - 22 + 2 * Math.sin((d.tick * 0.14 * 200 + index * 90) * Math.PI / 180)
        text: "♥"
        font.pixelSize: index === 0 ? 15 : 12
        color: index === 0 ? "#ff6eb4" : "#b69cff"
        style: Text.Outline
        styleColor: d.ink
      }
    }
  }

  // лапки внизу справа (три следа, как у Vitreus UwU)
  Repeater {
    model: d.b === "uwu" && d.botFree ? 3 : 0
    Item {
      id: paw
      required property int index
      x: d.w - 70 + index * 22
      y: d.h - 4 - (index % 2) * 3
      rotation: -12 + index * 12
      Rectangle { x: -5.5; y: -3; width: 11; height: 9; radius: 4.5; color: "#ff8fc8"; border.width: 1.4; border.color: d.ink }
      Repeater {
        model: [[-7, -8], [-2.2, -11], [2.8, -11], [7.4, -8]]
        Rectangle {
          required property var modelData
          x: modelData[0] - 2.6; y: modelData[1] - 2.6
          width: 5.2; height: 5.2; radius: 2.6
          color: "#ff8fc8"; border.width: 1.2; border.color: d.ink
        }
      }
    }
  }

  // ── proxy ──────────────────────────────────────────────────────────
  Item {
    anchors.fill: parent
    visible: d.b === "proxy"
    // наклонная плита с полосой здоровья
    Item {
      visible: d.topFree
      x: 18; y: -15
      width: 170; height: 24
      Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          fillColor: "#0b0d10"; strokeColor: Qt.rgba(0.9, 0.95, 0.96, 0.6); strokeWidth: 1
          PathMove { x: 8; y: 0 }
          PathLine { x: 170; y: 0 }
          PathLine { x: 162; y: 24 }
          PathLine { x: 0; y: 24 }
          PathLine { x: 8; y: 0 }
        }
      }
      Rectangle { x: 10; y: 4; width: 20; height: 16; color: "#2a8cff"
        Text { anchors.centerIn: parent; text: "07"; color: "white"; font.pixelSize: 10; font.weight: Font.Bold; font.family: "monospace" } }
      Rectangle {
        x: 36; y: 6; width: 116; height: 6
        gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: "#3dff8a" } GradientStop { position: 1; color: "#ffe14d" } }
      }
      Rectangle { x: 36; y: 15; width: 74; height: 3; color: "#ff4f9a" }
    }
    // плашка данных с синим значком
    Rectangle {
      visible: d.topFree
      x: d.w - 96; y: -10
      width: 78; height: 20; radius: 10
      color: "#0b0d10"
      border.width: 1; border.color: Qt.rgba(0.9, 0.95, 0.96, 0.6)
      Rectangle { x: 3; y: 3; width: 14; height: 14; radius: 7; color: "#2a8cff" }
      Text { x: 23; anchors.verticalCenter: parent.verticalCenter; text: "LV 42"; color: "#e6f2f5"; font.pixelSize: 10; font.weight: Font.Bold; font.family: "monospace" }
    }
    // «опасная» направляющая внизу
    Item {
      visible: d.botFree && d.w > 160
      x: 54; y: d.h - 13
      width: d.w - 108; height: 9
      clip: true
      Rectangle { anchors.fill: parent; color: "#0b0d10" }
      Repeater {
        model: Math.ceil((d.w - 108) / 16) + 1
        Shape {
          required property int index
          x: index * 16; width: 14; height: 9
          ShapePath {
            fillColor: "#ffd21f"; strokeWidth: -1
            PathMove { x: 5; y: 0 }
            PathLine { x: 13; y: 0 }
            PathLine { x: 8; y: 9 }
            PathLine { x: 0; y: 9 }
          }
        }
      }
    }
  }

  // ── doodle: второй контур от руки ─────────────────────────────────
  Shape {
    id: dd
    anchors.fill: parent
    visible: d.b === "doodle" && d.card.mergeEdges.length === 0
    preferredRendererType: Shape.CurveRenderer
    // дрожь — от seed карточки, а не случайная на каждом кадре
    function jit(i) { var x = Math.sin((i + 1) * 12.9898 + (d.card.seed || 0) * 78.233) * 43758.5453; return (x - Math.floor(x)) * 2 - 1 }
    ShapePath {
      fillColor: "transparent"; strokeColor: Qt.rgba(d.ink.r, d.ink.g, d.ink.b, 0.7); strokeWidth: 1.5
      capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
      PathPolyline {
        path: {
          var pts = [], n = 0, W = d.w, H = d.h, o = 3.5, step = 22
          function p(x, y) { pts.push(Qt.point(x + dd.jit(n++) * 1.6, y + dd.jit(n++) * 1.6)) }
          for (var x = -o; x <= W + o; x += step) p(x, -o)
          for (var y = -o; y <= H + o; y += step) p(W + o, y)
          for (x = W + o; x >= -o; x -= step) p(x, H + o)
          for (y = H + o; y >= -o; y -= step) p(-o, y)
          pts.push(pts[0])
          return pts
        }
      }
    }
  }
}
