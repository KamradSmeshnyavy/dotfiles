import QtQuick
import qs.Commons

// "Vaporwave" from bjarneo/omarchy-quickapps: a sunset sky, a banded retro
// sun, a perspective floor grid and a neon halo that travels to the selected
// card. The sunset runs from the theme background through its magenta, red
// and orange; the halo is its cyan and yellow.
SkinBase {
  id: root

  launchDelay: 0

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property color hotPink: root.theme ? root.theme.magenta : "#ff71ce"
  readonly property color cyan: root.theme ? root.theme.cyan : "#01cdfe"
  readonly property color lemon: root.theme ? root.theme.yellow : "#fff392"
  readonly property color violet: root.theme ? root.theme.blue : "#b967ff"
  readonly property color white: root.theme ? root.theme.bright : "#ffffff"
  readonly property color night: root.theme ? root.theme.mix(root.background, root.hotPink, 0.18) : "#2a0944"
  readonly property string serif: "serif"

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Rectangle {
    anchors.fill: parent
    opacity: Math.min(0.95, root.backdrop)
    gradient: Gradient {
      GradientStop { position: 0.0; color: root.night }
      GradientStop { position: 0.45; color: root.theme ? root.theme.mix(root.hotPink, root.background, 0.35) : "#a91079" }
      GradientStop { position: 0.65; color: root.theme ? root.theme.mix(root.theme.red, root.background, 0.2) : "#ff5470" }
      GradientStop { position: 1.0; color: root.theme ? root.theme.mix(root.theme.orange, root.background, 0.15) : "#feae51" }
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.backRequested()
      else root.dismissRequested()
    }
    onWheel: function(wheel) { root.wheelStep(wheel) }
  }

  // Sun with bands across its lower half.
  Item {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 40 * u
    width: 560 * u; height: 560 * u
    clip: true
    Rectangle {
      anchors.centerIn: parent
      width: 540 * u; height: 540 * u; radius: 270 * u
      gradient: Gradient {
        GradientStop { position: 0.0; color: root.lemon }
        GradientStop { position: 0.55; color: root.hotPink }
        GradientStop { position: 1.0; color: root.violet }
      }
    }
    Repeater {
      model: 9
      delegate: Rectangle {
        required property int index
        width: 540 * u
        height: 6 * u
        color: root.night
        anchors.horizontalCenter: parent.horizontalCenter
        y: (320 + index * 22) * u
        opacity: 0.85
      }
    }
  }

  // Floor grid.
  Canvas {
    anchors.fill: parent
    property color line: root.hotPink
    onLineChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      if (!root.theme) return
      ctx.strokeStyle = root.theme.rgba(root.theme.mix(root.hotPink, root.white, 0.2), 0.85)
      ctx.lineWidth = 1.2
      var horizon = height * 0.62
      for (var i = -16; i <= 16; ++i) {
        var x = width / 2 + (i * width / 12)
        ctx.beginPath(); ctx.moveTo(x, height); ctx.lineTo(width / 2, horizon); ctx.stroke()
      }
      for (var r = 0; r < 12; ++r) {
        var t = Math.pow(r / 12, 2.6)
        var y = horizon + t * (height - horizon)
        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
      }
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 60 * u
    spacing: 4 * u
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "ＡＥＳＴＨＥＴＩＣＳ"
      color: root.white
      font.family: root.serif; font.pixelSize: 42 * u; font.letterSpacing: 12; font.italic: true; font.weight: Font.Bold
      style: Text.Outline; styleColor: root.hotPink
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.query.length > 0 ? "～ " + root.query + " ～"
        : "～ " + (root.title === "Omarchy" ? "select your program" : root.title.toLowerCase()) + (root.pages > 1 ? " · " + (root.page + 1) + "/" + root.pages : "") + " ～"
      color: root.white
      font.family: root.serif; font.pixelSize: 14 * u; font.italic: true; font.letterSpacing: 4
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 880 * u; height: 880 * u

    Column {
      anchors.centerIn: parent
      spacing: 6 * u
      width: 400 * u
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.label : root.emptyText()
        color: root.white
        style: Text.Outline; styleColor: root.hotPink
        font.family: root.serif; font.pixelSize: 30 * u; font.italic: true; font.letterSpacing: 6; font.weight: Font.Bold
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.current ? root.current.detail : ""
        color: root.cyan
        font.family: root.mono; font.pixelSize: 11 * u; font.letterSpacing: 2
      }
    }

    // The halo travels to the focused card; drawn first so cards sit on it.
    Item {
      id: selector
      width: 132 * u; height: 132 * u
      readonly property real angle: root.angleFor(Math.max(0, root.selectedIndex - root.pageStart))
      x: stage.width / 2 - width / 2 + Math.cos(angle) * 290 * u
      y: stage.height / 2 - 66 * u + Math.sin(angle) * 290 * u
      Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
      Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
      visible: root.count > 0 && root.cursorActive

      Rectangle { anchors.centerIn: parent; width: 128 * u; height: 128 * u; radius: 14 * u; color: "transparent"; border.color: root.cyan; border.width: 3 }
      Rectangle { anchors.centerIn: parent; width: 122 * u; height: 122 * u; radius: 12 * u; color: "transparent"; border.color: root.hotPink; border.width: 1.5; opacity: 0.85 }
      Rectangle {
        anchors.centerIn: parent
        width: 140 * u; height: width; radius: 16 * u
        color: "transparent"
        border.color: root.lemon; border.width: 1
        opacity: 0.7
        SequentialAnimation on width {
          loops: Animation.Infinite
          running: root.live
          NumberAnimation { from: 132 * root.u; to: 160 * root.u; duration: 1100; easing.type: Easing.OutQuad }
          NumberAnimation { from: 160 * root.u; to: 132 * root.u; duration: 1100; easing.type: Easing.InQuad }
        }
      }
      Repeater {
        model: 4
        delegate: Item {
          required property int index
          width: 10 * u; height: 10 * u
          x: index % 2 ? selector.width - width - 2 : 2
          y: index < 2 ? 2 : selector.height - height - 2
          Rectangle { width: 10 * u; height: 2; color: root.lemon; y: index < 2 ? 0 : 8 * u }
          Rectangle { width: 2; height: 10 * u; color: root.lemon; x: index % 2 ? 8 * u : 0 }
        }
      }
    }

    Repeater {
      model: root.rowModel

      delegate: Item {
        id: tile

        required property int index
        required property string kind
        required property string icon
        required property string iconFont
        required property string appIcon
        required property string label

        readonly property int slot: tile.index - root.pageStart
        readonly property bool onPage: slot >= 0 && slot < root.pageCount
        readonly property bool focusedTile: root.cursorActive && tile.index === root.selectedIndex
        readonly property real angle: root.angleFor(Math.max(0, tile.slot))

        visible: tile.onPage
        width: 116 * u; height: 132 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 290 * u
        y: stage.height / 2 - 66 * u + Math.sin(angle) * 290 * u
        Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.12 : 1.0
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Rectangle {
          id: card
          anchors.horizontalCenter: parent.horizontalCenter
          width: 100 * u; height: 100 * u
          radius: 8 * u
          color: tile.focusedTile ? (root.theme ? root.theme.mix(root.white, root.hotPink, 0.06) : "#fff5fb") : Util.alpha(root.white, 0.12)
          border.color: tile.focusedTile ? root.hotPink : Util.alpha(root.white, 0.35)
          border.width: tile.focusedTile ? 0 : 1
          Behavior on color { ColorAnimation { duration: 180 } }
        }
        RowIcon {
          anchors.centerIn: card
          size: 52 * u
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0)
          color: tile.focusedTile ? root.theme ? root.theme.mix(root.hotPink, "#000000", 0.25) : root.violet : root.white
        }
        Text {
          anchors.horizontalCenter: card.horizontalCenter
          anchors.top: card.bottom; anchors.topMargin: 8 * u
          width: 140 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label
          color: root.white
          style: Text.Outline; styleColor: tile.focusedTile ? root.hotPink : root.night
          font.family: root.serif; font.pixelSize: 11 * u; font.italic: true; font.letterSpacing: 2; font.weight: Font.Bold
        }
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.selectRequested(tile.index)
          onClicked: root.activated(tile.index)
        }
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom; anchors.bottomMargin: 40 * u
    text: "◄ ►  cycle    ↵  launch    ⌫  back    ESC  exit"
    color: root.white
    font.family: root.mono; font.pixelSize: 12 * u; font.letterSpacing: 3
    style: Text.Outline; styleColor: root.hotPink
  }
}
