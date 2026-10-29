/**
 * @name Omarchy
 * @description Цвета текущей темы Omarchy (генерируется из colors.toml, слот ~/.config/vesktop/themes/omarchy.css)
 * @author omarchy-app-themes
 * @version 1.0.0
 */

.theme-dark,
.theme-light,
.visual-refresh,
:root {
  /* Фоны: новые имена Discord (visual refresh) и старые */
  --background-base-lowest: {{ darker_background }};
  --background-base-lower: {{ dark_background }};
  --background-base-low: {{ background }};
  --background-surface-high: {{ lighter_background }};
  --background-surface-higher: {{ lighter_background }};
  --background-surface-highest: {{ selection }};
  --background-primary: {{ background }};
  --background-secondary: {{ dark_background }};
  --background-secondary-alt: {{ darker_background }};
  --background-tertiary: {{ darker_background }};
  --background-floating: {{ dark_background }};
  --background-nested-floating: {{ background }};
  --background-mod-subtle: {{ lighter_background }};
  --background-mod-normal: {{ lighter_background }};
  --background-mod-strong: {{ selection }};
  --background-modifier-hover: {{ lighter_background }};
  --background-modifier-active: {{ selection }};
  --background-modifier-selected: {{ selection }};
  --chat-background: {{ background }};
  --chat-background-default: {{ background }};
  --channeltextarea-background: {{ lighter_background }};
  --input-background: {{ lighter_background }};
  --modal-background: {{ background }};
  --modal-footer-background: {{ dark_background }};
  --bg-overlay-chat: {{ background }};
  --bg-overlay-app-frame: {{ darker_background }};
  --bg-base-primary: {{ background }};
  --bg-base-secondary: {{ dark_background }};
  --bg-base-tertiary: {{ darker_background }};

  /* Текст и иконки */
  --text-default: {{ foreground }};
  --text-normal: {{ foreground }};
  --text-strong: {{ bright_foreground }};
  --text-muted: {{ dark_foreground }};
  --text-subtle: {{ muted }};
  --text-link: {{ accent }};
  --header-primary: {{ bright_foreground }};
  --header-secondary: {{ dark_foreground }};
  --channels-default: {{ dark_foreground }};
  --channel-icon: {{ muted }};
  --interactive-normal: {{ dark_foreground }};
  --interactive-hover: {{ foreground }};
  --interactive-active: {{ bright_foreground }};
  --interactive-muted: {{ muted }};
  --icon-default: {{ dark_foreground }};

  /* Акцент и состояния */
  --brand-500: {{ accent }};
  --brand-560: {{ accent }};
  --brand-experiment: {{ accent }};
  --button-filled-brand-background: {{ accent }};
  --button-filled-brand-text: {{ background }};
  --text-brand: {{ accent }};
  --status-danger: {{ red }};
  --status-warning: {{ yellow }};
  --status-positive: {{ green }};
  --mention-background: {{ lighter_background }};
  --mention-foreground: {{ accent }};
  --border-subtle: {{ lighter_background }};
  --border-normal: {{ selection }};
  --border-strong: {{ muted }};
  --scrollbar-thin-thumb: {{ selection }};
  --scrollbar-auto-thumb: {{ selection }};
  --scrollbar-auto-track: {{ dark_background }};
}
