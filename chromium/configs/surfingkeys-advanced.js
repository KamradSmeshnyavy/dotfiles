// an example to create a new mapping `ctrl-y`
api.mapkey('<ctrl-y>', 'Show me the money', function() {
    api.Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
});

// an example to replace `T` with `gt`, click `Default mappings` to see how `T` works.
api.map('gt', 'T');

// an example to remove mapkey `Ctrl-i`
api.unmap('<ctrl-i>');

// set theme
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
  background: #787eaaff;
}

.sk_theme .omnibar_highlight {
  color: #b4befeff;
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
  color: #b4befeff;
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
  background: #5a5e82ff;
}

.sk_theme #sk_omnibarSearchResult>ul>li.window {
  border-color: #45475aff;
}

.sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
  border-color: #b4befeff;
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
    color-stop(0%, #5a5e82ff),
    color-stop(100%, #4b4e6dff)
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

div.sk_arrow[dir=down
]>div:nth-of-type(1) {
  border-top-color: #45475aff;
}

div.sk_arrow[dir=up
]>div:nth-of-type(1) {
  border-bottom-color: #45475aff;
}

div.sk_arrow>div:nth-of-type(2) {
  border-left-color: transparent;
  border-right-color: transparent;
  background: transparent;
}

div.sk_arrow[dir=down
]>div:nth-of-type(2) {
  border-top-color: #181825ff;
}

div.sk_arrow[dir=up
]>div:nth-of-type(2) {
  border-bottom-color: #181825ff;
}
`;
// click `Save` button to make above settings to take effect.</ctrl-i></ctrl-y>
