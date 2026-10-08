// omarchyGenerated
const hintsCss =
  "font-size: 13pt; font-family: 'JetBrains Mono NL', 'Cascadia Code', 'Helvetica Neue', Helvetica, Arial, sans-serif; border: 0px; color: #dcd7e6 !important; background: #0d0e1a; background-color: #0d0e1a";

api.Hints.style(hintsCss);
api.Hints.style(hintsCss, "text");

settings.theme = `
  .sk_theme {
    background: #0d0e1a;
    color: #dcd7e6;
  }
  .sk_theme input {
    color: #dcd7e6;
  }
  .sk_theme .url {
    color: #c9a0dc;
  }
  .sk_theme .annotation {
    color: #7dcea0;
  }
  .sk_theme kbd {
    background: #1a1b32;
    color: #dcd7e6;
  }
  .sk_theme .frame {
    background: #171824;
  }
  .sk_theme .omnibar_highlight {
    color: #32323f;
  }
  .sk_theme .omnibar_folder {
    color: #dcd7e6;
  }
  .sk_theme .omnibar_timestamp {
    color: #8dd4cc;
  }
  .sk_theme .omnibar_visitcount {
    color: #8dd4cc;
  }
  .sk_theme .prompt, .sk_theme .resultPage {
    color: #dcd7e6;
  }
  .sk_theme .feature_name {
    color: #dcd7e6;
  }
  .sk_theme .separator {
    color: #4a4d6a;
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
    box-shadow: 0px 2px 10px #151622;
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
    border-bottom: 1px solid #4a4d6a;
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
    background: #171824;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.focused {
    background: #1a1b32;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window {
    border: 2px solid #4a4d6a;
    border-radius: 8px;
    margin: 4px 0px;
  }
  .sk_theme #sk_omnibarSearchResult>ul>li.window.focused {
    border: 2px solid #c9a0dc;
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
    box-shadow: 0px 2px 10px #151622;
  }
  #sk_status {
    position: fixed;
    bottom: 0;
    right: 20%;
    z-index: 2147483000;
    padding: 4px 8px 0 8px;
    border-radius: 4px 4px 0px 0px;
    border: 1px solid #4a4d6a;
    font-size: 12px;
  }
  #sk_status>span {
    line-height: 16px;
  }
  .expandRichHints span.annotation {
    padding-left: 4px;
    color: #7dcea0;
  }
  .expandRichHints .kbd-span {
    min-width: 30px;
    text-align: right;
    display: inline-block;
  }
  .expandRichHints kbd>.candidates {
    color: #dcd7e6;
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
    background: #0d0e1a;
    color: #dcd7e6;
  }
  #sk_usage, #sk_popup, #sk_editor {
    overflow: auto;
    position: fixed;
    width: 80%;
    max-height: 80%;
    top: 10%;
    left: 10%;
    text-align: left;
    box-shadow: #151622;
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
    border-bottom: 2px solid #4a4d6a;
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
    border: solid 1px #4a4d6a;
    border-bottom-lolor: #4a4d6a;
    border-radius: 3px;
    box-shadow: inset 0 -1px 0 #151622;
  }
  #sk_banner {
    padding: 0.5rem;
    position: fixed;
    left: 10%;
    top: -3rem;
    z-index: 2147483000;
    width: 80%;
    border-radius: 8px 8px 8px 8px;
    border: 2px solid #7dcea0;
	color: #f5cba7;
    text-align: center;
    background: #0d0e1a;
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
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#0d0e1a), color-stop(100%,#0d0e1a));
    box-shadow: 0px 3px 7px 0px #151622;
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
    color: #dcd7e6;
  }
  div.sk_tab_url {
    font-size: 10pt;
    white-space: nowrap;
    text-overflow: ellipsis;
    overflow: hidden;
    color: #c9a0dc;
  }
  div.sk_tab_hint {
    display: inline-block;
    float:right;
    font-size: 10pt;
    font-weight: bold;
    padding: 0px 2px 0px 2px;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#0d0e1a), color-stop(100%,#0d0e1a));
    color: #dcd7e6;
    border: solid 1px #4a4d6a;
    border-radius: 3px;
    box-shadow: #151622;
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
    border: 1px solid #4a4d6a;
    border-radius: 4px;
    box-shadow: 0 0 20px #151622;
    color: #dcd7e6;
    background-color: #0d0e1a;
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
    background-image: linear-gradient(#0d0e1a, transparent);
  }
  .sk_scroller_indicator_middle {
    background-image: linear-gradient(transparent, #0d0e1a, transparent);
  }
  .sk_scroller_indicator_bottom {
    background-image: linear-gradient(transparent, #0d0e1a);
  }
  #sk_bubble * {
    color: #dcd7e6 !important;
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
    border-top: 12px solid #4a4d6a;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(1) {
    border-bottom: 12px solid #4a4d6a;
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
    border-top: 10px solid #dcd7e6;
  }
  div.sk_arrow[dir=up]>div:nth-of-type(2) {
    top: 2px;
    border-bottom: 10px solid #dcd7e6;
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
