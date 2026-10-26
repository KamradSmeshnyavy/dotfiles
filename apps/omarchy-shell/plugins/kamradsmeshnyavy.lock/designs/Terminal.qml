import QtQuick
import Quickshell.Io

// Вход как в консоли: баннер, login и Password со звёздочками.
DesignBase {
  id: root
  field: pw

  property string host_: "localhost"
  property string kernel: ""
  FileView { path: "/proc/sys/kernel/hostname"; onLoaded: root.host_ = text().trim() }
  FileView { path: "/proc/sys/kernel/osrelease"; onLoaded: root.kernel = text().trim() }

  Rectangle { anchors.fill: parent; color: "#0b0b0b" }

  Column {
    anchors { left: parent.left; top: parent.top; margins: 48 }
    spacing: 6

    Repeater {
      model: [
        "Omarchy Linux " + root.kernel + " (tty1)",
        "",
        root.dateText + "  " + root.time,
        "",
        root.host_ + " login: " + root.userName
      ]
      delegate: Text {
        required property string modelData
        text: modelData || " "
        color: "#d0d0d0"
        font.family: root.font
        font.pixelSize: 20
      }
    }

    Row {
      spacing: 0
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "Password: "
        color: "#d0d0d0"
        font.family: root.font
        font.pixelSize: 20
      }
      PasswordField {
        id: pw
        host: root
        anchors.verticalCenter: parent.verticalCenter
        bare: true
        fieldWidth: 520
        fieldHeight: 30
        fieldFontSize: 20
        dotFontSize: 20
        dotLetterSpacing: 0
        maskCharacter: "*"
        textAlignment: TextInput.AlignLeft
        textColor: "#d0d0d0"
        placeholderColor: "#d0d0d0"
        placeholderText: root.authenticatingPassword ? "" : "▌"
      }
    }

    Text {
      visible: root.failedAttempts > 0
      text: "Login incorrect"
      color: "#ff6b6b"
      font.family: root.font
      font.pixelSize: 20
    }
  }
}
