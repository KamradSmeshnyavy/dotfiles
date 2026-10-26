import QtQuick
import Quickshell.Services.Mpris

// Что играет сейчас (MPRIS): обложка, название, кнопки; ниже — ввод.
DesignBase {
  id: root
  field: pw

  readonly property var player: {
    var list = Mpris.players.values
    for (var i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i]
    return list.length > 0 ? list[0] : null
  }

  Wallpaper { anchors.fill: parent; host: root }

  Column {
    anchors.centerIn: parent
    spacing: 28

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.time
      color: root.fg
      font.family: root.font
      font.pixelSize: 72
      font.weight: Font.Light
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 520
      height: 150
      radius: 20
      color: root.withAlpha(root.bg, 0.85)
      border.width: 1
      border.color: root.withAlpha(root.fg, 0.1)

      Rectangle {
        id: art
        anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
        width: 114
        height: 114
        radius: 12
        color: root.withAlpha(root.accent, 0.2)
        clip: true
        Text {
          anchors.centerIn: parent
          visible: cover.status !== Image.Ready
          text: "󰎆"
          color: root.accent
          font.family: root.font
          font.pixelSize: 44
        }
        Image {
          id: cover
          anchors.fill: parent
          source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
        }
      }

      Column {
        anchors { left: art.right; leftMargin: 20; right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
        spacing: 8
        Text {
          width: parent.width
          elide: Text.ElideRight
          text: root.player ? (root.player.trackTitle || "Без названия") : "Ничего не играет"
          color: root.fg
          font.family: root.font
          font.pixelSize: 18
          font.bold: true
        }
        Text {
          width: parent.width
          elide: Text.ElideRight
          text: root.player ? (root.player.trackArtist || root.player.identity || "") : ""
          color: root.withAlpha(root.fg, 0.65)
          font.family: root.font
          font.pixelSize: 14
        }
        Row {
          spacing: 22
          visible: root.player !== null && !root.preview
          Repeater {
            model: [
              { glyph: "󰒮", act: "previous" },
              { glyph: root.player && root.player.isPlaying ? "󰏤" : "󰐊", act: "toggle" },
              { glyph: "󰒭", act: "next" }
            ]
            delegate: Text {
              required property var modelData
              text: modelData.glyph
              color: root.accent
              font.family: root.font
              font.pixelSize: 26
              MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                onClicked: {
                  var p = root.player
                  if (!p) return
                  if (parent.modelData.act === "toggle") p.togglePlaying()
                  else if (parent.modelData.act === "next") p.next()
                  else p.previous()
                  root.forcePasswordFocus()
                }
              }
            }
          }
        }
      }
    }

    PasswordField {
      id: pw
      host: root
      anchors.horizontalCenter: parent.horizontalCenter
      fieldWidth: 380
      fieldHeight: 56
    }
  }
}
