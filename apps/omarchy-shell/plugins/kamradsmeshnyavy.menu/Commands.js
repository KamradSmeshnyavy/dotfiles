.pragma library

// Команды лаунчера: строка поиска, начинающаяся с ">" (идея caelestia, написано с нуля).
//   >            все команды
//   >th          команды, чьё имя начинается с "th"
//   >theme ro    аргументы команды theme, в которых есть "ro"
// Строка команды с аргументами по Enter дописывает ">имя " в поиск (provider "cmd-complete",
// action — новый текст поиска); строка-аргумент и команда без аргументов запускают action.
//
// data: { themes: [имя], skins: [{ name, path, user }], wallpaperTheme: bool,
//         plugins: { widgets, customizer }, home: "~" }
// Команды, которым нужны плагины kamradsmeshnyavy.widgets / .customizer, без них не показываются.

function quote(s) {
  return "'" + String(s).replace(/'/g, "'\\''") + "'"
}

function catalog(data, ru) {
  var t = function(en, r) { return ru ? r : en }
  var customizer = data.home + "/.config/omarchy/plugins/kamradsmeshnyavy.customizer"
  var list = [
    {
      name: "theme", icon: "󰏘", desc: t("Apply an Omarchy theme", "Применить тему Omarchy"),
      args: function() {
        return data.themes.map(function(n) { return { icon: "󰏘", label: n, detail: "omarchy theme set", action: "omarchy-theme-set " + quote(n) } })
      }
    },
    {
      name: "wall", icon: "󰸉", desc: t("Wallpaper: next one or the switcher", "Обои: следующие или переключатель"),
      args: function() {
        return [
          { icon: "󰒭", label: t("next", "следующие"), detail: "omarchy-theme-bg-next", action: "omarchy-theme-bg-next" },
          { icon: "󰸉", label: t("pick…", "выбрать…"), detail: "omarchy-theme-bg-switcher", action: "omarchy-theme-bg-switcher" }
        ]
      }
    },
    {
      name: "skin", icon: "󰉼", desc: t("Bar skin (★ — yours)", "Скин бара (★ — свои)"),
      args: function() {
        return data.skins.map(function(s) {
          return { icon: s.user ? "★" : "󰉼", label: s.name, detail: s.user ? t("your skin", "свой скин") : t("preset", "пресет"),
            action: customizer + "/customizer.sh apply bar-skins " + quote(s.path) }
        })
      }
    },
    { name: "dash", icon: "󰕮", desc: t("Toggle the dashboard", "Открыть / закрыть дашборд"), action: "omarchy-shell widgets toggleDashboard" },
    { name: "dnd", icon: "󰂛", desc: t("Toggle Do Not Disturb", "Включить / выключить «Не беспокоить»"), action: "omarchy-shell notifications toggleDnd" },
    { name: "shader", icon: "󰍹", desc: t("Toggle the screen shader", "Включить / выключить шейдер экрана"), action: customizer + "/scripts/crt-toggle.sh" },
    { name: "custom", icon: "󰸌", desc: t("Open the Customizer", "Открыть Customizer"), action: "omarchy-shell shell toggle kamradsmeshnyavy.customizer" },
    { name: "lock", icon: "󰌾", desc: t("Lock the screen", "Заблокировать экран"), action: "omarchy-system-lock" },
    { name: "power", icon: "󰐥", desc: t("Power menu", "Меню выключения"), action: "omarchy-shell widgets togglePower" }
  ]
  var needs = { skin: "customizer", shader: "customizer", custom: "customizer", dash: "widgets", power: "widgets" }
  list = list.filter(function(c) { return !needs[c.name] || (data.plugins && data.plugins[needs[c.name]]) })
  if (data.wallpaperTheme) {
    list.splice(1, 0, {
      name: "dynamic", icon: "󰏘", desc: t("Theme from the wallpaper (matugen)", "Тема из обоев (matugen)"),
      args: function() {
        return ["tonal-spot", "vibrant", "expressive", "fruit-salad", "monochrome", "light"].map(function(s) {
          return { icon: "󰏘", label: s, detail: "omarchy-wallpaper-theme",
            action: "omarchy-wallpaper-theme " + (s === "light" ? "--mode light" : "--scheme " + s) }
        })
      }
    })
  }
  return list
}

function row(id, icon, label, detail, action, provider, score) {
  return {
    itemId: "cmd." + id, kind: "action", icon: icon, iconFont: "", appIcon: "", appId: "",
    label: label, target: "", detail: detail, path: "", childCount: 0,
    action: action, provider: provider || "", score: score, section: ""
  }
}

function rows(query, data, ru) {
  var text = String(query || "").replace(/^>\s*/, "")
  var space = text.indexOf(" ")
  var name = (space < 0 ? text : text.slice(0, space)).toLowerCase()
  var arg = space < 0 ? "" : text.slice(space + 1).trim().toLowerCase()
  var list = catalog(data, ru)
  var out = []

  // Имя набрано целиком и после него пробел — аргументы команды.
  for (var i = 0; i < list.length; i++) {
    var cmd = list[i]
    if (space < 0 || cmd.name !== name) continue
    if (!cmd.args) return [row(cmd.name, cmd.icon, ">" + cmd.name, cmd.desc, cmd.action, "", 0)]
    var args = cmd.args()
    for (var a = 0; a < args.length; a++) {
      var it = args[a]
      if (arg && it.label.toLowerCase().indexOf(arg) < 0) continue
      out.push(row(cmd.name + "." + a, it.icon, it.label, it.detail, it.action, "", it.label.toLowerCase().indexOf(arg)))
    }
    return out
  }

  for (var j = 0; j < list.length; j++) {
    var c = list[j]
    if (name && c.name.indexOf(name) !== 0) continue
    out.push(c.args
      ? row(c.name, c.icon, ">" + c.name + " …", c.desc, ">" + c.name + " ", "cmd-complete", j)
      : row(c.name, c.icon, ">" + c.name, c.desc, c.action, "", j))
  }
  return out
}
