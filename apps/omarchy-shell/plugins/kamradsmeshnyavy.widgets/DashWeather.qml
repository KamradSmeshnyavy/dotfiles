import QtQuick

// Дашборд: погода сейчас (open-meteo через Widgets.qml). Без города — подсказка, где его задать.
Rectangle {
  id: wx

  required property var host
  readonly property var w: host.weather

  radius: 16
  color: Qt.rgba(host.foreground.r, host.foreground.g, host.foreground.b, 0.05)

  // Коды WMO → значок Nerd Font и подпись.
  function describe(code) {
    var table = [
      [[0], "󰖙", "Clear", "Ясно"], [[1, 2], "󰖕", "Partly cloudy", "Переменная облачность"],
      [[3], "󰖐", "Overcast", "Пасмурно"], [[45, 48], "󰖑", "Fog", "Туман"],
      [[51, 53, 55, 56, 57], "󰖗", "Drizzle", "Морось"], [[61, 63, 65, 66, 67, 80, 81, 82], "󰖖", "Rain", "Дождь"],
      [[71, 73, 75, 77, 85, 86], "󰖘", "Snow", "Снег"], [[95, 96, 99], "󰖓", "Thunderstorm", "Гроза"]
    ]
    for (var i = 0; i < table.length; i++)
      if (table[i][0].indexOf(code) !== -1) return { glyph: table[i][1], text: host.tr(table[i][2], table[i][3]) }
    return { glyph: "󰖐", text: "" }
  }
  readonly property string unit: String(host.value("weatherUnits")) === "fahrenheit" ? "°F" : "°"

  Text {
    visible: !wx.w || wx.w.error !== undefined
    anchors.fill: parent
    anchors.margins: 14
    wrapMode: Text.Wrap
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    text: wx.w && wx.w.error ? "󰖪  " + wx.w.error
      : "󰖐  " + wx.host.tr("Set a city: Customizer → Widgets → Dashboard: weather city", "Задай город: Customizer → Виджеты → Дашборд: город")
    font.family: wx.host.fontFamily
    font.pixelSize: 12
    color: wx.host.foreground
    opacity: 0.65
  }

  Row {
    visible: wx.w !== null && wx.w.error === undefined
    anchors.fill: parent
    anchors.margins: 14
    spacing: 14

    Text {
      id: wxIcon
      anchors.verticalCenter: parent.verticalCenter
      text: wx.w ? wx.describe(wx.w.code).glyph : ""
      font.family: wx.host.fontFamily
      font.pixelSize: 52
      color: wx.host.accent
    }
    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - wxIcon.width - parent.spacing
      spacing: 1
      Text {
        text: wx.w ? Math.round(wx.w.temp) + wx.unit : ""
        font.family: wx.host.fontFamily
        font.pixelSize: 30
        font.weight: Font.Bold
        color: wx.host.foreground
      }
      Text {
        width: parent.width
        text: wx.w ? wx.describe(wx.w.code).text + " · " + wx.w.city : ""
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        font.family: wx.host.fontFamily
        font.pixelSize: 11
        color: wx.host.foreground
        opacity: 0.75
      }
      Text {
        text: wx.w ? "↑" + Math.round(wx.w.max) + wx.unit + "  ↓" + Math.round(wx.w.min) + wx.unit + "  󰖝 " + Math.round(wx.w.wind) : ""
        font.family: wx.host.fontFamily
        font.pixelSize: 11
        color: wx.host.foreground
        opacity: 0.6
      }
    }
  }
}
