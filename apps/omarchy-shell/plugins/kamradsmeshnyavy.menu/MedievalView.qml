import QtQuick
import qs.Commons

// "Medieval" from bjarneo/omarchy-quickapps: a parchment codex with a gilt
// double border, rows as wax seals around a huge illuminated dropcap. The
// parchment is the theme background warmed with its yellow, the ink its
// foreground, the wax its red and the gilt its yellow dulled with brown.
SkinBase {
  id: root

  launchDelay: 0

  readonly property int ringMax: 12
  readonly property int page: Math.floor(Math.max(0, root.selectedIndex) / root.ringMax)
  readonly property int pages: Math.max(1, Math.ceil(root.count / root.ringMax))
  readonly property int pageStart: root.page * root.ringMax
  readonly property int pageCount: Math.max(0, Math.min(root.ringMax, root.count - root.pageStart))

  readonly property color parchment: root.theme ? root.theme.mix(root.background, root.theme.yellow, 0.08) : "#f4ecd2"
  readonly property color ink: root.foreground
  readonly property color wax: root.theme ? root.theme.red : "#9b1b1b"
  readonly property color gilt: root.theme ? root.theme.mix(root.theme.yellow, root.theme.brown, 0.35) : "#a07823"
  readonly property color sealDark: root.theme ? root.theme.mix(root.parchment, root.ink, 0.12) : "#2a1f10"
  readonly property string serif: "serif"

  function angleFor(slot) {
    return root.pageCount ? (2 * Math.PI * slot) / root.pageCount - Math.PI / 2 : -Math.PI / 2
  }

  function navigate(dx, dy) {
    root.step(dx !== 0 ? dx : dy)
  }

  Rectangle {
    anchors.fill: parent
    color: root.theme ? root.theme.mix(root.background, "#000000", 0.55) : "#1a1207"
    opacity: Math.min(0.98, root.backdrop)
  }

  Rectangle {
    anchors.centerIn: parent
    width: parent.width - 100 * u
    height: parent.height - 100 * u
    color: root.parchment

    Canvas {
      anchors.fill: parent
      property color grain: root.ink
      onGrainChanged: requestPaint()
      onWidthChanged: requestPaint()
      function rnd(i) { var x = Math.sin(i * 12.9898) * 43758.5453; return x - Math.floor(x) }
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var th = root.theme
        if (!th) return
        for (var i = 0; i < 1200; ++i) {
          ctx.fillStyle = th.rgba(root.ink, rnd(i * 4) * 0.06)
          var r = 0.5 + rnd(i * 4 + 1) * 1.5
          ctx.fillRect(rnd(i * 4 + 2) * width, rnd(i * 4 + 3) * height, r, r)
        }
        var grad = ctx.createRadialGradient(width / 2, height / 2, Math.min(width, height) * 0.3, width / 2, height / 2, Math.max(width, height) * 0.7)
        grad.addColorStop(0, th.rgba(th.mix(root.parchment, "#000000", 0.5), 0))
        grad.addColorStop(1, th.rgba(th.mix(root.parchment, "#000000", 0.5), 0.25))
        ctx.fillStyle = grad
        ctx.fillRect(0, 0, width, height)
      }
    }

    Rectangle { anchors.fill: parent; anchors.margins: 18 * u; color: "transparent"; border.color: root.gilt; border.width: 2 }
    Rectangle { anchors.fill: parent; anchors.margins: 24 * u; color: "transparent"; border.color: root.ink; border.width: 1 }

    Repeater {
      model: 4
      delegate: Item {
        required property int index
        width: 30 * u; height: 30 * u
        x: index % 2 === 0 ? 32 * u : parent.width - width - 32 * u
        y: index < 2 ? 32 * u : parent.height - height - 32 * u
        Rectangle { anchors.centerIn: parent; width: 18 * u; height: 18 * u; color: root.gilt; rotation: 45 }
        Rectangle { anchors.centerIn: parent; width: 8 * u; height: 8 * u; color: root.wax; rotation: 45 }
      }
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

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top; anchors.topMargin: 110 * u
    spacing: 4 * u
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.title === "Omarchy" ? "𝕮𝖔𝖉𝖊𝖝 𝖔𝖋 𝕬𝖕𝖕𝖑𝖎𝖈𝖆𝖙𝖎𝖔𝖓𝖘" : "𝕭𝖔𝖔𝖐 𝖔𝖋 " + root.title
      color: root.ink
      font.family: root.serif; font.pixelSize: 38 * u; font.weight: Font.Bold
    }
    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 280 * u; height: 1; color: root.gilt }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.query.length > 0 ? "wherein the user seeketh “" + root.query + "”"
        : (root.pages > 1 ? "folio " + (root.page + 1) + " of " + root.pages + ", wherein the noble user selecteth a programme" : "wherein the noble user selecteth a programme")
      color: root.ink
      opacity: 0.65
      font.family: root.serif; font.pixelSize: 13 * u; font.italic: true; font.letterSpacing: 1
    }
  }

  Item {
    id: stage
    anchors.centerIn: parent
    width: 780 * u; height: 780 * u

    Text {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: -10 * u
      textFormat: Text.PlainText
      text: root.current ? root.current.label.charAt(0).toUpperCase() : "—"
      color: root.wax
      style: Text.Outline; styleColor: root.gilt
      font.family: root.serif; font.pixelSize: 140 * u; font.weight: Font.Bold
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 70 * u
      width: 380 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? root.current.label : "—"
      color: root.ink
      font.family: root.serif; font.pixelSize: 22 * u; font.letterSpacing: 6; font.weight: Font.Bold
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: 102 * u
      width: 380 * u
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      textFormat: Text.PlainText
      text: root.current ? (root.current.detail ? "by incantation:  " + root.current.detail : "") : "no such scroll in this codex"
      color: root.ink
      opacity: 0.6
      font.family: root.serif; font.pixelSize: 12 * u; font.italic: true; font.letterSpacing: 1
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
        width: 92 * u; height: 122 * u
        x: stage.width / 2 - width / 2 + Math.cos(angle) * 290 * u
        y: stage.height / 2 - 44 * u + Math.sin(angle) * 290 * u
        Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        scale: tile.focusedTile ? 1.14 : 1.0
        Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }

        Rectangle {
          id: seal
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          width: 88 * u; height: 88 * u; radius: 44 * u
          color: tile.focusedTile ? root.wax : root.sealDark
          border.color: tile.focusedTile ? (root.theme ? root.theme.mix(root.wax, "#000000", 0.45) : "#5a0a0a") : root.gilt
          border.width: tile.focusedTile ? 3 : 1.5
          Rectangle {
            anchors.centerIn: parent
            width: parent.width - 12 * root.u; height: width; radius: width / 2
            color: "transparent"
            border.color: tile.focusedTile ? Util.alpha("#ffffff", 0.35) : root.gilt
            border.width: 1
          }
        }
        RowIcon {
          anchors.centerIn: seal
          size: 44 * u
          opacity: 0.9
          kind: tile.kind
          glyph: tile.icon
          glyphFont: tile.iconFont
          appIcon: tile.appIcon
          resolver: root.iconResolver
          fontFamily: root.fontFamily
          load: tile.onPage
          fallback: tile.label.charAt(0)
          color: tile.focusedTile ? (root.theme ? root.theme.mix(root.theme.yellow, "#ffffff", 0.5) : "#f4d8a4") : root.gilt
        }
        Text {
          anchors.horizontalCenter: seal.horizontalCenter
          anchors.top: seal.bottom; anchors.topMargin: 6 * u
          width: 130 * u
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          textFormat: Text.PlainText
          text: tile.label.toLowerCase()
          color: tile.focusedTile ? root.wax : root.ink
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
    anchors.bottom: parent.bottom; anchors.bottomMargin: 90 * u
    text: "❦  press enter to invoke · backspace to turn back  ❦"
    color: root.ink
    opacity: 0.55
    font.family: root.serif; font.pixelSize: 14 * u; font.italic: true; font.letterSpacing: 4
  }
}
