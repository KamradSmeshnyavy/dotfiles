import QtQuick
import QtQuick.Shapes

// Вогнутый изгиб там, где пластиковая карточка слита с баром или рамкой (StyleCard.mergeEdges). Рисуется для верхнего
// края слева: (0, 0) — угол карточки на кромке бара, x < 0 — наружу вдоль кромки, y > 0 — в глубь карточки; к нужному
// краю и стороне его переносит матрица. Заливка закрывает контур бара на длине изгиба и боковой контур карточки до
// его конца, контур идёт дугой от линии контура бара к боковому контуру карточки.
Shape {
  id: fl

  property string edge: "top"
  property int side: -1               // -1 — у начала края (лево / верх), 1 — у конца
  property real w: 0                  // карточка
  property real h: 0
  property real f: 14                 // радиус изгиба
  property real bw: 2                 // толщина контура
  property real ext: 3                // насколько карточка заходит на контур бара
  property color fill: "white"
  property color line: "black"

  // x' = a·x + b·y + tx, y' = c·x + d·y + ty
  readonly property var m: {
    var lo = side < 0
    switch (edge) {
    case "top": return lo ? [1, 0, 0, 1, 0, 0] : [-1, 0, 0, 1, w, 0]
    case "bottom": return lo ? [1, 0, 0, -1, 0, h] : [-1, 0, 0, -1, w, h]
    case "left": return lo ? [0, 1, 1, 0, 0, 0] : [0, 1, -1, 0, 0, h]
    default: return lo ? [0, -1, 1, 0, w, 0] : [0, -1, -1, 0, w, h]
    }
  }
  width: 1; height: 1
  preferredRendererType: Shape.CurveRenderer
  transform: Matrix4x4 { matrix: Qt.matrix4x4(fl.m[0], fl.m[1], 0, fl.m[4], fl.m[2], fl.m[3], 0, fl.m[5], 0, 0, 1, 0, 0, 0, 0, 1) }

  ShapePath {
    fillColor: fl.fill
    strokeWidth: -1
    startX: -fl.f; startY: -fl.ext
    PathLine { x: fl.bw + 0.5; y: -fl.ext }
    PathLine { x: fl.bw + 0.5; y: fl.f }
    PathLine { x: fl.bw / 2; y: fl.f }
    PathQuad { x: -fl.f; y: -fl.bw / 2; controlX: fl.bw / 2; controlY: -fl.bw / 2 }
  }
  ShapePath {
    fillColor: "transparent"
    strokeColor: fl.bw > 0 ? fl.line : "transparent"
    strokeWidth: fl.bw > 0 ? fl.bw : -1
    capStyle: ShapePath.FlatCap
    startX: -fl.f - 0.5; startY: -fl.bw / 2
    PathLine { x: -fl.f; y: -fl.bw / 2 }
    PathQuad { x: fl.bw / 2; y: fl.f; controlX: fl.bw / 2; controlY: -fl.bw / 2 }
    PathLine { x: fl.bw / 2; y: fl.f + 0.5 }
  }
}
