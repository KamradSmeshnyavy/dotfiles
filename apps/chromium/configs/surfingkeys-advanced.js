// === ПОЛНЫЙ ПЕРЕНОС БИНДОВ TRIDACTYL В SURFINGKEYS ===

// Очищаем стандартные конфликтующие клавиши, которые мы переназначаем
api.unmap('H');
api.unmap('L');
api.unmap('J');
api.unmap('K');
//api.unmap('d');
//api.unmap('u');

// 1. НАВИГАЦИЯ ПО ИСТОРИИ
api.map('H', 'S'); // H — назад по истории
api.map('L', 'D'); // L — вперед по истории

// 2. НАВИГАЦИЯ ПО ВКЛАДКАМ
api.map('J', 'R'); // J — следующая вкладка (вправо)
api.map('K', 'E'); // K — предыдущая вкладка (влево)

// Исправленные быстрые переходы по вкладкам
api.mapkey('gt', 'Go to next tab', () => api.RUNTIME('nextTab'));
api.mapkey('gT', 'Go to prev tab', () => api.RUNTIME('previousTab'));
api.mapkey('g$', 'Go to last tab', () => {
    api.RUNTIME('getTabs', null, res => {
        api.RUNTIME('selectTab', {tabId: res.tabs[res.tabs.length - 1].id});
    });
});

// 3. УПРАВЛЕНИЕ ВКЛАДКАМИ (d/u уходят под скролл, закрытие на x/X)
api.unmap('x');
api.unmap('X');
api.map('x', 'x'); // Теперь это легитимно, так как x был очищен
api.map('X', 'X'); 

// 4. ССЫЛКИ И ПОДСКАЗКИ (HINTS)
api.map('f', 'f'); 
api.map('F', 'af'); // F — открыть ссылку в фоне

// 6. АДРЕСНАЯ СТРОКА И ПОИСК (OMNIBAR)
api.map('o', 'go'); // o — открыть URL / Поиск
api.map('O', 'ox'); // O — открыть URL в новой вкладке
api.map('b', 'ob'); // b — поиск по открытым вкладкам (Buffer)

// 7. ПРОКРУТКА (SCROLL)
api.mapkey('gg', 'Scroll to top', () => api.scroll('top'));
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

// === НАСТРОЙКИ ТЕМЫ ОФОРМЛЕНИЯ ===
settings.theme = `
:root {
  --sk-bg: #05080a;
  --sk-bg-elev: #0b1115;
  --sk-fg: #fff6ff;
  --sk-muted: #4b4c4d;
  --sk-accent: #b2fff3;
  --sk-accent-2: #ffc2df;
  --sk-accent-3: #dfbaff;
  --sk-warn: #ffc79b;
  --sk-error: #ff9fbc;
}
.sk_theme {
  background: var(--sk-bg) !important;
  color: var(--sk-fg) !important;
  border: 1px solid var(--sk-muted) !important;
}
.sk_theme input, .sk_theme textarea, .sk_theme select {
  background: var(--sk-bg-elev) !important;
  color: var(--sk-fg) !important;
  border: 1px solid var(--sk-muted) !important;
}
#sk_omnibar {
  background: var(--sk-bg) !important;
  color: var(--sk-fg) !important;
  border: 1px solid var(--sk-muted) !important;
  box-shadow: 0 10px 30px rgba(5, 8, 10, 0.6) !important;
}
#sk_omnibarSearchResult li {
  border-top: 1px solid rgba(255, 246, 255, 0.08) !important;
}
#sk_omnibarSearchResult li.focused, #sk_omnibarSearchResult li.focused * {
  background: var(--sk-accent-2) !important;
  color: #05080a !important;
}
.sk_theme .omnibar_highlight { color: var(--sk-accent) !important; }
.sk_theme .omnibar_timestamp { color: var(--sk-muted) !important; }
.sk_theme .omnibar_folder { color: var(--sk-accent-3) !important; }
.sk_theme .omnibar_visitcount { color: var(--sk-warn) !important; }
.sk_theme .url { color: var(--sk-accent) !important; }
.sk_theme .annotation { color: var(--sk-muted) !important; }
#sk_status, #sk_find {
  background: var(--sk-bg) !important;
  color: var(--sk-fg) !important;
  border: 1px solid var(--sk-muted) !important;
}
#sk_keystroke {
  background: var(--sk-accent) !important;
  color: #05080a !important;
}
#sk_hints .sk-hint {
  background: var(--sk-accent-2) !important;
  color: #05080a !important;
  border: 1px solid #05080a !important;
}
#sk_hints .sk-hint span {
  color: #05080a !important;
}
`;

// Настройка подсказок (Hints) в стиле Vantablack
api.Hints.style(`
  background: #000000 !important;
  color: #ffffff !important;
  border: solid 1px #ffffff !important;
  box-shadow: none !important;
`);

