import QtQuick
import QtQuick.Shapes
import SddmComponents 2.0

// Экран входа SDDM (Qt6) темы DOT-MATRIX.
// Чёрная аппаратная рамка #000000 с контуром 1px #2a2a2a, матричные обои,
// часы Doto Bold, капсула пароля с круглыми LED-точками и красным #d71921 только при ошибке
// или двухшаговом подтверждении питания.
Rectangle {
  id: root
  width: 1920
  height: 1080
  color: "#000000"

  readonly property color cVoid: "#000000"
  readonly property color cSurface: "#0e0e0e"
  readonly property color cRaised: "#1a1a1a"
  readonly property color cLine: "#2a2a2a"
  readonly property color cMuted: "#5a5a5a"
  readonly property color cDim: "#8e8e8e"
  readonly property color cInk: "#f2f2f2"
  readonly property color cSignal: "#d71921"

  readonly property int bezelWidth: 8
  readonly property int bezelRadius: 20

  FontLoader { id: dotoLoader; source: "fonts/Doto.ttf" }
  FontLoader { id: groteskLoader; source: "fonts/SpaceGrotesk.ttf" }
  FontLoader { id: monoLoader; source: "fonts/SpaceMono-Regular.ttf" }

  readonly property string fontDot: dotoLoader.status === FontLoader.Ready ? dotoLoader.name : "Doto"
  readonly property string fontSans: groteskLoader.status === FontLoader.Ready ? groteskLoader.name : "Space Grotesk"
  readonly property string fontMono: monoLoader.status === FontLoader.Ready ? monoLoader.name : "Space Mono"

  property date now: new Date()
  property bool loginFailed: false
  property bool loggingIn: false
  property string armedAction: ""

  property int userIndex: (typeof userModel !== "undefined" && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
  readonly property int userCount: typeof userModel !== "undefined" ? userModel.rowCount() : 0
  readonly property string currentUser: {
    if (typeof userModel === "undefined") return "arch"
    if (userCount > 0 && userIndex >= 0 && userIndex < userCount) {
      var u = userModel.data(userModel.index(userIndex, 0), Qt.UserRole + 1)
      if (u) return u.toString()
    }
    return (userModel.lastUser || "").toString()
  }

  property int sessionIndex: {
    if (typeof sessionModel === "undefined") return 0
    for (var i = 0; i < sessionModel.rowCount(); i++) {
      var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString().toLowerCase()
      if (name.indexOf("uwsm") !== -1) return i
    }
    for (var j = 0; j < sessionModel.rowCount(); j++) {
      var hname = (sessionModel.data(sessionModel.index(j, 0), Qt.DisplayRole) || "").toString().toLowerCase()
      if (hname.indexOf("hyprland") !== -1) return j
    }
    return sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
  }
  readonly property int sessionCount: typeof sessionModel !== "undefined" ? sessionModel.rowCount() : 0
  readonly property string sessionName: {
    if (typeof sessionModel === "undefined" || sessionCount === 0) return "HYPRLAND"
    var s = sessionModel.data(sessionModel.index(sessionIndex, 0), Qt.DisplayRole)
    return (s ? s.toString() : "SESSION").toUpperCase()
  }

  readonly property int dotCount: Math.min(password.text.length, 28)
  readonly property real dotSize: dotCount > 18 ? 5 : (dotCount > 12 ? 6.5 : 8)
  readonly property real dotGap: dotCount > 18 ? 4 : (dotCount > 12 ? 6 : 8)

  readonly property string formattedDate: {
    var loc = Qt.locale()
    var day = loc.toString(root.now, "ddd").replace(/\./g, "")
    var num = Qt.formatDate(root.now, "dd")
    var mon = loc.toString(root.now, "MMM").replace(/\./g, "")
    return (day + " · " + num + " " + mon).toUpperCase()
  }

  function submitLogin() {
    if (password.text.length === 0 || root.loggingIn) return
    root.loggingIn = true
    root.loginFailed = false
    if (typeof sddm !== "undefined") {
      sddm.login(root.currentUser, password.text, root.sessionIndex)
    }
  }

  function triggerPower(kind) {
    if (root.armedAction !== kind) {
      root.armedAction = kind
      disarmTimer.restart()
      return
    }
    root.armedAction = ""
    if (typeof sddm === "undefined") return
    if (kind === "reboot") sddm.reboot()
    else if (kind === "poweroff") sddm.powerOff()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.now = new Date()
  }

  Timer {
    id: disarmTimer
    interval: 3000
    repeat: false
    onTriggered: root.armedAction = ""
  }

  Connections {
    target: typeof sddm !== "undefined" ? sddm : null
    function onLoginFailed() {
      root.loggingIn = false
      root.loginFailed = true
      password.text = ""
      password.forceActiveFocus()
    }
    function onLoginSucceeded() {
      root.loggingIn = false
      root.loginFailed = false
    }
  }

  Image {
    anchors.fill: parent
    source: (typeof config !== "undefined" && config.background) ? config.background : "background.png"
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
  }

  Rectangle {
    anchors.fill: parent
    color: root.cVoid
    opacity: (typeof config !== "undefined" && config.dim !== undefined) ? Number(config.dim) : 0.45
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      root.armedAction = ""
      password.forceActiveFocus()
    }
  }

  // Чёрная аппаратная рамка 8px со скруглёнными внутренними углами 20px и контуром 1px #2a2a2a.
  Shape {
    id: bezelShape
    anchors.fill: parent
    z: 10
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: root.cVoid
      fillRule: ShapePath.OddEvenFill
      strokeWidth: -1

      PathRectangle {
        x: 0
        y: 0
        width: bezelShape.width
        height: bezelShape.height
      }
      PathRectangle {
        x: root.bezelWidth
        y: root.bezelWidth
        width: Math.max(0, bezelShape.width - root.bezelWidth * 2)
        height: Math.max(0, bezelShape.height - root.bezelWidth * 2)
        radius: root.bezelRadius
      }
    }

    ShapePath {
      fillColor: "transparent"
      strokeColor: root.cLine
      strokeWidth: 1

      PathRectangle {
        x: root.bezelWidth - 0.5
        y: root.bezelWidth - 0.5
        width: Math.max(0, bezelShape.width - root.bezelWidth * 2 + 1)
        height: Math.max(0, bezelShape.height - root.bezelWidth * 2 + 1)
        radius: root.bezelRadius + 0.5
      }
    }
  }

  // Часы Doto Bold 128px.
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -160
    text: Qt.formatTime(root.now, "HH:mm")
    color: root.cInk
    font.family: root.fontDot
    font.weight: Font.Bold
    font.pixelSize: 128
    renderType: Text.NativeRendering
  }

  // Дата Space Mono.
  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -62
    text: root.formattedDate
    color: root.cDim
    font.family: root.fontMono
    font.pixelSize: 13
    font.letterSpacing: 2.0
  }

  // Пользователь (клик переключает, если в системе несколько учётных записей).
  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -14
    width: userLabel.implicitWidth + 28
    height: 26
    radius: 13
    color: userMouse.containsMouse && root.userCount > 1 ? root.cRaised : "transparent"
    border.width: root.userCount > 1 ? 1 : 0
    border.color: root.cLine

    Text {
      id: userLabel
      anchors.centerIn: parent
      text: root.currentUser.toUpperCase()
      color: root.cMuted
      font.family: root.fontMono
      font.pixelSize: 11
      font.letterSpacing: 2.2
    }

    MouseArea {
      id: userMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.userCount > 1
      onClicked: {
        root.userIndex = (root.userIndex + 1) % root.userCount
        password.forceActiveFocus()
      }
    }
  }

  // Капсула ввода пароля 280×46.
  Rectangle {
    id: pill
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 44
    width: 280
    height: 46
    radius: 23
    color: root.cVoid
    border.width: 1
    border.color: root.loggingIn
      ? root.cMuted
      : (root.loginFailed ? root.cSignal : (password.activeFocus ? root.cMuted : root.cLine))
    clip: true

    Behavior on border.color {
      ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Text {
      visible: password.text.length === 0
      anchors.fill: parent
      anchors.leftMargin: 20
      anchors.rightMargin: 20
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.loggingIn ? "CHECKING…" : (root.loginFailed ? "AUTH FAILED" : "PASSWORD")
      color: root.loggingIn ? root.cMuted : (root.loginFailed ? root.cSignal : root.cMuted)
      font.family: root.fontMono
      font.pixelSize: 11
      font.letterSpacing: 2.2
    }

    Row {
      visible: password.text.length > 0
      anchors.centerIn: parent
      spacing: root.dotGap

      Repeater {
        model: root.dotCount

        delegate: Rectangle {
          width: root.dotSize
          height: root.dotSize
          radius: root.dotSize / 2
          color: root.cInk
        }
      }
    }

    TextInput {
      id: password
      anchors.fill: parent
      anchors.leftMargin: 20
      anchors.rightMargin: 20
      verticalAlignment: TextInput.AlignVCenter
      horizontalAlignment: TextInput.AlignHCenter
      echoMode: TextInput.Password
      color: "transparent"
      selectionColor: "transparent"
      selectedTextColor: "transparent"
      cursorDelegate: Item {}
      focus: true
      enabled: !root.loggingIn

      onTextChanged: {
        if (text.length > 0 && root.loginFailed) root.loginFailed = false
      }

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          root.submitLogin()
          event.accepted = true
        } else if (event.key === Qt.Key_Escape || ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_U)) {
          password.text = ""
          event.accepted = true
        }
      }
    }
  }

  // Нижняя строка: выбор сессии слева, девиз по центру, кнопки питания справа.
  Rectangle {
    visible: root.sessionCount > 0
    anchors.left: parent.left
    anchors.leftMargin: 32
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 32
    width: sessText.implicitWidth + 28
    height: 30
    radius: 15
    color: sessMouse.containsMouse ? root.cRaised : root.cVoid
    border.width: 1
    border.color: root.cLine

    Text {
      id: sessText
      anchors.centerIn: parent
      text: root.sessionName
      color: root.cDim
      font.family: root.fontMono
      font.pixelSize: 10
      font.letterSpacing: 1.6
    }

    MouseArea {
      id: sessMouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: root.sessionCount > 1
      onClicked: {
        root.sessionIndex = (root.sessionIndex + 1) % root.sessionCount
        password.forceActiveFocus()
      }
    }
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    text: (typeof config !== "undefined" && config.motto) ? config.motto : "ex nihilo"
    color: root.cMuted
    opacity: 0.55
    font.family: root.fontMono
    font.pixelSize: 10
    font.letterSpacing: 5.5
  }

  Row {
    anchors.right: parent.right
    anchors.rightMargin: 32
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 30
    spacing: 10

    Repeater {
      model: [
        { id: "reboot", label: "R", title: "REBOOT" },
        { id: "poweroff", label: "P", title: "POWER OFF" }
      ]

      delegate: Rectangle {
        required property var modelData
        readonly property bool armed: root.armedAction === modelData.id
        width: armed ? btnLabel.implicitWidth + 24 : 32
        height: 32
        radius: 16
        color: armed ? root.cSignal : (pwrMouse.containsMouse ? root.cRaised : root.cVoid)
        border.width: 1
        border.color: armed ? root.cSignal : root.cLine

        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Text {
          id: btnLabel
          anchors.centerIn: parent
          text: parent.armed ? (parent.modelData.title + "?") : parent.modelData.label
          color: parent.armed ? root.cInk : root.cMuted
          font.family: root.fontMono
          font.pixelSize: 10
          font.letterSpacing: 1.4
        }

        MouseArea {
          id: pwrMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.triggerPower(parent.modelData.id)
        }
      }
    }
  }

  Component.onCompleted: password.forceActiveFocus()
}
