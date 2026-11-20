import QtQuick

// Пружина с массой 1, как spring у pleamar (Vitreus): stiffness, damping — те же числа, что у него
// (drip 235/21 — перелёт ~5 %, splash 581/22, hang 360/38). value тянется к target; impulse(v) — толчок скоростью
// v px/с (так Vitreus качает панель при приземлении). Считает только пока движется (FrameAnimation), в покое кадров нет.
// motion — множитель длительностей стиля (BarStyle.motion): 2 — вдвое медленнее, 0 — сразу в цель.
QtObject {
  id: s

  property real target: 0
  property real value: 0
  property real velocity: 0
  property real stiffness: 235
  property real damping: 21
  property real motion: 1
  readonly property bool moving: anim.running

  function impulse(v) {
    if (motion <= 0) return
    velocity += v
    anim.running = true
  }
  // сразу в точку, без движения
  function snap(v) {
    anim.running = false
    velocity = 0
    value = v === undefined ? target : v
  }
  onTargetChanged: {
    if (motion <= 0) { snap(target); return }
    if (target !== value || velocity !== 0) anim.running = true
  }

  property FrameAnimation anim: FrameAnimation {
    running: false
    onTriggered: {
      // мелкие шаги: жёсткие пружины (581) на 60 Гц иначе разносит
      var dt = Math.min(frameTime, 1 / 20) / Math.max(0.05, s.motion)
      var n = Math.max(1, Math.ceil(dt * 240)), h = dt / n
      var x = s.value, v = s.velocity
      for (var i = 0; i < n; i++) {
        v += (s.stiffness * (s.target - x) - s.damping * v) * h
        x += v * h
      }
      if (Math.abs(s.target - x) < 0.0005 && Math.abs(v) < 0.005) {
        x = s.target
        v = 0
        running = false
      }
      s.velocity = v
      s.value = x
    }
  }
}
