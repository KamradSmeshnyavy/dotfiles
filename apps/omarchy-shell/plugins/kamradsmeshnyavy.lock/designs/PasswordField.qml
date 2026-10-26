import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Поле пароля для всех дизайнов — логика ввода из стокового LockView.qml
// (маска, фокус, Esc / Ctrl+U, «Checking…», ошибка, значок отпечатка).
// Привязано к host (DesignBase): читает его состояние и шлёт его сигналы,
// поэтому дизайн только ставит поле на место и, если надо, меняет вид.
//
//   bare: true — без рамки и фона, только точки/подсказка (дизайн zen и т.п.)
BorderSurface {
  id: field

  required property Item host

  property int fieldWidth: 381
  property int fieldHeight: 67
  property int outlineThickness: 3
  property bool bare: false
  property real fieldRadius: Style.cornerRadius
  property color fill: Commons.Color.lock.background
  property color textColor: Commons.Color.lock.text
  property color placeholderColor: Commons.Color.lock.placeholder
  property string placeholderText: "Enter Password"
  property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  property int dotFontSize: Math.round(Style.font.heading * 1.33)
  property int dotLetterSpacing: Math.round(Style.font.heading * 0.19)
  property string fontFamily: Style.font.family
  property int textAlignment: TextInput.AlignHCenter
  property string maskCharacter: "\u25CF"

  readonly property bool errorState: host.failureMessage.length > 0
  readonly property bool showCursor: host.inputEnabled && !host.authenticatingPassword && !errorState
  readonly property real fingerprintReserve: host.fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  readonly property real dotScale: dotMetrics.advanceWidth > 0 ? Math.min(1, (input.width - 4) / dotMetrics.advanceWidth) : 1
  readonly property int length: input.text.length

  property bool syncing: false

  function forceFocus() { input.forceActiveFocus() }

  function syncText() {
    if (input.text === host.passwordText) return
    syncing = true
    input.text = host.passwordText
    syncing = false
  }

  Connections {
    target: field.host
    function onPasswordTextChanged() { field.syncText() }
    function onInputEnabledChanged() { if (field.host.inputEnabled) Qt.callLater(field.forceFocus) }
  }
  Component.onCompleted: {
    syncText()
    if (host.inputEnabled) Qt.callLater(forceFocus)
  }

  implicitWidth: fieldWidth
  implicitHeight: fieldHeight
  color: bare ? "transparent" : fill
  borderSpec: bare ? Border.flat("transparent", 0) : (errorState
    ? Border.surfaceSpec("lock", "border-error", Commons.Color.lock.borderError, outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Commons.Color.lock.borderActive, outlineThickness, "border-alpha"))
  radius: fieldRadius
  clip: true

  TextMetrics {
    id: dotMetrics
    font.family: field.fontFamily
    font.pixelSize: field.dotFontSize
    font.letterSpacing: field.dotLetterSpacing
    text: field.maskCharacter.repeat(input.text.length)
  }

  TextInput {
    id: input
    anchors.fill: parent
    anchors.topMargin: field.borderTop
    anchors.bottomMargin: field.borderBottom
    anchors.leftMargin: field.borderLeft + 18 + field.fingerprintReserve
    anchors.rightMargin: field.borderRight + 18 + field.fingerprintReserve
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: field.textAlignment
    activeFocusOnPress: true
    clip: true
    enabled: field.host.inputEnabled && !field.host.authenticatingPassword
    readOnly: field.host.authenticatingPassword
    echoMode: TextInput.Password
    passwordCharacter: field.maskCharacter
    passwordMaskDelay: 0
    color: field.textColor
    selectionColor: Commons.Color.lock.selection
    selectedTextColor: field.textColor
    font.family: field.fontFamily
    font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(field.dotFontSize * field.dotScale)) : field.fieldFontSize
    font.letterSpacing: text.length > 0 ? field.dotLetterSpacing * field.dotScale : 0
    cursorVisible: activeFocus && field.showCursor && text.length > 0
    cursorDelegate: Rectangle {
      width: 2
      color: field.textColor
      visible: input.cursorVisible
    }

    onTextChanged: {
      if (!field.syncing) field.host.passwordTextEdited(text)
      if (text.length > 0) field.host.wakeRequested()
      if (text.length > 0 && field.host.failureMessage.length > 0) field.host.clearFailureRequested()
    }

    onAccepted: {
      var submitted = field.host.passwordText
      field.host.passwordTextEdited("")
      if (submitted.length > 0) field.host.submitPassword(submitted)
    }

    Keys.onPressed: function(event) {
      field.host.wakeRequested()
      if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
        field.host.passwordTextEdited("")
        event.accepted = true
      }
    }
  }

  Text {
    textFormat: Text.PlainText
    anchors.fill: input
    text: field.host.authenticatingPassword ? "Checking…" : (field.errorState ? field.host.failureMessage : field.placeholderText)
    visible: input.text.length === 0
    color: field.host.authenticatingPassword ? field.textColor : (field.errorState ? Commons.Color.lock.textError : field.placeholderColor)
    font.family: field.fontFamily
    font.pixelSize: field.fieldFontSize
    font.italic: !field.host.authenticatingPassword && field.errorState
    horizontalAlignment: field.textAlignment === TextInput.AlignLeft ? Text.AlignLeft : Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
  }

  Text {
    id: fingerprintIcon
    anchors.right: parent.right
    anchors.rightMargin: field.borderRight + 18
    anchors.verticalCenter: parent.verticalCenter
    visible: field.host.fingerprintConfigured
    text: "󰈷"
    color: field.placeholderColor
    font.family: field.fontFamily
    font.pixelSize: Math.round(field.fieldFontSize * 1.1)
    verticalAlignment: Text.AlignVCenter
  }
}
