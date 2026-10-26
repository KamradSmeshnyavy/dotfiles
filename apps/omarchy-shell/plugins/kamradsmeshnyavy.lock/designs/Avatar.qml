import QtQuick
import QtQuick.Effects

// Круглый аватар: настройка avatar или ~/.face; нет картинки — первая буква имени.
Item {
  id: av

  required property Item host
  property int size: 96

  width: size
  height: size

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    color: av.host.withAlpha(av.host.accent, 0.25)
    border.width: 2
    border.color: av.host.accent
    visible: image.status !== Image.Ready
    Text {
      anchors.centerIn: parent
      text: av.host.userName.charAt(0).toUpperCase()
      color: av.host.fg
      font.family: av.host.font
      font.pixelSize: av.size * 0.42
      font.bold: true
    }
  }

  Image {
    id: image
    anchors.fill: parent
    source: "file://" + av.host.avatarPath
    sourceSize.width: av.size * 2
    sourceSize.height: av.size * 2
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    visible: false
  }

  Rectangle {
    id: mask
    anchors.fill: parent
    radius: width / 2
    visible: false
    layer.enabled: true
  }

  MultiEffect {
    anchors.fill: parent
    source: image
    visible: image.status === Image.Ready
    maskEnabled: true
    maskSource: mask
  }

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    color: "transparent"
    border.width: 2
    border.color: av.host.accent
    visible: image.status === Image.Ready
  }
}
