.pragma library

// Быстрые режимы лаунчера — по первому символу строки поиска (идеи Vitreus и glyph-rice, код свой):
//   =  калькулятор и единицы (qalc): «=2^10», «=5 km to mi», «=100 usd to eur»; Enter — копировать
//   :  эмодзи, каомодзи и символы (charms.json, scripts/gen-charms.py): «:fire», «:k cat», «:s arrow»
//   @  окна Hyprland: «@fire» — перейти к окну
//   !  веб-поиск: «!g запрос», «!yt …», «!gh …»; без известного bang — DuckDuckGo
//   ;  история буфера обмена (cliphist): «;ссылка»; Enter — вернуть в буфер
// Строки — того же вида, что у Commands.js: action — shell-команда, её выполняет Menu.runAction.
// ctx: { charms: {emoji,kaomoji,symbols}, windows: [{address,cls,title,ws}], calc: {expr,result,busy},
//        clips: [{line,text}], clipsLoaded: bool }

var PREFIXES = "=:@!;"

function modeOf(text) {
  var c = String(text || "").charAt(0)
  return c !== "" && PREFIXES.indexOf(c) !== -1 ? c : ""
}

function quote(s) {
  return "'" + String(s).replace(/'/g, "'\\''") + "'"
}

function row(id, icon, label, detail, action, score) {
  return {
    itemId: "mode." + id, kind: "action", icon: icon, iconFont: "", appIcon: "", appId: "",
    label: label, target: "", detail: detail, path: "", childCount: 0,
    action: action, provider: "", score: score || 0, section: ""
  }
}
function hint(id, icon, label, detail) {
  // Строка-подсказка: Enter по ней дописывает пример в поиск (provider cmd-complete).
  var r = row(id, icon, label, detail, "", 0)
  r.provider = "cmd-complete"
  r.action = label.replace(/\s*…$/, "")
  return r
}

function copyAction(text, title) {
  return "printf '%s' " + quote(text) + " | wl-copy && omarchy notification send -t 1500 -g 󰆏 " + quote(title) + " " + quote(text) + " >/dev/null 2>&1"
}

var BANGS = [
  ["g", "Google", "https://www.google.com/search?q="],
  ["d", "DuckDuckGo", "https://duckduckgo.com/?q="],
  ["yt", "YouTube", "https://www.youtube.com/results?search_query="],
  ["gh", "GitHub", "https://github.com/search?type=repositories&q="],
  ["w", "Wikipedia", "https://{lang}.wikipedia.org/w/index.php?search="],
  ["aw", "Arch Wiki", "https://wiki.archlinux.org/index.php?search="],
  ["aur", "AUR", "https://aur.archlinux.org/packages?K="],
  ["pkg", "Arch packages", "https://archlinux.org/packages/?q="],
  ["r", "Reddit", "https://www.reddit.com/search/?q="],
  ["so", "Stack Overflow", "https://stackoverflow.com/search?q="],
  ["mdn", "MDN", "https://developer.mozilla.org/search?q="],
  ["tr", "Translate", "https://translate.google.com/?sl=auto&tl={lang}&text="],
  ["m", "Maps", "https://www.openstreetmap.org/search?query="],
  ["ya", "Yandex", "https://yandex.ru/search/?text="]
]

function rows(mode, text, ctx, ru) {
  var t = function(en, r) { return ru ? r : en }
  var q = String(text || "").slice(1)
  var out = []

  if (mode === "=") {
    var expr = q.trim()
    if (expr === "") {
      return [hint("calc.0", "󰃬", "=2^10 + 3*7", t("Calculator: any expression", "Калькулятор: любое выражение")),
              hint("calc.1", "󰃬", "=5 km to mi", t("Units and conversions (qalc)", "Единицы и перевод (qalc)")),
              hint("calc.2", "󰃬", "=100 usd to eur", t("Currencies (rates updated by qalc)", "Валюты (курсы обновляет qalc)"))]
    }
    var c = ctx.calc || {}
    if (c.expr !== expr || c.busy) return [row("calc.busy", "󰃬", "= …", t("calculating", "считаю"), "", 0)]
    if (!c.result) return [row("calc.err", "󰃬", t("No result", "Нет результата"), expr, "", 0)]
    return [row("calc.res", "󰃬", "= " + c.result, t("Enter — copy · ", "Enter — скопировать · ") + expr, copyAction(c.result, t("Copied", "Скопировано")), 0)]
  }

  if (mode === ":") {
    var ch = ctx.charms || { emoji: [], kaomoji: [], symbols: [] }
    var kind = "", query = q.trim().toLowerCase()
    var m = query.match(/^([eks])\s+(.*)$/)
    if (m) { kind = m[1]; query = m[2] }
    else if (query === "e" || query === "k" || query === "s") { kind = query; query = "" }
    var words = query.split(/\s+/).filter(function(w) { return w !== "" })
    function match(name) {
      for (var i = 0; i < words.length; i++) if (name.indexOf(words[i]) === -1) return false
      return true
    }
    function add(list, tag, limit, label) {
      var n = 0
      for (var i = 0; i < list.length && n < limit; i++) {
        if (!match(list[i][1])) continue
        out.push(row("charm." + tag + i, label ? "󰞅" : list[i][0], label ? list[i][0] : list[i][1],
                     label ? list[i][1] : tag === "e" ? t("emoji", "эмодзи") : t("symbol", "символ"),
                     copyAction(list[i][0], t("Copied", "Скопировано")), n))
        n++
      }
    }
    if (!kind && words.length === 0) {
      out.push(hint("charm.h1", "󰞅", ":k cat", t("Kaomoji: :k <word>", "Каомодзи: :k <слово>")))
      out.push(hint("charm.h2", "󱖫", ":s arrow", t("Symbols: :s <name> (arrows, math, currency, box…)", "Символы: :s <название> (стрелки, математика, валюты, рамки…)")))
    }
    if (!kind || kind === "e") add(ch.emoji, "e", kind ? 120 : 60, false)
    if (!kind || kind === "k") add(ch.kaomoji, "k", kind ? 80 : 12, true)
    if (!kind || kind === "s") add(ch.symbols, "s", kind ? 120 : 30, false)
    return out
  }

  if (mode === "@") {
    var wq = q.trim().toLowerCase()
    var wins = ctx.windows || []
    for (var i = 0; i < wins.length; i++) {
      var w = wins[i]
      var hay = (w.title + " " + w.cls).toLowerCase()
      if (wq && hay.indexOf(wq) === -1) continue
      out.push(row("win." + w.address, "󰖯", w.title || w.cls, w.cls + " · " + t("workspace ", "стол ") + w.ws,
                   "hyprctl eval " + quote("hl.dispatch(hl.dsp.focus({ window = 'address:" + w.address + "' }))"), hay.indexOf(wq)))
    }
    if (out.length === 0) out.push(row("win.none", "󰖯", t("No windows", "Окон нет"), wq, "", 0))
    return out
  }

  if (mode === "!") {
    var sp = q.indexOf(" ")
    var key = (sp < 0 ? q : q.slice(0, sp)).toLowerCase()
    var rest = sp < 0 ? "" : q.slice(sp + 1).trim()
    var lang = ru ? "ru" : "en"
    var bang = null
    for (var b = 0; b < BANGS.length; b++) if (BANGS[b][0] === key) bang = BANGS[b]
    if (bang && rest !== "") {
      var url = bang[2].replace("{lang}", lang) + encodeURIComponent(rest)
      return [row("bang." + key, "󰖟", t("Search ", "Искать ") + bang[1] + ": " + rest, url, "xdg-open " + quote(url), 0)]
    }
    if (sp < 0) {
      for (var k = 0; k < BANGS.length; k++) {
        if (key && BANGS[k][0].indexOf(key) !== 0) continue
        var hr = hint("bang.h" + k, "󰖟", "!" + BANGS[k][0] + " …", BANGS[k][1])
        hr.action = "!" + BANGS[k][0] + " "
        out.push(hr)
      }
    }
    var all = q.trim()
    if (all !== "" && !(bang && rest === "")) {
      var durl = "https://duckduckgo.com/?q=" + encodeURIComponent(all)
      out.push(row("bang.ddg", "󰖟", t("Search the web: ", "Искать в сети: ") + all, durl, "xdg-open " + quote(durl), 99))
    }
    return out
  }

  if (mode === ";") {
    if (!ctx.clipsLoaded) return [row("clip.busy", "󰅍", "…", t("reading clipboard history", "читаю историю буфера"), "", 0)]
    var cq = q.trim().toLowerCase()
    var clips = ctx.clips || []
    for (var j = 0; j < clips.length && out.length < 120; j++) {
      var item = clips[j]
      if (cq && item.text.toLowerCase().indexOf(cq) === -1) continue
      var img = /^\[\[ binary data/.test(item.text)
      out.push(row("clip." + j, img ? "󰋩" : "󰅍", item.text.replace(/\s+/g, " ").slice(0, 120),
                   t("Enter — back to the clipboard", "Enter — вернуть в буфер"),
                   "printf '%s' " + quote(item.line) + " | cliphist decode | wl-copy", j))
    }
    if (out.length === 0) out.push(row("clip.none", "󰅍", t("Nothing found", "Ничего не нашлось"), cq || t("history is empty", "история пуста"), "", 0))
    return out
  }
  return out
}
