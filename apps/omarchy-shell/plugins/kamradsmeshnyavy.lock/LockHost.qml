import QtQuick
import Quickshell
import Quickshell.Io

// design: подставляет выбранный дизайн экрана блокировки вместо стокового
// LockView. Интерфейс (свойства и сигналы) — как у LockView, Service.qml
// работает с хостом так же, как раньше; пароль и PAM дизайн не видит,
// он только шлёт введённый текст через submitPassword.
//
// Выбор — ~/.config/omarchy/lock-design.json ({ "design": "<id>", …настройки });
// реестр — designs/designs.json; свои дизайны — ~/.config/omarchy/lock-designs/<Файл>.qml
// с id "my:<Файл>.qml". Дизайн не загрузился или в нём нет поля пароля —
// показывается стоковый LockView: экран без ввода пароля не остаётся.
Item {
  id: host

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  // Превью конкретного дизайна (IPC previewDesign) поверх выбранного.
  property string designOverride: ""
  property bool preview: false

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  readonly property string home: Quickshell.env("HOME")
  readonly property string userDir: home + "/.config/omarchy/lock-designs"
  readonly property string designsDir: decodeURIComponent(String(Qt.resolvedUrl("designs")).replace(/^file:\/\//, ""))

  property var config: ({})
  property var registry: []

  readonly property string designId: designOverride || String(config.design || "classic")
  readonly property string designSource: {
    var id = host.designId
    if (id === "classic") return ""
    if (id.indexOf("my:") === 0) {
      var name = id.slice(3)
      if (!/^[A-Za-z0-9_. -]+\.qml$/.test(name)) return ""
      return "file://" + host.userDir + "/" + name
    }
    for (var i = 0; i < host.registry.length; i++) {
      var d = host.registry[i]
      if (d.id === id && d.file) return "file://" + host.designsDir + "/" + d.file
    }
    return ""
  }

  function forcePasswordFocus() {
    var item = host.activeItem
    if (item && typeof item.forcePasswordFocus === "function") item.forcePasswordFocus()
  }

  FileView {
    path: host.home + "/.config/omarchy/lock-design.json"
    // Синхронно: иначе экран блокировки на миг покажет сток, пока читается файл.
    blockLoading: true
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var v = JSON.parse(text())
        host.config = v && typeof v === "object" ? v : ({})
      } catch (e) {
        console.warn("lock-design.json: " + e)
      }
    }
    onLoadFailed: host.config = ({})
  }

  FileView {
    path: host.designsDir + "/designs.json"
    blockLoading: true
    printErrors: false
    onLoaded: {
      try { host.registry = JSON.parse(text()) } catch (e) { console.warn("designs.json: " + e) }
    }
  }

  // Дизайн «живой», если загрузился и за полсекунды назначил себе поле пароля.
  property bool fieldChecked: false
  Timer {
    id: fieldCheck
    interval: 500
    onTriggered: host.fieldChecked = true
  }
  readonly property bool designBroken: designSource === ""
    || design.status === Loader.Error
    || (design.status === Loader.Ready && fieldChecked && (!design.item || !("field" in design.item) || design.item.field === null))
  readonly property Item activeItem: designBroken ? stock.item : design.item

  onDesignSourceChanged: { fieldChecked = false; fieldCheck.restart() }
  onDesignBrokenChanged: if (designBroken && designSource !== "") console.warn("lock design " + designId + " unusable, showing stock LockView")

  function bindView(item) {
    if (!item) return
    item.backgroundPath = Qt.binding(function() { return host.backgroundPath })
    item.backgroundVersion = Qt.binding(function() { return host.backgroundVersion })
    item.fingerprintConfigured = Qt.binding(function() { return host.fingerprintConfigured })
    item.authenticatingPassword = Qt.binding(function() { return host.authenticatingPassword })
    item.failureMessage = Qt.binding(function() { return host.failureMessage })
    item.failedAttempts = Qt.binding(function() { return host.failedAttempts })
    // Пока показан не этот вид, он не принимает ввод (оба могут жить секунду при подмене).
    item.inputEnabled = Qt.binding(function() { return host.inputEnabled && host.activeItem === item })
    item.loadBackground = Qt.binding(function() { return host.loadBackground && host.activeItem === item })
    item.passwordText = Qt.binding(function() { return host.passwordText })
    if ("settings" in item) item.settings = Qt.binding(function() { return host.config })
    if ("preview" in item) item.preview = Qt.binding(function() { return host.preview })
    item.submitPassword.connect(function(p) { if (host.activeItem === item) host.submitPassword(p) })
    item.passwordTextEdited.connect(function(p) { if (host.activeItem === item) host.passwordTextEdited(p) })
    item.clearFailureRequested.connect(function() { if (host.activeItem === item) host.clearFailureRequested() })
    item.wakeRequested.connect(function() { if (host.activeItem === item) host.wakeRequested() })
  }

  Loader {
    id: design
    anchors.fill: parent
    active: host.designSource !== ""
    source: host.designSource
    visible: !host.designBroken
    onLoaded: host.bindView(item)
  }

  Loader {
    id: stock
    anchors.fill: parent
    active: host.designBroken
    visible: host.designBroken
    sourceComponent: LockView { }
    onLoaded: host.bindView(item)
  }
}
