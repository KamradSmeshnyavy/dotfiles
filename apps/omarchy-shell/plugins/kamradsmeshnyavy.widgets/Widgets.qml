import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import QtQuick
import qs.Commons as Commons

// Виджеты рабочего стола: часы, now playing, визуализатор cava, кольца системы,
// и дашборд, выезжающий из-под бара / рамки (Dashboard.qml, IPC widgets toggleDashboard).
// Окна на слое Bottom — над обоями и под окнами, клики проходят насквозь (кроме
// кнопок плеера). Настройки — ~/.config/omarchy/widgets.json (Customizer → Widgets),
// применяются на лету. Данные (cava, /proc, MPRIS) собираются здесь один раз на все мониторы.
Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string configPath: home + "/.config/omarchy/widgets.json"

  readonly property var defaults: ({
    clock: true,
    clockStyle: "big",          // big stacked terminal minimal
    clockAnchor: "top-left",
    clock24: true,
    clockSeconds: false,
    media: true,
    mediaAnchor: "bottom-left",
    visualizer: true,
    visualizerStyle: "bars",    // bars mirror wave
    visualizerBars: 48,
    visualizerHeight: 140,
    visualizerAlpha: 0.45,
    visualizerIdle: false,      // показывать и без музыки (cava тогда работает всегда)
    sysinfo: true,
    sysinfoAnchor: "top-right",
    edgeMargin: 56,
    tint: "accent",             // роль (accent foreground muted) или ключ colors.toml / #hex
    locale: "",                 // язык даты: "" — как в Customizer (customizer.json), иначе системный
    screens: "all",             // all primary
    weatherCity: "",            // город для погоды (open-meteo); пусто — блок погоды с подсказкой
    weatherUnits: "celsius"     // celsius fahrenheit
  })

  property var raw: ({})
  property var palette: ({})

  function value(key) {
    var v = raw[key]
    return v === undefined || v === null ? defaults[key] : v
  }
  function num(key) {
    var n = Number(value(key))
    return isFinite(n) ? n : Number(defaults[key])
  }
  function flag(key) { return value(key) === true }

  function resolve(spec, fallback) {
    var s = String(spec || "").trim()
    if (s === "") return fallback
    if (s.charAt(0) === "#") return Qt.color(s)
    if (s === "accent") return Commons.Color.accent
    if (s === "foreground") return Commons.Color.foreground
    if (s === "background") return Commons.Color.background
    if (s === "muted") return Commons.Color.muted
    if (s === "urgent") return Commons.Color.urgent
    if (palette[s]) return Qt.color(palette[s])
    return fallback
  }
  readonly property color accent: resolve(value("tint"), Commons.Color.accent)
  readonly property color foreground: Commons.Color.foreground
  readonly property color muted: Commons.Color.muted
  readonly property color background: Commons.Color.background
  readonly property string fontFamily: Commons.Style.font.family

  property string uiLang: ""
  readonly property bool ru: String(locale.name).indexOf("ru") === 0
  function tr(en, ruText) { return ru ? ruText : en }
  readonly property var locale: {
    var l = String(value("locale") || uiLang || "")
    return l !== "" ? Qt.locale(l) : Qt.locale()
  }
  FileView {
    path: root.home + "/.config/omarchy/customizer.json"
    watchChanges: true
    printErrors: false
    onLoaded: {
      try { root.uiLang = String(JSON.parse(text() || "{}").lang || "") } catch (e) { root.uiLang = "" }
    }
    onFileChanged: reload()
  }

  FileView {
    path: root.configPath
    watchChanges: true
    printErrors: false
    onLoaded: {
      try {
        var parsed = JSON.parse(String(text() || "{}"))
        root.raw = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {}
      } catch (e) {
        console.warn("widgets.json: " + e)
      }
    }
    onLoadFailed: root.raw = {}
    onFileChanged: reload()
  }

  FileView {
    path: root.home + "/.local/state/omarchy/current/theme/colors.toml"
    watchChanges: true
    printErrors: false
    onLoaded: {
      var out = {}
      var lines = String(text() || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        var m = lines[i].match(/^\s*([A-Za-z0-9_]+)\s*=\s*["'](#[0-9A-Fa-f]{6})["']/)
        if (m) out[m[1]] = m[2]
      }
      root.palette = out
    }
    onFileChanged: reload()
  }

  // ── Плеер: играющий, иначе первый ─────────────────────────────────────
  readonly property var player: {
    var list = Mpris.players.values
    for (var i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i]
    return list.length > 0 ? list[0] : null
  }
  readonly property bool playing: player !== null && player.isPlaying
  // position у MPRIS не обновляется сам — дёргаем раз в секунду, пока играет.
  Timer {
    interval: 1000
    repeat: true
    running: root.playing && (root.flag("media") || root.dashboardOpen)
    onTriggered: if (root.player) root.player.positionChanged()
  }

  // ── cava ───────────────────────────────────────────────────────────────
  readonly property int bars: Math.max(8, Math.min(128, Math.round(num("visualizerBars"))))
  property var levels: []
  readonly property bool cavaWanted: (flag("visualizer") || dashboardOpen) && (playing || flag("visualizerIdle"))
  readonly property string cavaConfig: [
    "[general]", "bars = " + bars, "framerate = 30", "sleep_timer = 2",
    "[input]", "method = pipewire", "source = auto",
    "[output]", "method = raw", "raw_target = /dev/stdout", "data_format = ascii",
    "ascii_max_range = 100", "bar_delimiter = 59", "frame_delimiter = 10",
    "[smoothing]", "noise_reduction = 77", ""
  ].join("\n")

  Process {
    id: cava
    running: root.cavaWanted
    command: ["bash", "-c", "exec cava -p <(printf '%s' \"$1\")", "omarchy-widgets-cava", root.cavaConfig]
    onRunningChanged: if (!running) root.levels = []
    stdout: SplitParser {
      onRead: data => {
        var parts = data.split(";")
        var out = []
        for (var i = 0; i < parts.length; i++) if (parts[i] !== "") out.push(Number(parts[i]) / 100)
        root.levels = out
      }
    }
  }
  // Смена числа полос — перезапуск с новым конфигом.
  onCavaConfigChanged: if (cava.running) { cava.running = false; Qt.callLater(() => cava.running = root.cavaWanted) }

  // ── Система: CPU, RAM, температура, батарея ───────────────────────────
  property real cpu: 0
  property real mem: 0
  property real temp: 0
  property int battery: -1
  property string batteryStatus: ""
  property var cpuPrev: null
  // История для графиков дашборда (по точке раз в 2 с).
  readonly property int historyLength: 60
  property var cpuHistory: []
  property var memHistory: []

  // ── Дашборд ────────────────────────────────────────────────────────────
  property bool dashboardOpen: false
  // Меню выключения (PowerMenu.qml). Открытие одного закрывает другое.
  property bool powerOpen: false
  onPowerOpenChanged: if (powerOpen) { dashboardOpen = false; overviewOpen = false }
  // Обзор рабочих столов (Overview.qml).
  property bool overviewOpen: false
  onOverviewOpenChanged: if (overviewOpen) { dashboardOpen = false; powerOpen = false }
  IpcHandler {
    target: "widgets"
    function toggleDashboard(): void { root.dashboardOpen = !root.dashboardOpen }
    function openDashboard(): void { root.dashboardOpen = true }
    function closeDashboard(): void { root.dashboardOpen = false }
    function togglePower(): void { root.powerOpen = !root.powerOpen }
    function openPower(): void { root.powerOpen = true }
    function closePower(): void { root.powerOpen = false }
    function toggleOverview(): void { root.overviewOpen = !root.overviewOpen }
    function openOverview(): void { root.overviewOpen = true }
    function closeOverview(): void { root.overviewOpen = false }
  }
  onDashboardOpenChanged: if (dashboardOpen) { powerOpen = false; overviewOpen = false; weatherFetcher.refreshIfStale() }

  // Экран под курсором / с фокусом — дашборд открывается там.
  readonly property var focusedScreen: {
    var m = Hyprland.focusedMonitor
    var list = Quickshell.screens
    for (var i = 0; m && i < list.length; i++) if (list[i].name === m.name) return list[i]
    return list.length > 0 ? list[0] : null
  }

  // Цвет и форма бара (bar-skin.json) — дашборд того же цвета, что бар и рамка.
  property var barSkin: ({})
  FileView {
    path: root.home + "/.config/omarchy/bar-skin.json"
    watchChanges: true
    printErrors: false
    onLoaded: { try { root.barSkin = JSON.parse(text() || "{}") || {} } catch (e) { root.barSkin = {} } }
    onLoadFailed: root.barSkin = {}
    onFileChanged: reload()
  }
  // Прозрачный бар (скины glass, islands, stock-transparent) — тогда цвет попапов темы.
  readonly property color drawerColor: {
    var spec = String(barSkin.background || "bar")
    var c = spec === "bar" ? Commons.Color.bar.background : resolve(spec, Commons.Color.bar.background)
    var a = Number(barSkin.backgroundAlpha)
    if (isFinite(a) && a >= 0) c = Qt.rgba(c.r, c.g, c.b, a)
    if (c.a < 0.6 || barSkin.shape === "islands") c = Commons.Color.popups.background
    return Qt.rgba(c.r, c.g, c.b, Math.max(0.94, c.a))
  }
  readonly property int drawerFlare: barSkin.shape === "frame" || barSkin.shape === "hug"
    ? Math.max(8, Number(barSkin.radius) || 0) : 14

  // Погода: open-meteo (без ключа), раз в 20 минут, только пока открыт дашборд.
  QtObject {
    id: weatherFetcher
    property double fetchedAt: 0
    property string fetchedFor: ""
    function refreshIfStale() {
      var city = String(root.value("weatherCity") || "").trim()
      if (city === "") { root.weather = null; return }
      var key = city + "|" + root.value("weatherUnits")
      if (key === fetchedFor && Date.now() - fetchedAt < 20 * 60 * 1000) return
      fetchedFor = key
      fetchedAt = Date.now()
      get("https://geocoding-api.open-meteo.com/v1/search?count=1&language=" + (root.ru ? "ru" : "en") +
          "&name=" + encodeURIComponent(city), function(geo) {
        var place = geo && geo.results && geo.results[0]
        if (!place) { root.weather = { error: root.tr("City not found: ", "Город не найден: ") + city }; return }
        get("https://api.open-meteo.com/v1/forecast?latitude=" + place.latitude + "&longitude=" + place.longitude +
            "&current=temperature_2m,weather_code,wind_speed_10m,apparent_temperature" +
            "&daily=temperature_2m_max,temperature_2m_min&forecast_days=1&timezone=auto" +
            "&temperature_unit=" + root.value("weatherUnits"), function(f) {
          if (!f || !f.current) { root.weather = { error: root.tr("No weather data", "Нет данных о погоде") }; return }
          root.weather = {
            city: place.name, temp: f.current.temperature_2m, feels: f.current.apparent_temperature,
            code: f.current.weather_code, wind: f.current.wind_speed_10m,
            max: f.daily.temperature_2m_max[0], min: f.daily.temperature_2m_min[0]
          }
        })
      })
    }
    function get(url, done) {
      var xhr = new XMLHttpRequest()
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE) return
        var data = null
        try { data = JSON.parse(xhr.responseText) } catch (e) {}
        if (xhr.status !== 200) { weatherFetcher.fetchedAt = 0; root.weather = { error: root.tr("Weather unavailable", "Погода недоступна") }; return }
        done(data)
      }
      xhr.open("GET", url)
      xhr.send()
    }
  }
  property var weather: null

  Dashboard {
    host: root
  }

  PowerMenu {
    host: root
  }

  Overview {
    host: root
  }

  Process {
    id: sysProbe
    command: ["bash", "-c",
      "read -r _ u n s i w q sq st _ < /proc/stat; echo \"cpu $((u+n+s+i+w+q+sq+st)) $((i+w))\";" +
      "awk '/^MemTotal|^MemAvailable/{printf \"%s \", $2} END{print \"\"}' /proc/meminfo | sed 's/^/mem /';" +
      "t=; for z in /sys/class/thermal/thermal_zone*; do case $(<$z/type) in x86_pkg_temp|TCPU|cpu*|k10temp) t=$(<$z/temp); break;; esac; done;" +
      "echo \"temp ${t:-$(</sys/class/thermal/thermal_zone0/temp)}\";" +
      "for b in /sys/class/power_supply/BAT*; do [ -e \"$b/capacity\" ] && { echo \"bat $(<$b/capacity) $(<$b/status)\"; break; }; done"]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
          var f = lines[i].trim().split(/\s+/)
          if (f[0] === "cpu" && f.length >= 3) {
            var total = Number(f[1]), idle = Number(f[2])
            if (root.cpuPrev) {
              var dt = total - root.cpuPrev.total
              root.cpu = dt > 0 ? Math.max(0, Math.min(1, 1 - (idle - root.cpuPrev.idle) / dt)) : root.cpu
            }
            root.cpuPrev = { total: total, idle: idle }
            root.cpuHistory = root.cpuHistory.concat([root.cpu]).slice(-root.historyLength)
          } else if (f[0] === "mem" && f.length >= 3) {
            root.mem = Number(f[1]) > 0 ? 1 - Number(f[2]) / Number(f[1]) : 0
            root.memHistory = root.memHistory.concat([root.mem]).slice(-root.historyLength)
          } else if (f[0] === "temp" && f.length >= 2) {
            root.temp = Number(f[1]) / 1000
          } else if (f[0] === "bat" && f.length >= 2) {
            root.battery = Number(f[1])
            root.batteryStatus = f[2] || ""
          }
        }
      }
    }
  }
  Timer {
    interval: 2000
    repeat: true
    triggeredOnStart: true
    running: root.flag("sysinfo") || root.dashboardOpen
    onTriggered: if (!sysProbe.running) sysProbe.running = true
  }

  // ── Окна ───────────────────────────────────────────────────────────────
  Variants {
    model: root.value("screens") === "primary" ? Quickshell.screens.slice(0, 1) : Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: layer

        required property var modelData

        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        surfaceFormat.opaque: false
        WlrLayershell.namespace: "omarchy-widgets"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        // Клики — только по карточке плеера, остальное прозрачно для рабочего стола.
        mask: Region { item: media.visible ? media : null }

        Visualizer {
          host: root
          visible: root.flag("visualizer") && root.levels.length > 0
          anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
          height: Math.max(40, root.num("visualizerHeight"))
        }

        ClockWidget {
          id: clockW
          host: root
          visible: root.flag("clock")
          x: layer.place(clockW, "clockAnchor").x
          y: layer.place(clockW, "clockAnchor").y
        }

        MediaWidget {
          id: media
          host: root
          visible: root.flag("media") && root.player !== null && root.player.trackTitle !== ""
          x: layer.place(media, "mediaAnchor").x
          y: layer.place(media, "mediaAnchor").y
        }

        SysInfo {
          id: sysW
          host: root
          visible: root.flag("sysinfo")
          x: layer.place(sysW, "sysinfoAnchor").x
          y: layer.place(sysW, "sysinfoAnchor").y
        }

        // Позиция по якорю: top-left … bottom-right, center; отступ edgeMargin от краёв.
        function place(item, key) {
          var a = String(root.value(key))
          var m = root.num("edgeMargin")
          var w = item.width, h = item.height
          var x = a.indexOf("left") !== -1 ? m : a.indexOf("right") !== -1 ? width - w - m : (width - w) / 2
          var y = a.indexOf("top") !== -1 ? m : a.indexOf("bottom") !== -1 ? height - h - m : (height - h) / 2
          return Qt.point(Math.round(x), Math.round(y))
        }
      }
    }
  }
}
