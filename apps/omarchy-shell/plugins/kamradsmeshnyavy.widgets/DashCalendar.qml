import QtQuick

// Дашборд: календарь месяца. Неделя начинается по локали, сегодня — кружок акцента,
// ‹ › листают месяцы (сброс к текущему при каждом открытии).
Rectangle {
  id: cal

  required property var host

  radius: 16
  color: Qt.rgba(host.foreground.r, host.foreground.g, host.foreground.b, 0.05)

  property int offset: 0
  Connections {
    target: cal.host
    function onDashboardOpenChanged() { if (cal.host.dashboardOpen) cal.offset = 0 }
  }

  readonly property date today: new Date()
  readonly property date month: new Date(today.getFullYear(), today.getMonth() + offset, 1)
  // Qt: firstDayOfWeek 1 = понедельник … 7 = воскресенье; в JS getDay() воскресенье = 0.
  readonly property int firstDay: host.locale.firstDayOfWeek % 7
  readonly property var cells: {
    var start = (month.getDay() - firstDay + 7) % 7
    var out = []
    for (var i = 0; i < 42; i++) out.push(new Date(month.getFullYear(), month.getMonth(), 1 - start + i))
    return out
  }

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 6

    Item {
      width: parent.width
      height: 24
      Text {
        anchors.centerIn: parent
        text: cal.host.locale.standaloneMonthName(cal.month.getMonth()) + " " + cal.month.getFullYear()
        font.family: cal.host.fontFamily
        font.pixelSize: 14
        font.weight: Font.Bold
        font.capitalization: Font.Capitalize
        color: cal.host.foreground
      }
      Repeater {
        model: [{ glyph: "‹", step: -1 }, { glyph: "›", step: 1 }]
        delegate: Text {
          required property var modelData
          x: modelData.step < 0 ? 4 : parent.width - width - 4
          anchors.verticalCenter: parent.verticalCenter
          text: modelData.glyph
          font.family: cal.host.fontFamily
          font.pixelSize: 20
          color: arrowHover.hovered ? cal.host.accent : cal.host.foreground
          HoverHandler { id: arrowHover; cursorShape: Qt.PointingHandCursor }
          TapHandler { onTapped: cal.offset += modelData.step }
        }
      }
    }

    Grid {
      columns: 7
      width: parent.width
      readonly property real cell: width / 7

      Repeater {
        model: 7
        delegate: Text {
          required property int index
          width: parent.cell
          horizontalAlignment: Text.AlignHCenter
          text: cal.host.locale.dayName((cal.firstDay + index) % 7, Locale.ShortFormat).slice(0, 2)
          font.family: cal.host.fontFamily
          font.pixelSize: 11
          color: cal.host.accent
          opacity: 0.8
        }
      }

      Repeater {
        model: cal.cells
        delegate: Item {
          required property var modelData
          readonly property bool inMonth: modelData.getMonth() === cal.month.getMonth()
          readonly property bool isToday: modelData.toDateString() === cal.today.toDateString()
          width: parent.cell
          height: 26
          Rectangle {
            anchors.centerIn: parent
            width: 24
            height: 24
            radius: 12
            color: parent.isToday ? cal.host.accent : "transparent"
          }
          Text {
            anchors.centerIn: parent
            text: modelData.getDate()
            font.family: cal.host.fontFamily
            font.pixelSize: 12
            font.weight: parent.isToday ? Font.Bold : Font.Normal
            color: parent.isToday ? cal.host.background : cal.host.foreground
            opacity: parent.inMonth ? 1 : 0.3
          }
        }
      }
    }
  }
}
