import QtQuick
import QtQuick.Effects
import qs.Commons as Commons

// Обои темы с блюром и затемнением из настроек (wallpaperBlur / wallpaperDim).
// Как в стоковом LockView: ?v=<версия> заставляет перечитать сменившийся фон.
Item {
  id: wp

  required property Item host
  property real blur: host.wallpaperBlur
  property real dim: host.wallpaperDim

  function fileUrl(path) {
    if (!path) return ""
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/") + "?v=" + host.backgroundVersion
  }

  Rectangle { anchors.fill: parent; color: Commons.Color.background }

  Image {
    id: image
    anchors.fill: parent
    source: wp.host.loadBackground ? wp.fileUrl(wp.host.backgroundPath) : ""
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: false
    sourceSize.width: width
    sourceSize.height: height
    visible: wp.blur <= 0
  }

  MultiEffect {
    anchors.fill: image
    source: image
    visible: wp.blur > 0
    autoPaddingEnabled: false
    blurEnabled: wp.host.loadBackground && image.status === Image.Ready
    blur: Math.max(0, Math.min(1, wp.blur))
    blurMax: 128
    blurMultiplier: 1.25
    contrast: -0.08
  }

  Rectangle {
    anchors.fill: parent
    color: "#000000"
    opacity: Math.max(0, Math.min(0.9, wp.dim))
  }
}
