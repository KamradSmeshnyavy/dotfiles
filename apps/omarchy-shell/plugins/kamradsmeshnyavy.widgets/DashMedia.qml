import QtQuick
import QtQuick.Effects

// Дашборд: плеер — обложка, трек, прогресс, кнопки и визуализатор cava снизу.
Rectangle {
  id: media

  required property var host
  readonly property var player: host.player

  radius: 16
  color: Qt.rgba(host.foreground.r, host.foreground.g, host.foreground.b, 0.05)

  readonly property real progress: player && player.lengthSupported && player.length > 0
    ? Math.max(0, Math.min(1, player.position / player.length)) : 0
  function clock(sec) {
    sec = Math.max(0, Math.floor(sec || 0))
    var m = Math.floor(sec / 60), s = sec % 60
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  Text {
    visible: media.player === null
    anchors.centerIn: parent
    text: "󰝛  " + media.host.tr("Nothing is playing", "Ничего не играет")
    font.family: media.host.fontFamily
    font.pixelSize: 15
    color: media.host.foreground
    opacity: 0.6
  }

  Item {
    visible: media.player !== null
    anchors.fill: parent
    anchors.margins: 14

    Item {
      id: cover
      width: 112
      height: 112

      Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(media.host.accent.r, media.host.accent.g, media.host.accent.b, 0.18)
        Text {
          anchors.centerIn: parent
          text: "󰎆"
          font.family: media.host.fontFamily
          font.pixelSize: 44
          color: media.host.accent
          visible: art.status !== Image.Ready
        }
      }
      Image {
        id: art
        anchors.fill: parent
        source: media.player ? media.player.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 224
        sourceSize.height: 224
        visible: false
      }
      Rectangle {
        id: artMask
        anchors.fill: parent
        radius: 12
        visible: false
        layer.enabled: true
      }
      MultiEffect {
        anchors.fill: parent
        source: art
        maskEnabled: true
        maskSource: artMask
        visible: art.status === Image.Ready
      }
    }

    Column {
      anchors { left: cover.right; leftMargin: 14; right: parent.right; top: parent.top; topMargin: 4 }
      spacing: 4
      Text {
        width: parent.width
        text: media.player ? media.player.trackTitle : ""
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.Wrap
        font.family: media.host.fontFamily
        font.pixelSize: 17
        font.weight: Font.Bold
        color: media.host.foreground
      }
      Text {
        width: parent.width
        text: media.player ? (media.player.trackArtist || media.player.identity) : ""
        elide: Text.ElideRight
        font.family: media.host.fontFamily
        font.pixelSize: 13
        color: media.host.foreground
        opacity: 0.7
      }
    }

    Row {
      anchors { left: cover.right; leftMargin: 8; top: cover.bottom; topMargin: -36 }
      spacing: 4
      Repeater {
        model: [
          { glyph: "󰒮", act: "previous", enabled: media.player && media.player.canGoPrevious },
          { glyph: media.host.playing ? "󰏤" : "󰐊", act: "toggle", enabled: media.player && media.player.canTogglePlaying },
          { glyph: "󰒭", act: "next", enabled: media.player && media.player.canGoNext }
        ]
        delegate: Rectangle {
          required property var modelData
          width: 38
          height: 32
          radius: 8
          color: hover.hovered ? Qt.rgba(media.host.accent.r, media.host.accent.g, media.host.accent.b, 0.2) : "transparent"
          opacity: modelData.enabled ? 1 : 0.35
          Text {
            anchors.centerIn: parent
            text: modelData.glyph
            font.family: media.host.fontFamily
            font.pixelSize: 22
            color: modelData.act === "toggle" ? media.host.accent : media.host.foreground
          }
          HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
          TapHandler {
            enabled: modelData.enabled
            onTapped: {
              if (!media.player) return
              if (modelData.act === "previous") media.player.previous()
              else if (modelData.act === "next") media.player.next()
              else media.player.togglePlaying()
            }
          }
        }
      }
    }

    // Прогресс с временем
    Item {
      id: bar
      anchors { left: parent.left; right: parent.right; top: cover.bottom; topMargin: 12 }
      height: 16
      Text {
        id: posText
        anchors.verticalCenter: parent.verticalCenter
        text: media.player ? media.clock(media.player.position) : ""
        font.family: media.host.fontFamily
        font.pixelSize: 11
        color: media.host.foreground
        opacity: 0.6
      }
      Text {
        id: lenText
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        text: media.player && media.player.lengthSupported ? media.clock(media.player.length) : ""
        font.family: media.host.fontFamily
        font.pixelSize: 11
        color: media.host.foreground
        opacity: 0.6
      }
      Rectangle {
        anchors { left: posText.right; leftMargin: 8; right: lenText.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
        height: 4
        radius: 2
        color: Qt.rgba(media.host.foreground.r, media.host.foreground.g, media.host.foreground.b, 0.15)
        Rectangle {
          width: parent.width * media.progress
          height: parent.height
          radius: 2
          color: media.host.accent
        }
      }
    }

    // Визуализатор: те же уровни cava, что у виджета на рабочем столе.
    Row {
      anchors { left: parent.left; right: parent.right; top: bar.bottom; topMargin: 8; bottom: parent.bottom }
      readonly property int count: Math.max(1, media.host.levels.length)
      readonly property real slot: width / count
      Repeater {
        model: media.host.levels.length
        delegate: Item {
          required property int index
          width: parent.slot
          height: parent.height
          Rectangle {
            width: Math.max(2, parent.width * 0.6)
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.max(2, (media.host.levels[index] || 0) * parent.height)
            y: parent.height - height
            radius: width / 2
            color: media.host.accent
            opacity: 0.75
            Behavior on height { NumberAnimation { duration: 60 } }
          }
        }
      }
    }
  }
}
