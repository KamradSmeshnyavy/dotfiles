import QtQuick

// Слева часы и ввод, справа сетка месяца с сегодняшним днём.
DesignBase {
  id: root
  field: pw

  Wallpaper { anchors.fill: parent; host: root; dim: Math.max(root.wallpaperDim, 0.2) }

  readonly property int year: now.getFullYear()
  readonly property int month: now.getMonth()
  readonly property int today: now.getDate()
  // Понедельник — первый день недели.
  readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7
  readonly property int days: new Date(year, month + 1, 0).getDate()

  Row {
    anchors.centerIn: parent
    spacing: 80

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 14
      Text {
        text: root.time
        color: root.fg
        font.family: root.font
        font.pixelSize: 90
        font.bold: true
      }
      Text {
        text: root.dateText
        color: root.accent
        font.family: root.font
        font.pixelSize: 18
      }
      Item { width: 1; height: 24 }
      PasswordField {
        id: pw
        host: root
        fieldWidth: 360
        fieldHeight: 54
        textAlignment: TextInput.AlignLeft
      }
    }

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: grid.width + 48
      height: title.height + grid.height + 72
      radius: 20
      color: root.withAlpha(root.bg, 0.82)
      border.width: 1
      border.color: root.withAlpha(root.fg, 0.1)

      Text {
        id: title
        anchors { top: parent.top; topMargin: 22; horizontalCenter: parent.horizontalCenter }
        text: Qt.locale().standaloneMonthName(root.month) + " " + root.year
        color: root.fg
        font.family: root.font
        font.pixelSize: 18
        font.bold: true
      }

      Grid {
        id: grid
        anchors { top: title.bottom; topMargin: 18; horizontalCenter: parent.horizontalCenter }
        columns: 7
        spacing: 4

        Repeater {
          model: 7
          delegate: Text {
            required property int index
            width: 40
            height: 28
            horizontalAlignment: Text.AlignHCenter
            text: Qt.locale().dayName((index + 1) % 7, Locale.ShortFormat)
            color: root.withAlpha(root.fg, 0.5)
            font.family: root.font
            font.pixelSize: 12
          }
        }
        Repeater {
          model: root.offset + root.days
          delegate: Rectangle {
            required property int index
            readonly property int day: index - root.offset + 1
            width: 40
            height: 36
            radius: 10
            color: day === root.today ? root.accent : "transparent"
            Text {
              anchors.centerIn: parent
              visible: parent.day > 0
              text: parent.day
              color: parent.day === root.today ? root.bg : root.fg
              font.family: root.font
              font.pixelSize: 14
              font.bold: parent.day === root.today
            }
          }
        }
      }
    }
  }
}
