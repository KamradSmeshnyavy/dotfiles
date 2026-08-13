// === ПОЛНЫЙ ПЕРЕНОС БИНДОВ TRIDACTYL В SURFINGKEYS ===
settings.smoothScroll = false;
//settings.scrollStepSize = 140;
// Очищаем стандартные конфликтующие клавиши, которые мы переназначаем
api.map('S', 'H')
api.map('D', 'L')


api.unmap('H');
api.unmap('L');
api.unmap('J');
api.unmap('K');
//api.unmap('d');
//api.unmap('u');

// Переназначаем клавишу 'B' на вызов поиска по закладкам (оригинальное действие клавиши 'b')
api.map('B', 'b');

// По умолчанию 'b' открывает закладки, а 'T' — табы. Меняем 'b' на поиск по табам:
api.map('b', 'T');


// 1. НАВИГАЦИЯ ПО ИСТОРИИ
api.map('H', 'S'); // H — назад по истории
api.map('L', 'D'); // L — вперед по истории

// 2. НАВИГАЦИЯ ПО ВКЛАДКАМ
api.map('K', 'R'); // J — следующая вкладка (вправо)
api.map('J', 'E'); // K — предыдущая вкладка (влево)

// Исправленные быстрые переходы по вкладкам
// api.mapkey('gt', 'Go to next tab', () => api.RUNTIME('nextTab'));
// api.mapkey('gT', 'Go to prev tab', () => api.RUNTIME('previousTab'));
api.mapkey('g$', 'Go to last tab', () => {
    api.RUNTIME('getTabs', null, res => {
        api.RUNTIME('selectTab', {tabId: res.tabs[res.tabs.length - 1].id});
    });
});

// 3. УПРАВЛЕНИЕ ВКЛАДКАМИ (d/u уходят под скролл, закрытие на x/X)
//api.unmap('x');
//api.unmap('X');
//api.map('x', 'x'); // Теперь это легитимно, так как x был очищен
//api.map('X', 'X'); 

// 4. ССЫЛКИ И ПОДСКАЗКИ (HINTS)
api.map('f', 'f'); 
api.map('F', 'af'); // F — открыть ссылку в фоне

// 6. АДРЕСНАЯ СТРОКА И ПОИСК (OMNIBAR)
api.map('o', 'go'); // o — открыть URL / Поиск
api.map('O', 'ox'); // O — открыть URL в новой вкладке
api.map('b', 'ob'); // b — поиск по открытым вкладкам (Buffer)

// 7. ПРОКРУТКА (SCROLL)
//api.mapkey('gg', 'Scroll to top', () => api.scroll('top'));
api.map('G', 'G'); // G — в самый низ страницы
//api.mapkey('d', 'Scroll down half page', () => api.scroll('pageDown'));
//api.mapkey('u', 'Scroll up half page', () => api.scroll('pageUp'));

// 8. БУФЕР ОБМЕНА
api.map('yy', 'yy'); // yy — скопировать URL страницы
api.map('p', 'cc');   // p — открыть ссылку из буфера
api.map('P', 'ccb');  // P — открыть ссылку из буфера в новой вкладке

// 9. ЗУМ И ПЕРЕЗАГРУЗКА
api.map('r', 'r');   // r — перезагрузить страницу
api.map('R', 'R');   // R — жесткая перезагрузка
api.map('zi', 'zi'); // zi — увеличить масштаб
api.map('zo', 'zo'); // zo — уменьшить масштаб
api.map('zz', 'zr'); // zz — сбросить масштаб

// 10. РЕЖИМ ВЫДЕЛЕНИЯ ТЕКСТА
api.map('v', 'v'); 

//// === Кастомные скрипты ===
//api.mapkey('gP', '#12Open incognito window', function() {
//    api.RUNTIME("openIncognito");
//});
//
api.mapkey('gt', '#8Translate clipboard', function() {
    api.Clipboard.read(function(response) {
        api.tabOpenLink("https://translate.yandex.ru/translator/" + encodeURIComponent(response.data));
    });
});

//api.unmap('U')
//// Бинд на клавишу "u" для скролла на страницу вверх (аналог PageUp)
//api.mapkey('U', 'Scroll a page up', function() {
//    window.scrollBy({ top: -window.innerHeight, behavior: 'instant' });
//});
//api.unmap('D')
//// Бинд на клавишу "d" для скролла на страницу вниз (аналог PageDown)
//api.mapkey('D', 'Scroll a page down', function() {
//    window.scrollBy({ top: window.innerHeight, behavior: 'instant' });
//});

//// Нажмите 'tr' — Перевести текущую страницу на русский в этой же вкладке
//api.unmap('t')
//api.mapkey('tr', 'Перевести страницу на русский', function() {
//    window.location.href = "https://translate.google.com/translate?sl=auto&tl=ru&u=" + encodeURIComponent(window.location.href);
//});
//
//// Нажмите 'tR' (t + Shift+r) — Перевести страницу на русский в новой вкладке
//api.mapkey('tR', 'Перевести страницу в новой вкладке', function() {
//    tabOpenLink("https://translate.google.com/translate?sl=auto&tl=ru&u=" + encodeURIComponent(window.location.href));
//});

// Удаляем стандартные бинды для j и k
//api.unmap('j');
//api.unmap('k');
//
//// Кастомный бинд для j (вниз)
//api.mapkey('j', 'Scroll down', function() {
//    window.scrollBy({ top: 70, behavior: 'instant' });
//});
//
//// Кастомный бинд для k (вверх)
//api.mapkey('k', 'Scroll up', function() {
//    window.scrollBy({ top: -70, behavior: 'instant' });
//});

// Удаляем стандартные бинды для d и u
api.unmap('d');
api.unmap('u');

// Кастомный бинд для d (полстраницы вниз)
api.mapkey('d', 'Scroll half page down', function() {
    window.scrollBy({ top: window.innerHeight / 2, behavior: 'instant' });
});

// Кастомный бинд для u (полстраницы вверх)
api.mapkey('u', 'Scroll half page up', function() {
    window.scrollBy({ top: -window.innerHeight / 2, behavior: 'instant' });
});



// === НАСТРОЙКИ ТЕМЫ ОФОРМЛЕНИЯ ===
// // pastel-hacker
// settings.theme = `
// .sk_theme {
//   background: #1e1e2eff;
//   color: #cdd6f4ff;
// }
//
// .sk_theme input {
//   color: #cdd6f4ff;
// }
//
// .sk_theme .url {
//   color: #a6adc8ff;
// }
//
// .sk_theme .annotation {
//   color: #a6adc8ff;
// }
//
// .sk_theme kbd {
//   background: #313244ff;
//   color: #cdd6f4ff;
// }
//
// .sk_theme .frame {
//   background: #709473ff;
// }
//
// .sk_theme .omnibar_highlight {
//   color: #a6e3a1ff;
// }
//
// .sk_theme .omnibar_folder {
//   color: #b4befeff;
// }
//
// .sk_theme .omnibar_timestamp {
//   color: #f5c2e7ff;
// }
//
// .sk_theme .omnibar_visitcount {
//   color: #89b4faff;
// }
//
// .sk_theme .prompt,
// .sk_theme .resultPage {
//   color: #7f849cff;
// }
//
// .sk_theme .feature_name {
//   color: #fab387ff;
// }
//
// .sk_theme .separator {
//   color: #a6e3a1ff;
// }
//
// #sk_omnibar {
//   box-shadow: 0px 2px 10px #11111b4d;
// }
//
// #sk_omnibarSearchArea>input {
//   background: transparent;
// }
//
// #sk_omnibarSearchArea {
//   border-bottom-color: #6c7086ff;
// }
//
// #sk_omnibarSearchResult.llmChat>h4 {
//   background-color: #a6e3a1ff;
//   color: #1e1e2eff;
// }
//
// .sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
//   background: #313244ff;
// }
//
// .sk_theme #sk_omnibarSearchResult>ul>li.focused {
//   background: #546d5cff;
// }
//
// .sk_theme #sk_omnibarSearchResult>ul>li.window {
//   border-color: #45475aff;
// }
//
// .sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
//   border-color: #a6e3a1ff;
// }
//
// #sk_omnibarSearchResult .tab_in_window {
//   box-shadow: 0px 2px 10px #11111b4d;
// }
//
// #sk_status {
//   border-color: #45475aff;
// }
//
// .expandRichHints span.annotation {
//   color: #89dcebff;
// }
//
// .expandRichHints kbd>.candidates {
//   color: #f38ba8ff;
// }
//
// #sk_keystroke {
//   background: #1e1e2eff;
//   color: #cdd6f4ff;
// }
//
// #sk_usage,
// #sk_popup,
// #sk_editor {
//   box-shadow: 0px 2px 10px #11111b4d;
// }
//
// #sk_usage .feature_name>span {
//   border-bottom-color: #45475aff;
// }
//
// kbd {
//   border-color: #45475aff;
//   border-bottom-color: #585b70ff;
//   box-shadow: inset 0 -1px 0 #585b70ff;
// }
//
// #sk_banner {
//   border-color: #f9e2afff;
//   background: #766c62ff;
// }
//
// #sk_tabs {
//   background: #00000085;
// }
//
// div.sk_tab {
//   background: -webkit-gradient(
//     linear,
//     left top,
//     left bottom,
//     color-stop(0%, #546d5cff),
//     color-stop(100%, #475a51ff)
//   );
//   box-shadow: 0px 3px 7px 0px #11111b4d;
//   border-top-color: #1e1e2eff;
// }
//
// div.sk_tab_title {
//   color: #1e1e2eff;
// }
//
// div.sk_tab_url {
//   color: #181825ff;
// }
//
// div.sk_tab_hint {
//   background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #fdf3dfff), color-stop(100%, #f9e2afff));
//   color: #1e1e2eff;
//   border-color: #f5d07fff;
//   box-shadow: 0px 3px 7px 0px #11111b4d;
// }
//
// div.sk_tab_group {
//   color: #a6adc8ff;
//   border-color: #45475aff;
//   background: #1e1e2eff;
// }
//
// #sk_bubble {
//   border-color: #45475aff;
//   box-shadow: 0 0 20px #11111b4d;
//   color: #bac2deff;
//   background-color: #181825ff;
// }
//
// .sk_scroller_indicator_top {
//   background-image: linear-gradient(#11111bff, transparent);
// }
//
// .sk_scroller_indicator_middle {
//   background-image: linear-gradient(transparent, #11111bff, transparent);
// }
//
// .sk_scroller_indicator_bottom {
//   background-image: linear-gradient(transparent, #11111bff);
// }
//
// #sk_bubble * {
//   color: #cdd6f4ff !important;
// }
//
// div.sk_arrow>div:nth-of-type(1) {
//   border-left-color: transparent;
//   border-right-color: transparent;
//   background: transparent;
// }
//
// div.sk_arrow[dir=down]>div:nth-of-type(1) {
//   border-top-color: #45475aff;
// }
//
// div.sk_arrow[dir=up]>div:nth-of-type(1) {
//   border-bottom-color: #45475aff;
// }
//
// div.sk_arrow>div:nth-of-type(2) {
//   border-left-color: transparent;
//   border-right-color: transparent;
//   background: transparent;
// }
//
// div.sk_arrow[dir=down]>div:nth-of-type(2) {
//   border-top-color: #181825ff;
// }
//
// div.sk_arrow[dir=up]>div:nth-of-type(2) {
//   border-bottom-color: #181825ff;
// }
// `;
//
// // Настройка подсказок (Hints) в стиле Vantablack
// //api.Hints.style(`
//   //background: #000000 !important;
//   //color: #ffffff !important;
//   //border: solid 1px #ffffff !important;
//   //box-shadow: none !important;
// //`);
//
// api.Hints.style(`
//   background: #0d0e1a !important;
//   color: #7dcea0 !important;
//   border: solid 1px #0d0e1a !important; box-shadow: none !important;
// `);
// api.Hints.style("border: solid 2px #0d0e1a !important; color: #7dcea0 !important; background: #0d0e1a !important;", "text");
//
// name: Rosé Pine
// author: thuanowa
// license: unlicense
// upstream: https://github.com/rose-pine/surfingkeys/blob/main/dist/rose-pine.conf
// blurb: All natural pine, faux fur and a bit of soho vibes for the classy minimalist

const hintsCss =
  "font-size: 13pt; font-family: 'JetBrains Mono NL', 'Cascadia Code', 'Helvetica Neue', Helvetica, Arial, sans-serif; border: 0px; color: #e0def4 !important; background: #191724; background-color: #191724";

api.Hints.style(hintsCss);
api.Hints.style(hintsCss, "text");

settings.theme = `
  .sk_theme {
    background: #191724;
    color: #e0def4;
  }
  .sk_theme input {
    color: #e0def4;
  }
  .sk_theme .url {
    color: #c4a7e7;
  }
  .sk_theme .annotation {
    color: #ebbcba;
  }
  .sk_theme kbd {
    background: #26233a;
    color: #e0def4;
  }
  .sk_theme .frame {
    background: #1f1d2e;
  }
  .sk_theme .omnibar_highlight {
    color: #403d52;
  }
  .sk_theme .omnibar_folder {
    color: #e0def4;
  }
  .sk_theme .omnibar_timestamp {
    color: #9ccfd8;
  }
  .sk_theme .omnibar_visitcount {
    color: #9ccfd8;
  }
  .sk_theme .prompt, .sk_theme .resultPage {
    color: #e0def4;
  }
  .sk_theme .feature_name {
    color: #e0def4;
  }
  .sk_theme .separator {
    color: #524f67;
  }
  body {
    margin: 0;

    font-family: "JetBrains Mono NL", "Cascadia Code", "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 12px;
  }
  #sk_omnibar {
    overflow: hidden;
    position: fixed;
    width: 80%;
    max-height: 80%;
    left: 10%;
    text-align: left;
    box-shadow: 0px 2px 10px #21202e;
    z-index: 2147483000;
  }
  .sk_omnibar_middle {
    top: 10%;
    border-radius: 4px;
  }
  .sk_omnibar_bottom {
    bottom: 0;
    border-radius: 4px 4px 0px 0px;
  }
  #sk_omnibar span.omnibar_highlight {
    text-shadow: 0 0 0.01em;
  }
  #sk_omnibarSearchArea .prompt, #sk_omnibarSearchArea .resultPage {
    display: inline-block;
    font-size: 20px;
    width: auto;
  }
  #sk_omnibarSearchArea>input {
    display: inline-block;
    width: 100%;
    flex: 1;
    font-size: 20px;
    margin-bottom: 0;
    padding: 0px 0px 0px 0.5rem;
    background: transparent;
    border-style: none;
    outline: none;
  }
  #sk_omnibarSearchArea {
    display: flex;
    align-items: center;
    border-bottom: 1px solid #524f67;
  }
  .sk_omnibar_middle #sk_omnibarSearchArea {
    margin: 0.5rem 1rem;
  }
  .sk_omnibar_bottom #sk_omnibarSearchArea {
    margin: 0.2rem 1rem;
  }
  .sk_omnibar_middle #sk_omnibarSearchResult>ul {
    margin-top: 0;
  }
  .sk_omnibar_bottom #sk_omnibarSearchResult>ul {
    margin-bottom: 0;
  }
  #sk_omnibarSearchResult {
    max-height: 60vh;
    overflow: hidden;
    margin: 0rem 0.6rem;
  }
  #sk_omnibarSearchResult:empty {
    display: none;
  }
  #sk_omnibarSearchResult>ul {
    padding: 0;
  }
  #sk_omnibarSearchResult>ul>li {
    padding: 0.2rem 0rem;
    display: block;
    max-height: 600px;
    overflow-x: hidden;
    overflow-y: auto;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
    background: #1f1d2e;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.focused {
    background: #26233a;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window {
    border: 2px solid #524f67;
    border-radius: 8px;
    margin: 4px 0px;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
    border: 2px solid #c4a7e7;
  }
  .sk_theme div.table {
    display: table;
  }
  .sk_theme div.table>* {
    vertical-align: middle;
    display: table-cell;
  }
  #sk_omnibarSearchResult li div.title {
    text-align: left;
  }
  #sk_omnibarSearchResult li div.url {
    font-weight: bold;
    white-space: nowrap;
  }
  #sk_omnibarSearchResult li.focused div.url {
    white-space: normal;
  }
  #sk_omnibarSearchResult li span.annotation {
    float: right;
  }
  #sk_omnibarSearchResult .tab_in_window {
    display: inline-block;
    padding: 5px;
    margin: 5px;
    box-shadow: 0px 2px 10px #21202e;
  }
  #sk_status {
    position: fixed;
    bottom: 0;
    right: 20%;
    z-index: 2147483000;
    padding: 4px 8px 0 8px;
    border-radius: 4px 4px 0px 0px;
    border: 1px solid #524f67;
    font-size: 12px;
  }
  #sk_status>span {
    line-height: 16px;
  }
  .expandRichHints span.annotation {
    padding-left: 4px;
    color: #ebbcba;
  }
  .expandRichHints .kbd-span {
    min-width: 30px;
    text-align: right;
    display: inline-block;
  }
  .expandRichHints kbd>.candidates {
    color: #e0def4;
    font-weight: bold;
  }
  .expandRichHints kbd {
    padding: 1px 2px;
  }
  #sk_find {
    border-style: none;
    outline: none;
  }
  #sk_keystroke {
    padding: 6px;
    position: fixed;
    float: right;
    bottom: 0px;
    z-index: 2147483000;
    right: 0px;
    background: #191724;
    color: #e0def4;
  }
  #sk_usage, #sk_popup, #sk_editor {
    overflow: auto;
    position: fixed;
    width: 80%;
    max-height: 80%;
    top: 10%;
    left: 10%;
    text-align: left;
    box-shadow: #21202e;
    z-index: 2147483298;
    padding: 1rem;
  }
  #sk_nvim {
    position: fixed;
    top: 10%;
    left: 10%;
    width: 80%;
    height: 30%;
  }
  #sk_popup img {
    width: 100%;
  }
  #sk_usage>div {
    display: inline-block;
    vertical-align: top;
  }
  #sk_usage .kbd-span {
    width: 80px;
    text-align: right;
    display: inline-block;
  }
  #sk_usage .feature_name {
    text-align: center;
    padding-bottom: 4px;
  }
  #sk_usage .feature_name>span {
    border-bottom: 2px solid #524f67;
  }
  #sk_usage span.annotation {
    padding-left: 32px;
    line-height: 22px;
  }
  #sk_usage * {
    font-size: 10pt;
  }
  kbd {
    white-space: nowrap;
    display: inline-block;
    padding: 3px 5px;
    font: 11px "JetBrains Mono NL", "Cascadia Code", "Helvetica Neue", Helvetica, Arial, sans-serif;
    line-height: 10px;
    vertical-align: middle;
    border: solid 1px #524f67;
    border-bottom-lolor: #524f67;
    border-radius: 3px;
    box-shadow: inset 0 -1px 0 #21202e;
  }
  #sk_banner {
    padding: 0.5rem;
    position: fixed;
    left: 10%;
    top: -3rem;
    z-index: 2147483000;
    width: 80%;
    border-radius: 8px 8px 8px 8px;
    border: 2px solid #ebbcba;
	color: #f6c177;
    text-align: center;
    background: #191724;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
  }
  #sk_tabs {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: transparent;
    overflow: auto;
    z-index: 2147483000;
  }
  div.sk_tab {
    display: inline-flex;
    height: 28px;
    width: 202px;
    justify-content: space-between;
    align-items: center;
    flex-direction: row-reverse;
    border-radius: 3px;
    padding: 10px 20px;
    margin: 5px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#191724), color-stop(100%,#191724));
    box-shadow: 0px 3px 7px 0px #21202e;
  }
  div.sk_tab_wrap {
    display: inline-block;
    flex: 1;
  }
  div.sk_tab_icon {
    display: inline-block;
    vertical-align: middle;
  }
  div.sk_tab_icon>img {
    width: 18px;
  }
  div.sk_tab_title {
    width: 150px;
    display: inline-block;
    vertical-align: middle;
    font-size: 10pt;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    padding-left: 5px;
    color: #e0def4;
  }
  div.sk_tab_url {
    font-size: 10pt;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    color: #c4a7e7;
  }
  div.sk_tab_hint {
    display: inline-block;
    float:right;
    font-size: 10pt;
    font-weight: bold;
    padding: 0px 2px 0px 2px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#191724), color-stop(100%,#191724));
    color: #e0def4;
    border: solid 1px #524f67;
    border-radius: 3px;
    box-shadow: #21202e;
  }
  #sk_tabs.vertical div.sk_tab_hint {
    position: initial;
    margin-inline: 0;
  }
  div.tab_rocket {
    display: none;
  }
  #sk_bubble {
    position: absolute;
    padding: 9px;
    border: 1px solid #524f67;
    border-radius: 4px;
    box-shadow: 0 0 20px #21202e;
    color: #e0def4;
    background-color: #191724;
    z-index: 2147483000;
    font-size: 14px;
  }
  #sk_bubble .sk_bubble_content {
    overflow-y: scroll;
    background-size: 3px 100%;
    background-position: 100%;
    background-repeat: no-repeat;
  }
  .sk_scroller_indicator_top {
    background-image: linear-gradient(#191724, transparent);
  }
  .sk_scroller_indicator_middle {
    background-image: linear-gradient(transparent, #191724, transparent);
  }
  .sk_scroller_indicator_bottom {
    background-image: linear-gradient(transparent, #191724);
  }
  #sk_bubble * {
    color: #e0def4 !important;
  }
  div.sk_arrow>div:nth-of-type(1) {
    left: 0;
    position: absolute;
    width: 0;
    border-left: 12px solid transparent;
    border-right: 12px solid transparent;
    background: transparent;
  }
  div.sk_arrow[dir=down]>div:nth-of-type(1) {
    border-top: 12px solid #524f67;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(1) {
    border-bottom: 12px solid #524f67;
  }
  div.sk_arrow>div:nth-of-type(2) {
    left: 2px;
    position: absolute;
    width: 0;
    border-left: 10px solid transparent;
    border-right: 10px solid transparent;
    background: transparent;
  }
  div.sk_arrow[dir=down]>div:nth-of-type(2) {
    border-top: 10px solid #e0def4;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(2) {
    top: 2px;
    border-bottom: 10px solid #e0def4;
  }
  .ace_editor.ace_autocomplete {
    z-index: 2147483300 !important;
    width: 80% !important;
  }
  @media only screen and (max-width: 767px) {
    #sk_omnibar {
      width: 100%;
      left: 0;
    }
    #sk_omnibarSearchResult {
      max-height: 50vh;
      overflow: scroll;
    }
    .sk_omnibar_bottom #sk_omnibarSearchArea {
      margin: 0;
      padding: 0.2rem;
    }
  }
`;
