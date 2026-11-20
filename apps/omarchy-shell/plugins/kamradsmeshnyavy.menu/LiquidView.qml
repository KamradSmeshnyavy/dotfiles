import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons

// Liquid — стеклянная карточка по мотивам лаунчера Vitreus (github.com/natepayn3/Vitreus, MIT; код свой): сверху
// крупные часы, поиск-пилюля с подписью раздела, под ней — подсказки быстрых режимов, ниже строки с иконкой, названием
// и описанием; выбранная залита акцентом. Карточка полупрозрачная — за ней размывает Hyprland (layer_rule
// omarchy-menu в apps/hyprland/windows.lua), фон вокруг почти прозрачный, чтобы размывалась только она.
// Основа темы Vitreus (~/.config/omarchy/style.json "base", пишут пресеты Liquid-*) меняет карточку:
//   пластик (retro, doodle, proxy, milk, paper) — сплошная заливка цветом фона темы, контур чернилами, жёсткая тень,
//   углы почти квадратные; шапка как у лаунчера Vitreus — значок из четырёх квадратиков, SEARCH, режим поиска; подсказки
//   двумя рядами ячеек; retro — ещё красный язычок сверху, прорези-ручки и винт, выбор с красным оттенком;
//   cyber — стекло с уголками-скобками, линейкой рисок и мигающим «терминальным» кодом.
// «Капля» (style.json appear drip, у liquid — по умолчанию; panel-shadow.json panelAppear — выбор пользователя): лаунчер
// вытекает из кнопки меню на баре одним куском с баром, как у Vitreus (DrawerGeom + DripMotion + LiquidGlass — копии из
// kamradsmeshnyavy.widgets), содержимое проявляется после формы; закрылся — втягивается обратно, бар колышется.
SkinBase {
  id: root

  readonly property real k: root.u
  // Retro у Vitreus на ходу пикселится (DripMotion.pixel, Pixelate.qml)
  layer.enabled: root.retro && root.drip && drop.pixel > 1
  layer.effect: Pixelate { px: drop.pixel }
  readonly property color fg: root.foreground
  readonly property color glassFill: Qt.rgba(root.background.r, root.background.g, root.background.b, 0.42)
  readonly property color rim: Qt.rgba(1, 1, 1, 0.28)
  readonly property int rowH: Math.round(60 * k)

  // основа темы
  property string base: "glass"
  property var look: ({})
  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/style.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { var d = JSON.parse(text()); root.look = d || {}; root.base = String(d.material === "liquid" && d.base ? d.base : "glass") } catch (e) { root.base = "glass"; root.look = {} } }
  }
  property string panelAppear: "auto"
  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/panel-shadow.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { root.panelAppear = String(JSON.parse(text()).panelAppear || "auto") } catch (e) { root.panelAppear = "auto" } }
    onLoadFailed: root.panelAppear = "auto"
  }
  readonly property real motion: { var m = Number(look.motion); return isFinite(m) ? Math.max(0, m) : 1 }
  readonly property string appear: panelAppear === "drip" || panelAppear === "classic" ? panelAppear
    : look.appear === "drip" || look.appear === "classic" ? String(look.appear) : (look.material === "liquid" ? "drip" : "classic")
  readonly property bool drip: appear === "drip" && motion > 0 && geo.barLayer.width > 0

  // ── капля из бара ──
  BarGeom { id: geo }
  DripMotion {
    id: drop
    active: root.drip
    open: root.barMode ? root.live : (root.live || tp.value > 0.3)
    motion: root.motion
    revealDelay: root.barMode ? 180 : 260
    screenName: Hyprland.focusedMonitor ? String(Hyprland.focusedMonitor.name) : ""
    rippleOrigin: root.barMode ? Qt.point(dg.startRect.x + dg.startRect.width / 2, dg.startRect.y + dg.startRect.height / 2)
                               : Qt.point(root.midX, root.topIn / 2)
    onDChanged: if (root.live && !root.barMode && d > 0.5) tp.target = 1
  }
  // окно меню держится открытым, пока капля втягивается (Menu.qml смотрит holding)
  readonly property bool holding: drop.active && !root.live && (drop.d > 0.002 || tp.value > 0.002)

  // ── как у Vitreus (vitreus.plm, edg / lp.ty): в раскладке с рамкой поиск выпадает из середины верхней кромки, висит
  // на ней каплей, отрывается и опускается выше середины экрана — max(середина − 210, верх + 24 + половина высоты);
  // закрывается обратным путём. Бар сверху (его Island) или скин liquid-bar — растёт из кнопки меню на баре (DrawerGeom).
  readonly property bool barMode: root.variant === "bar" || String(geo.exported.position || "") === "top"
  readonly property string barPos: String(geo.exported.position || "")
  readonly property real barSz: Number(geo.exported.barSize) || 0
  readonly property real fw: geo.framed ? geo.frameWidth : 0
  readonly property real topIn: barPos === "top" ? barSz : fw
  readonly property real loX: barPos === "left" ? barSz : fw
  readonly property real hiX: root.width - (barPos === "right" ? barSz : fw)
  readonly property real botIn: root.height - (barPos === "bottom" ? barSz : fw)
  readonly property real midX: (loX + hiX) / 2
  readonly property real restY: Math.max((topIn + botIn) / 2 - 210 * k - card.height / 2, topIn + 24 * k)
  // путь вниз (dripl 180/16): 0 — висит на кромке, 1 — на своём месте
  Spring { id: tp; stiffness: 180; damping: 16; motion: root.motion }
  readonly property real dd: Math.max(0, drop.d)
  readonly property real bell: Math.max(0, 4 * dd * (1 - dd))
  readonly property real lf: Math.min(1, 1.6 * dd) + Math.max(0, dd - 1) * 0.6
  readonly property real topW: Math.max(0, card.width * lf * (1 - 0.07 * bell + 0.003 * drop.wobble))
  readonly property real topH: Math.max(0, (card.height * dd + Math.max(0, drop.sag)) * (1 - 0.002 * drop.wobble))
  readonly property rect topRect: Qt.rect(midX - topW / 2, topIn + (restY - topIn) * tp.value, topW, topH)
  readonly property real topNeck: (26 + 20 * bell) * Math.min(1, 4 * dd) * (1 - 0.85 * root.sq)
  // итог для тела капли
  readonly property rect bodyRect: barMode ? dg.morph : topRect
  readonly property real bodyR: {
    if (barMode) return dg.dripRadius
    var pill = Math.min(topRect.width, topRect.height) / 2
    return pill + (Math.min(root.cardR, pill) - pill) * Math.max(0, Math.min(1, 1.6 * dd - 0.1))
  }
  readonly property real neckKNow: barMode ? dg.neckK : topNeck
  readonly property rect neckNow: barMode ? dg.neckFor(bodyRect)
    : Qt.rect(topRect.x - topNeck - 6, topIn - 8, topRect.width + 2 * topNeck + 12, 5)
  readonly property rect cutNow: barMode ? dg.cut : Qt.rect(-4000, -4000, 8000 + root.width, 4000 + topIn - 3)
  readonly property var mergeNow: drop.d < 0.6 ? [] : barMode ? dg.mergeEdges : (tp.value < 0.05 ? ["top"] : [])
  // содержимое едет вместе с каплей и проявляется на подходе к месту
  readonly property point endPos: barMode ? Qt.point(dg.endRect.x, dg.endRect.y) : Qt.point(midX - card.width / 2, topRect.y)
  readonly property real reveal: barMode ? drop.reveal : drop.reveal * Math.max(0, Math.min(1, (tp.value - 0.45) / 0.4))
  DrawerGeom {
    id: dg
    geo: geo
    bodyWidth: card.width
    bodyHeight: card.height
    progress: drop.d
    anchorIds: ["kamradsmeshnyavy.menu", "omarchy.launcher", "vit-icons"]
    scrW: root.width
    scrH: root.height
    drip: true
    sag: drop.sag
    wobble: drop.wobble
    squareness: root.sq
    panelRadius: root.cardR
  }
  onLiveChanged: { if (live) geo.refresh(); else tp.target = 0 }
  readonly property bool plastic: ["retro", "doodle", "proxy", "milk", "paper", "uwu"].indexOf(base) !== -1
  // uwu — «конфетный пластик» Vitreus: пастельный градиент, контур цвета винограда, розовая жёсткая тень
  readonly property bool candy: base === "uwu"
  readonly property bool retro: base === "retro"
  readonly property bool cyber: base === "cyber"
  readonly property real sq: ({ retro: 1, doodle: 1, proxy: 1, cyber: 1, paper: 0.6 })[base] || 0
  readonly property real cardR: 30 * k * (1 - 0.73 * sq)
  readonly property real bw: ({ retro: 2.3, doodle: 2.8, proxy: 1.9, paper: 1.6, milk: 0, uwu: 3 })[base] || 1
  readonly property point hard: ({ retro: Qt.point(6, 7), doodle: Qt.point(3.5, 3.5), proxy: Qt.point(3.4, 4), uwu: Qt.point(4, 5) })[base] || Qt.point(0, 0)
  readonly property color ink: root.fg
  readonly property color deep: Qt.darker(ink, 1.45)
  readonly property color hardColor: base === "uwu" ? Qt.rgba(deep.r * 0.25 + 0.75, deep.g * 0.25 + 0.43, deep.b * 0.25 + 0.78, 0.9) : base === "proxy" ? "#2a8cff" : base === "doodle" ? ink : Qt.rgba(ink.r, ink.g, ink.b, 0.55)
  property int tick: 0
  Timer { interval: 140; repeat: true; running: root.live && root.cyber; onTriggered: root.tick++ }

  function navigate(dx, dy) { root.step(dy !== 0 ? dy : dx) }

  property real t: 0
  onWoke: { t = 0; t = 1 }
  Component.onCompleted: t = 1
  Behavior on t { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

  // почти прозрачный фон: ниже порога ignore_alpha размытие не идёт
  Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.12) }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(m) { if (m.button === Qt.RightButton) root.backRequested(); else root.dismissRequested() }
  }

  // жёсткая тень пластика — копия карточки со сдвигом, без размытия
  Rectangle {
    visible: root.plastic && root.hard.x > 0 && (!root.drip || drop.d > 0.6)
    x: (root.drip ? root.bodyRect.x : card.x) + root.hard.x; y: (root.drip ? root.bodyRect.y : card.y) + root.hard.y
    width: root.drip ? root.bodyRect.width : card.width; height: root.drip ? root.bodyRect.height : card.height
    radius: root.drip ? root.bodyR : card.radius
    color: root.hardColor
    opacity: root.drip ? Math.min(1, (drop.d - 0.6) * 2.5) : root.t
  }
  Gradient {
    id: candyGrad
    orientation: Gradient.Horizontal
    GradientStop { position: 0; color: "#ffb3dc" }
    GradientStop { position: 0.38; color: "#cfc4ff" }
    GradientStop { position: 0.68; color: "#aab4ff" }
    GradientStop { position: 1; color: "#ffd0ea" }
  }
  // тело капли: стекло одним куском с баром (перешеек, крылья у рамки) или пластик со слитыми краями
  LiquidGlass {
    id: body
    visible: root.drip && !root.plastic && drop.d > 0.001
    x: root.bodyRect.x; y: root.bodyRect.y
    width: root.bodyRect.width; height: root.bodyRect.height
    radius: root.bodyR
    screenOrigin: Qt.point(x, y)
    tintColor: root.background
    bleed: 2 * dg.fillet + 70
    readonly property rect neck: root.neckNow
    joinRect: root.neckKNow > 0 ? Qt.rect(neck.x - x, neck.y - y, neck.width, neck.height) : Qt.rect(0, 0, 0, 0)
    joinRadius: 2.5
    joinK: root.neckKNow
    join2Rect: root.barMode && dg.wing.width > 0 && dg.wingK > 0.5 ? Qt.rect(dg.wing.x - x, dg.wing.y - y, dg.wing.width, dg.wing.height) : Qt.rect(0, 0, 0, 0)
    join2K: dg.wingK
    cutRect: Qt.rect(root.cutNow.x - x, root.cutNow.y - y, root.cutNow.width, root.cutNow.height)
    cut2Rect: root.barMode && dg.cut2.width > 0 ? Qt.rect(dg.cut2.x - x, dg.cut2.y - y, dg.cut2.width, dg.cut2.height) : Qt.rect(0, 0, 0, 0)
  }
  Item {
    id: plasticBody
    visible: root.drip && root.plastic && drop.d > 0.001
    readonly property var edges: root.mergeNow
    function merged(e) { return edges.indexOf(e) !== -1 }
    readonly property real ext: 3
    function grow(e) { return merged(e) ? root.bw + 12 : 0 }
    function cutOut(e) { return merged(e) ? ext : 0 }
    x: root.bodyRect.x - cutOut("left"); y: root.bodyRect.y - cutOut("top")
    width: root.bodyRect.width + cutOut("left") + cutOut("right"); height: root.bodyRect.height + cutOut("top") + cutOut("bottom")
    clip: edges.length > 0
    Rectangle {
      x: plasticBody.cutOut("left") - plasticBody.grow("left"); y: plasticBody.cutOut("top") - plasticBody.grow("top")
      width: root.bodyRect.width + plasticBody.grow("left") + plasticBody.grow("right")
      height: root.bodyRect.height + plasticBody.grow("top") + plasticBody.grow("bottom")
      radius: root.bodyR
      color: root.background
      gradient: root.candy ? candyGrad : null
      border { width: root.bw; color: root.base === "paper" ? Util.alpha(root.ink, 0.45) : root.base === "proxy" ? Qt.rgba(0.9, 0.95, 0.96, 0.6) : root.candy ? root.deep : root.ink }
    }
  }
  Repeater {
    model: root.drip && root.plastic && plasticBody.edges.length > 0
      ? [["top", -1], ["top", 1], ["bottom", -1], ["bottom", 1], ["left", -1], ["left", 1], ["right", -1], ["right", 1]].filter(function(m) {
          var adj = m[0] === "top" || m[0] === "bottom" ? (m[1] < 0 ? "left" : "right") : (m[1] < 0 ? "top" : "bottom")
          return plasticBody.merged(m[0]) && !plasticBody.merged(adj)
        }) : []
    MergeFillet {
      required property var modelData
      x: root.bodyRect.x; y: root.bodyRect.y
      edge: modelData[0]; side: modelData[1]
      w: root.bodyRect.width; h: root.bodyRect.height
      f: 22; bw: root.bw; ext: plasticBody.ext
      fill: root.candy ? "#cfc4ff" : root.background
      line: root.base === "paper" ? Util.alpha(root.ink, 0.45) : root.base === "proxy" ? Qt.rgba(0.9, 0.95, 0.96, 0.6) : root.candy ? root.deep : root.ink
    }
  }
  Rectangle {
    id: card
    x: root.drip ? root.endPos.x : (parent.width - width) / 2
    y: root.drip ? root.endPos.y + 12 * (1 - root.reveal) : parent.height * 0.14 + 30 * k * (1 - root.t)
    opacity: root.drip ? root.reveal : root.t
    scale: root.drip ? 1 : 0.96 + 0.04 * root.t
    width: Math.round(680 * k)
    height: Math.min(parent.height * 0.76, head.height + search.height + (root.plastic ? hintsGrid.height : hints.height) + list.contentHeight + foot.height + 110 * k)
    radius: root.cardR
    color: root.drip ? "transparent" : root.plastic ? root.background : root.glassFill
    gradient: !root.drip && root.candy ? candyGrad : null
    border { width: root.drip ? 0 : root.bw; color: root.plastic ? (root.base === "paper" ? Util.alpha(root.ink, 0.45) : root.base === "proxy" ? Qt.rgba(0.9, 0.95, 0.96, 0.6) : root.candy ? root.deep : root.ink) : root.rim }
    MouseArea { anchors.fill: parent; onWheel: function(w) { root.wheelStep(w) } }

    // блик по верхней кромке — «жидкое стекло» (у капли блик рисует LiquidGlass)
    Rectangle {
      visible: !root.plastic && !root.drip
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: 60 * k
      radius: card.radius
      gradient: Gradient {
        GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.16) }
        GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) }
      }
    }

    // шапка: заголовок меню слева, часы справа
    Item {
      id: head
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 26 * k }
      height: 52 * k
      // пластик: значок из четырёх квадратиков, SEARCH › режим (как у лаунчера Vitreus)
      Row {
        visible: root.plastic
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10 * k
        Rectangle {
          width: 32 * k; height: 32 * k; radius: 9 * k * (1 - 0.6 * root.sq)
          color: Util.alpha(root.accent, 0.2)
          Grid {
            anchors.centerIn: parent
            columns: 2; spacing: 2 * k
            rotation: root.title ? 90 : 0
            Behavior on rotation { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
            Repeater { model: 4; Rectangle { width: 6.5 * k; height: 6.5 * k; radius: 2 * k * (1 - 0.6 * root.sq); color: "transparent"; border { width: 1.5 * k; color: root.accent } } }
          }
        }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "SEARCH"; color: root.ink; font { family: root.fontFamily; pixelSize: 19 * k; weight: Font.Bold } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: "›"; color: Util.alpha(root.ink, 0.45); font { family: root.fontFamily; pixelSize: 18 * k } }
        Text { anchors.verticalCenter: parent.verticalCenter; text: (root.title || "Apps").toLowerCase(); color: root.accent; font { family: root.fontFamily; pixelSize: 16 * k; weight: Font.Bold } }
      }
      Row {
        visible: !root.plastic
        anchors.verticalCenter: parent.verticalCenter
        spacing: 7 * k
        Repeater {
          model: 4
          Rectangle { required property int index; width: index === 2 ? 26 * k : 10 * k; height: 10 * k; radius: 5 * k; color: index === 2 ? root.accent : Qt.rgba(1, 1, 1, index < 2 ? 0.85 : 0.35) }
        }
      }
      Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 8 * k
        Text { id: hh; text: Qt.formatTime(clockTick.now, "HH:mm"); color: root.fg; font { family: root.fontFamily; pixelSize: 40 * k; weight: Font.Bold } }
        Column {
          anchors.verticalCenter: hh.verticalCenter
          Text { text: Qt.locale().toString(clockTick.now, "ddd").toUpperCase(); color: Util.alpha(root.fg, 0.75); font { family: root.fontFamily; pixelSize: 12 * k; weight: Font.DemiBold } }
          Text { text: Qt.formatDate(clockTick.now, "d MMM"); color: Util.alpha(root.fg, 0.6); font { family: root.fontFamily; pixelSize: 12 * k } }
        }
      }
      QtObject { id: clockTick; property date now: new Date() }
      Timer { interval: 10000; running: root.live; repeat: true; triggeredOnStart: true; onTriggered: clockTick.now = new Date() }
    }

    // поиск-пилюля
    Rectangle {
      id: search
      anchors { left: parent.left; right: parent.right; top: head.bottom; margins: 22 * k; topMargin: 16 * k }
      height: (root.plastic ? 46 : 56) * k
      radius: root.plastic ? 20 * k * (1 - 0.5 * root.sq) : height / 2
      color: root.plastic ? Util.alpha(root.ink, 0.08) : Qt.rgba(1, 1, 1, 0.12)
      border { width: root.plastic ? 1 : 1; color: root.plastic ? Util.alpha(root.ink, 0.22) : Qt.rgba(1, 1, 1, 0.18) }
      Text { id: lens; x: 22 * k; anchors.verticalCenter: parent.verticalCenter; text: "󰍉"; color: root.accent; font { family: root.mono; pixelSize: 22 * k } }
      Text {
        anchors { left: lens.right; leftMargin: 14 * k; right: mode.left; rightMargin: 10 * k; verticalCenter: parent.verticalCenter }
        textFormat: Text.PlainText
        elide: Text.ElideLeft
        text: root.query.length ? root.query : "Search…"
        color: root.query.length ? root.fg : Util.alpha(root.fg, 0.5)
        font { family: root.fontFamily; pixelSize: 18 * k }
      }
      Text {
        id: mode
        anchors { right: parent.right; rightMargin: 22 * k; verticalCenter: parent.verticalCenter }
        visible: !root.plastic
        text: root.title || "Apps"
        color: root.accent
        font { family: root.fontFamily; pixelSize: 13 * k; weight: Font.DemiBold }
      }
    }

    // быстрые режимы — по первому символу поиска (Modes.js)
    // пластик: две строки по три ячейки с разделителями
    Grid {
      id: hintsGrid
      visible: root.plastic
      anchors { left: search.left; right: search.right; top: search.bottom; topMargin: 10 * k }
      columns: 3
      rowSpacing: 2 * k
      Repeater {
        model: [["=", "calc"], [":", "emoji"], ["@", "windows"], ["!", "web"], [";", "clipboard"], [">", "commands"]]
        Item {
          required property var modelData
          required property int index
          readonly property bool on: root.query.charAt(0) === modelData[0]
          width: hintsGrid.width / 3; height: 20 * k
          Rectangle { anchors.fill: parent; anchors.margins: 1; radius: 9 * k * (1 - 0.6 * root.sq); color: Util.alpha(root.ink, parent.on ? 0.1 : 0) }
          Rectangle { visible: index % 3 > 0; x: 0; anchors.verticalCenter: parent.verticalCenter; width: 1; height: 10 * k; color: Util.alpha(root.ink, 0.18) }
          Row {
            anchors.centerIn: parent
            spacing: 6 * k
            Text { text: modelData[0]; color: root.accent; font { family: root.fontFamily; pixelSize: 15 * k; weight: Font.Bold } }
            Text { text: modelData[1]; color: parent.parent.on ? root.ink : Util.alpha(root.ink, 0.62); font { family: root.fontFamily; pixelSize: 13 * k } }
          }
        }
      }
    }
    Row {
      id: hints
      visible: !root.plastic
      anchors { horizontalCenter: parent.horizontalCenter; top: search.bottom; topMargin: 12 * k }
      spacing: 18 * k
      Repeater {
        model: [["=", "calc"], [":", "emoji"], ["@", "windows"], ["!", "web"], [";", "clipboard"], [">", "commands"]]
        Row {
          required property var modelData
          spacing: 6 * k
          readonly property bool on: root.query.charAt(0) === modelData[0]
          Text { text: parent.modelData[0]; color: root.accent; font { family: root.mono; pixelSize: 13 * k; weight: Font.Bold } }
          Text { text: parent.modelData[1]; color: parent.on ? root.fg : Util.alpha(root.fg, 0.6); font { family: root.fontFamily; pixelSize: 12 * k } }
        }
      }
    }

    ListView {
      id: list
      anchors { left: parent.left; right: parent.right; top: root.plastic ? hintsGrid.bottom : hints.bottom; bottom: foot.top; margins: 16 * k; topMargin: 14 * k }
      clip: true
      spacing: 6 * k
      model: root.rowModel
      currentIndex: root.selectedIndex
      highlightFollowsCurrentItem: false
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

      delegate: Rectangle {
        id: row
        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label
        required property string detail
        readonly property bool on: root.cursorActive && index === root.selectedIndex
        width: list.width
        height: root.rowH
        radius: 18 * root.k * (1 - 0.6 * root.sq)
        color: root.plastic
          ? (on ? Util.alpha(root.accent, 0.22) : Util.alpha(root.ink, area.containsMouse ? 0.07 : 0.03))
          : (on ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.45) : Qt.rgba(1, 1, 1, area.containsMouse ? 0.1 : 0.05))
        border { width: root.plastic && on ? 1.6 : 1; color: on ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.8) : root.plastic ? Util.alpha(root.ink, 0.1) : Qt.rgba(1, 1, 1, 0.08) }
        Behavior on color { ColorAnimation { duration: 120 } }

        RowIcon {
          id: ico
          x: 14 * root.k
          anchors.verticalCenter: parent.verticalCenter
          size: 36 * root.k
          kind: row.kind
          glyph: row.icon
          glyphFont: row.iconFont
          appIcon: row.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: Math.abs(row.index - root.selectedIndex) < 30
          fallback: row.label.length ? row.label.charAt(0).toUpperCase() : "•"
          color: row.on ? root.fg : Util.alpha(root.fg, 0.85)
        }
        Column {
          anchors { left: ico.right; leftMargin: 14 * root.k; right: parent.right; rightMargin: 16 * root.k; verticalCenter: parent.verticalCenter }
          spacing: 2 * root.k
          Text { width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.label; color: root.fg; font { family: root.fontFamily; pixelSize: 16 * root.k; weight: Font.DemiBold } }
          Text { visible: row.detail.length > 0; width: parent.width; elide: Text.ElideRight; textFormat: Text.PlainText; text: row.detail; color: Util.alpha(root.fg, 0.65); font { family: root.fontFamily; pixelSize: 12 * root.k } }
        }
        MouseArea {
          id: area
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onPositionChanged: root.hoverSelect(row.index, mapToItem(root, mouseX, mouseY))
          onClicked: root.activated(row.index)
        }
      }
    }
    Text {
      visible: root.count === 0
      anchors.centerIn: list
      text: root.emptyText()
      color: Util.alpha(root.fg, 0.6)
      font { family: root.fontFamily; pixelSize: 14 * k }
    }

    Item {
      id: foot
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 22 * k }
      height: 20 * k
      Text { text: "↑↓ move  ·  Enter open  ·  Esc close"; color: Util.alpha(root.fg, 0.55); font { family: root.fontFamily; pixelSize: 12 * k } }
      Text { anchors.right: parent.right; text: root.count ? (root.selectedIndex + 1) + " / " + root.count : ""; color: Util.alpha(root.fg, 0.55); font { family: root.fontFamily; pixelSize: 12 * k } }
    }

    // retro: светлая кромка, красный язычок сверху, прорези-ручки снизу справа и винт слева
    Rectangle {
      visible: root.retro
      x: root.bw + 1; y: root.bw + 1
      width: parent.width - 2 * (root.bw + 1); height: 2; radius: 1
      color: Qt.rgba(1, 1, 1, 0.4)
    }
    Item {
      visible: root.retro
      x: 58 * k; y: -9 * k
      width: 78 * k; height: 24 * k
      Rectangle { x: 2; y: 3; width: parent.width; height: parent.height; radius: 5; color: Util.alpha(root.ink, 0.38) }
      Rectangle { anchors.fill: parent; radius: 5; color: Qt.darker(root.accent, 1.35) }
      Rectangle { width: parent.width; height: parent.height - 5 * k; radius: 5; color: root.accent }
      Rectangle { x: 6; y: 2; width: parent.width - 12; height: 2.2; radius: 1.1; color: Qt.rgba(1, 1, 1, 0.55) }
      Rectangle { anchors.fill: parent; radius: 5; color: "transparent"; border { width: 1.4; color: root.ink } }
    }
    Row {
      visible: root.retro
      anchors { right: parent.right; rightMargin: 20 * k; bottom: parent.bottom; bottomMargin: -4 * k }
      spacing: 9 * k
      Repeater {
        model: 8
        Rectangle {
          width: 6 * k; height: 22 * k; radius: 2
          color: root.ink
          Rectangle { width: 1.2; height: parent.height - 3; x: 0.6; y: 1; color: Qt.rgba(1, 1, 1, 0.45) }
        }
      }
    }
    Rectangle {
      visible: root.retro
      x: 12 * k; anchors { bottom: parent.bottom; bottomMargin: 10 * k }
      width: 7.2 * k; height: width; radius: width / 2
      color: Qt.darker(root.background, 1.25)
      border { width: 1; color: root.ink }
      Rectangle { anchors.centerIn: parent; width: 5 * k; height: 1.2; rotation: 35; color: root.ink }
    }

    // cyber: уголки-скобки со свечением, линейка рисок, «терминальный» код
    Repeater {
      model: root.cyber ? [[0, 0], [1, 0], [0, 1], [1, 1]] : []
      Shape {
        id: br
        required property var modelData
        readonly property int sx: modelData[0] ? 1 : -1
        readonly property int sy: modelData[1] ? 1 : -1
        x: modelData[0] ? card.width + 7 : -7
        y: modelData[1] ? card.height + 7 : -7
        width: 1; height: 1
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          strokeColor: Util.alpha(root.accent, 0.16); strokeWidth: 5; fillColor: "transparent"; capStyle: ShapePath.FlatCap
          PathMove { x: 0; y: -br.sy * 15 }
          PathLine { x: 0; y: 0 }
          PathLine { x: -br.sx * 15; y: 0 }
        }
        ShapePath {
          strokeColor: Qt.lighter(root.accent, 1.35); strokeWidth: 1.7; fillColor: "transparent"; capStyle: ShapePath.FlatCap
          PathMove { x: 0; y: -br.sy * 15 }
          PathLine { x: 0; y: 0 }
          PathLine { x: -br.sx * 15; y: 0 }
        }
      }
    }
    Repeater {
      model: root.cyber ? 14 : 0
      Rectangle {
        required property int index
        x: 22 + index * 6; y: card.height + 8
        width: 1.1; height: index % 4 === 0 ? 6 : 3
        color: root.accent; opacity: 0.7
      }
    }
    Row {
      visible: root.cyber
      anchors { right: parent.right; bottom: parent.bottom; rightMargin: 0; bottomMargin: -16 }
      spacing: 4
      Text {
        text: ["SYS 7F3A·9C21", "SYS A1E4·03BD", "SYS 5C90·E7F2"][root.tick % 3]
        color: Qt.lighter(root.accent, 1.35); opacity: 0.85
        font { family: root.mono; pixelSize: 10; weight: Font.Medium }
      }
      Rectangle { width: 5; height: 10; color: Qt.lighter(root.accent, 1.35); opacity: Math.floor(root.tick / 2) % 2 === 0 ? 0.9 : 0 }
    }
  }

  // украшения основ Vitreus (UwU — уши, усы, звёзды, сердечки, лапки; Cyber — скобки и код; Paper — скотч; Proxy — плиты;
  // Doodle — второй контур): тот же BaseDecor, что у панелей, на теле лаунчера; слитый край украшений не получает
  QtObject {
    id: decoCard
    readonly property var style: ({ base: root.base })
    readonly property string material: "liquid"
    readonly property bool decor: true
    readonly property var mergeEdges: root.drip ? root.mergeNow : []
    readonly property int seed: 41
    function merged(e) { return mergeEdges.indexOf(e) !== -1 }
  }
  BaseDecor {
    card: decoCard
    anchors.fill: undefined
    x: root.drip ? root.bodyRect.x : card.x
    y: root.drip ? root.bodyRect.y : card.y
    width: root.drip ? root.bodyRect.width : card.width
    height: root.drip ? root.bodyRect.height : card.height
    opacity: root.drip ? root.reveal : root.t
    z: 5
  }
}
