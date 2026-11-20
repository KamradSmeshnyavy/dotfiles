import QtQuick
import Quickshell
import Quickshell.Io

// Движение «капли» — панель вытекает из бара, как drawer у Vitreus (github.com/natepayn3/Vitreus, MIT; числа его,
// код свой). Включается токеном стиля appear: "drip" (BarStyle.drip; у liquid — по умолчанию).
//   d       — раскрытие на пружине drip 235/21: ~5 % перелёта, без «проваливания» назад
//   sag     — провис при приземлении (hang 360/38, толчок 220), wobble — дрожь (splash 581/22, толчок −260)
//   reveal  — содержимое: появляется после формы (задержка revealDelay), поднимаясь на 12 px; уходит за 68 мс
//   revealAt(i) — то же по очереди, для блоков панели (шаг 70 мс)
// Закрылась (d < 0.08) — rippleAt(): по бару бежит рябь (бар читает $XDG_RUNTIME_DIR/omarchy-bar-ripple.json).
QtObject {
  id: m

  property bool active: false
  property bool open: false
  property real motion: 1
  property real stiffness: 235
  property real damping: 21
  property int revealDelay: 200
  property int revealDuration: 260
  // откуда рябь по бару: точка на кромке бара (логические px экрана) и имя экрана
  property point rippleOrigin: Qt.point(NaN, NaN)
  property string screenName: ""

  readonly property real d: dSpring.value
  readonly property real sag: sagSpring.value
  readonly property real wobble: wobSpring.value
  readonly property bool moving: dSpring.moving || sagSpring.moving || wobSpring.moving
  property real reveal: 0
  function revealAt(i) { return Math.max(0, Math.min(1, reveal * (1 + 0.27 * i) - 0.27 * i)) }

  signal landed()
  signal folded()

  property Spring dSpring: Spring { stiffness: m.stiffness; damping: m.damping; motion: m.motion }
  property Spring sagSpring: Spring { stiffness: 360; damping: 38; motion: m.motion }
  property Spring wobSpring: Spring { stiffness: 581; damping: 22; motion: m.motion }

  property bool landedOnce: false
  property bool foldedOnce: true
  onOpenChanged: {
    if (!active) return
    if (open) {
      landedOnce = false
      foldedOnce = false
      revealOut.stop()
      revealIn.restart()
      dSpring.target = 1
    } else {
      revealIn.stop()
      revealOut.restart()
      wobSpring.impulse(90)
      dSpring.target = 0
    }
  }
  onDChanged: {
    if (open && !landedOnce && d > 0.97) {
      landedOnce = true
      sagSpring.impulse(220)
      wobSpring.impulse(-260)
      landed()
    } else if (!open && !foldedOnce && d < 0.08) {
      foldedOnce = true
      folded()
      ripple()
    }
  }
  onActiveChanged: if (!active) { dSpring.snap(open ? 1 : 0); reveal = open ? 1 : 0 }

  property SequentialAnimation revealIn: SequentialAnimation {
    PauseAnimation { duration: Math.round(m.revealDelay * m.motion) }
    NumberAnimation { target: m; property: "reveal"; to: 1; duration: Math.round(m.revealDuration * m.motion); easing.type: Easing.OutCubic }
  }
  property NumberAnimation revealOut: NumberAnimation { target: m; property: "reveal"; to: 0; duration: Math.round(68 * m.motion) }

  function ripple() {
    if (isNaN(rippleOrigin.x)) return
    rippleFile.setText(JSON.stringify({ screen: screenName, x: Math.round(rippleOrigin.x), y: Math.round(rippleOrigin.y), t: Date.now() }) + "\n")
  }
  property FileView rippleFile: FileView {
    path: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/omarchy-bar-ripple.json"
    printErrors: false
  }
}
