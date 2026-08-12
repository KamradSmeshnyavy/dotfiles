// === ПОЛНЫЙ ПЕРЕНОС БИНДОВ TRIDACTYL В SURFINGKEYS ===
settings.smoothScroll = false;
//settings.scrollStepSize = 140;
// Очищаем стандартные конфликтующие клавиши, которые мы переназначаем
api.unmap('H');
api.unmap('L');
api.unmap('J');
api.unmap('K');
//api.unmap('d');
//api.unmap('u');

// Переназначаем клавишу 'T' на вызов поиска по закладкам (оригинальное действие клавиши 'b')
api.map('T', 'b');

// По умолчанию 'b' открывает закладки, а 'T' — табы. Меняем 'b' на поиск по табам:
api.map('b', 'T');

// 1. НАВИГАЦИЯ ПО ИСТОРИИ
api.map('H', 'S'); // H — назад по истории
api.map('L', 'D'); // L — вперед по истории

// 2. НАВИГАЦИЯ ПО ВКЛАДКАМ
api.map('K', 'R'); // J — следующая вкладка (вправо)
api.map('J', 'E'); // K — предыдущая вкладка (влево)

// Исправленные быстрые переходы по вкладкам
api.mapkey('gt', 'Go to next tab', () => api.RUNTIME('nextTab'));
api.mapkey('gT', 'Go to prev tab', () => api.RUNTIME('previousTab'));
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
settings.theme = `
.sk_theme {
  background: #1e1e2eff;
  color: #cdd6f4ff;
}

.sk_theme input {
  color: #cdd6f4ff;
}

.sk_theme .url {
  color: #a6adc8ff;
}

.sk_theme .annotation {
  color: #a6adc8ff;
}

.sk_theme kbd {
  background: #313244ff;
  color: #cdd6f4ff;
}

.sk_theme .frame {
  background: #709473ff;
}

.sk_theme .omnibar_highlight {
  color: #a6e3a1ff;
}

.sk_theme .omnibar_folder {
  color: #b4befeff;
}

.sk_theme .omnibar_timestamp {
  color: #f5c2e7ff;
}

.sk_theme .omnibar_visitcount {
  color: #89b4faff;
}

.sk_theme .prompt,
.sk_theme .resultPage {
  color: #7f849cff;
}

.sk_theme .feature_name {
  color: #fab387ff;
}

.sk_theme .separator {
  color: #a6e3a1ff;
}

#sk_omnibar {
  box-shadow: 0px 2px 10px #11111b4d;
}

#sk_omnibarSearchArea>input {
  background: transparent;
}

#sk_omnibarSearchArea {
  border-bottom-color: #6c7086ff;
}

#sk_omnibarSearchResult.llmChat>h4 {
  background-color: #a6e3a1ff;
  color: #1e1e2eff;
}

.sk_theme #sk_omnibarSearchResult>ul>li:nth-child(odd) {
  background: #313244ff;
}

.sk_theme #sk_omnibarSearchResult>ul>li.focused {
  background: #546d5cff;
}

.sk_theme #sk_omnibarSearchResult>ul>li.window {
  border-color: #45475aff;
}

.sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
  border-color: #a6e3a1ff;
}

#sk_omnibarSearchResult .tab_in_window {
  box-shadow: 0px 2px 10px #11111b4d;
}

#sk_status {
  border-color: #45475aff;
}

.expandRichHints span.annotation {
  color: #89dcebff;
}

.expandRichHints kbd>.candidates {
  color: #f38ba8ff;
}

#sk_keystroke {
  background: #1e1e2eff;
  color: #cdd6f4ff;
}

#sk_usage,
#sk_popup,
#sk_editor {
  box-shadow: 0px 2px 10px #11111b4d;
}

#sk_usage .feature_name>span {
  border-bottom-color: #45475aff;
}

kbd {
  border-color: #45475aff;
  border-bottom-color: #585b70ff;
  box-shadow: inset 0 -1px 0 #585b70ff;
}

#sk_banner {
  border-color: #f9e2afff;
  background: #766c62ff;
}

#sk_tabs {
  background: #00000085;
}

div.sk_tab {
  background: -webkit-gradient(
    linear,
    left top,
    left bottom,
    color-stop(0%, #546d5cff),
    color-stop(100%, #475a51ff)
  );
  box-shadow: 0px 3px 7px 0px #11111b4d;
  border-top-color: #1e1e2eff;
}

div.sk_tab_title {
  color: #1e1e2eff;
}

div.sk_tab_url {
  color: #181825ff;
}

div.sk_tab_hint {
  background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #fdf3dfff), color-stop(100%, #f9e2afff));
  color: #1e1e2eff;
  border-color: #f5d07fff;
  box-shadow: 0px 3px 7px 0px #11111b4d;
}

div.sk_tab_group {
  color: #a6adc8ff;
  border-color: #45475aff;
  background: #1e1e2eff;
}

#sk_bubble {
  border-color: #45475aff;
  box-shadow: 0 0 20px #11111b4d;
  color: #bac2deff;
  background-color: #181825ff;
}

.sk_scroller_indicator_top {
  background-image: linear-gradient(#11111bff, transparent);
}

.sk_scroller_indicator_middle {
  background-image: linear-gradient(transparent, #11111bff, transparent);
}

.sk_scroller_indicator_bottom {
  background-image: linear-gradient(transparent, #11111bff);
}

#sk_bubble * {
  color: #cdd6f4ff !important;
}

div.sk_arrow>div:nth-of-type(1) {
  border-left-color: transparent;
  border-right-color: transparent;
  background: transparent;
}

div.sk_arrow[dir=down]>div:nth-of-type(1) {
  border-top-color: #45475aff;
}

div.sk_arrow[dir=up]>div:nth-of-type(1) {
  border-bottom-color: #45475aff;
}

div.sk_arrow>div:nth-of-type(2) {
  border-left-color: transparent;
  border-right-color: transparent;
  background: transparent;
}

div.sk_arrow[dir=down]>div:nth-of-type(2) {
  border-top-color: #181825ff;
}

div.sk_arrow[dir=up]>div:nth-of-type(2) {
  border-bottom-color: #181825ff;
}
`;

// Настройка подсказок (Hints) в стиле Vantablack
//api.Hints.style(`
  //background: #000000 !important;
  //color: #ffffff !important;
  //border: solid 1px #ffffff !important;
  //box-shadow: none !important;
//`);

api.Hints.style(`
  background: #0d0e1a !important;
  color: #7dcea0 !important;
  border: solid 1px #0d0e1a !important; box-shadow: none !important;
`);
api.Hints.style("border: solid 2px #0d0e1a !important; color: #7dcea0 !important; background: #0d0e1a !important;", "text");

