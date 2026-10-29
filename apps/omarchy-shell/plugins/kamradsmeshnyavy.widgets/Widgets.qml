import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import QtQuick
import qs.Commons as Commons

// Виджеты рабочего стола: часы, now playing, визуализатор cava, кольца системы.
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
    screens: "all"              // all primary
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
    running: root.playing && root.flag("media")
    onTriggered: if (root.player) root.player.positionChanged()
  }

  // ── cava ───────────────────────────────────────────────────────────────
  readonly property int bars: Math.max(8, Math.min(128, Math.round(num("visualizerBars"))))
  property var levels: []
  readonly property bool cavaWanted: flag("visualizer") && (playing || flag("visualizerIdle"))
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
          } else if (f[0] === "mem" && f.length >= 3) {
            root.mem = Number(f[1]) > 0 ? 1 - Number(f[2]) / Number(f[1]) : 0
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
    running: root.flag("sysinfo")
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
