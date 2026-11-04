# Browser theming for Omarchy themes

Dark Reader, Stylus and Surfingkeys in Helium and Firefox follow the current Omarchy theme, and so does Firefox's own interface.

## Pieces

| Path | What it does |
|---|---|
| `hooks/theme-set` | Omarchy `theme-set` hook (→ `~/.config/omarchy/hooks/theme-set`); runs the sync scripts |
| `hooks/post-boot.d/darkreader-sync` | applies Dark Reader / Surfingkeys themes left pending at logout |
| `scripts/omarchy-darkreader` | picks the theme's `dark-reader.json` or generates one from `browser-templates/efterklang/Dark-Reader-Settings.json` (colors only), forces the page font from the font profile (`~/.config/omarchy/fonts.json`), writes it into Dark Reader's storage while the browser is closed; also sets the browsers' own page fonts and light/dark sites (see below) |
| `scripts/omarchy-stylus` | recolors the official Catppuccin userstyles (`browser-templates/catppuccin/stylus-import.json`, lib inlined from `lib-std-v1.less`) to the theme palette and makes them active at the next browser start (Firefox: written into Stylus' database; Helium: `helium-launch`) |
| `scripts/firefox_idb.py`, `scripts/stylus-compile.cjs` | read and write Firefox extension IndexedDB (structured clone + snappy); compile usercss with Stylus' own `worker.js` / `less.js` under node |
| `scripts/omarchy-firefox-chrome` | Firefox interface (userChrome / userContent) in theme colors: `stock` view for the stock font profile, `nihil` view for the others |
| `scripts/omarchy-surfingkeys` | swaps the theme block (`const hintsCss` … `settings.theme`, or appends it if missing) inside Surfingkeys' `snippets` in Helium and Firefox, keeping the rest of the config; uses the theme's `surfingkeys.js` (rose-pine-hacker*, kept as-is) or generates one from `browser-templates/surfingkeys/rose-pine.js` (colors only); font is the font profile's mono |
| `scripts/omarchy-stylus-serve` + `systemd/omarchy-stylus-server.service` | serve the styles on `127.0.0.1:47860–47875` (Stylus throttles per host:port) |
| `scripts/helium-browser` | `~/.local/bin` wrapper: runs `omarchy-darkreader apply` and `omarchy-surfingkeys apply`, then starts Helium through `omarchy-stylus helium-launch` |

Dark Reader, Stylus and Surfingkeys read their data only at startup, so a new theme reaches the browser
on its next launch, and is active the moment it starts. Stylus' own update check (interval 8760 h, and
never sooner than a minute after start) is only a fallback (`prime`).

- **Firefox.** While Firefox is closed, `omarchy-stylus` builds each changed style with Stylus' own
  `worker.js` and `less.js` (taken from the installed XPI, run under node) and writes it straight into the
  `stylish` IndexedDB. The result is byte-identical to what Stylus produces itself: same sections, same
  `originalDigest` = sha1 of the source, user variable values kept.
- **Helium.** Chromium's IndexedDB is not writable from outside, so the wrapper starts Helium with
  `--remote-debugging-pipe` when the style set changed since the last launch. The control channel is a
  pair of pipes owned by the wrapper only; no port is opened. Over it, the wrapper calls
  `API.updater.checkAllStyles()` in Stylus' service worker, and Stylus fetches and installs the styles
  within seconds. Closing the pipe would quit Chromium, so the wrapper stays as Helium's parent until it
  exits.

If a browser is open during a theme or font-profile change, `omarchy-darkreader` shows a notification
with a **Перезапустить** button. It sends SIGTERM to the browser's main process (a clean quit that saves
the session), applies everything, runs `omarchy-stylus prime`, and starts the browser again with its tabs
(`helium-browser --restore-last-session`; Firefox gets `browser.sessionstore.resume_session_once`).
After any close, the waiter also runs `omarchy-stylus prime` and `omarchy-surfingkeys apply` for that browser.
Without the button, the changes apply on the next close.

The browsers themselves follow the theme too, so pages look the same in both:

- **Light or dark sites.** Helium takes `prefers-color-scheme` from gsettings, which Omarchy sets per theme.
  Firefox gets `layout.css.prefers-color-scheme.content-override` in `prefs.js` (0 dark, 1 light, from
  `omarchy-theme-color mode`). It must not be set in `user.js`. A forced dark value there made sites
  serve their dark markup on light themes, which Dark Reader then recolored badly.
- **Page fonts.** These are the sans and mono of the font profile. Helium: `webkit.webprefs.fonts` in
  `Preferences` (standard, sans-serif and serif get sans; fixed gets mono). Firefox: `font.name.*` for
  `x-western` and `x-cyrillic`.
- The **Nihil fonts** userstyle gets a new `@version` whenever its rules change; Stylus skips updates that
  are not newer. In the `stock` profile it stays installed with no font rules instead of becoming a
  stub, because a stub's `0.0.0` version would never replace it.

## Firefox

The default profile comes from `~/.config/mozilla/firefox/profiles.ini`. Everything is written while
Firefox is closed: on a theme change if it is closed, otherwise by a background waiter right after
it closes. No wrapper is needed (the desktop entry runs `/usr/lib/firefox/firefox` directly).

- Dark Reader keeps its settings in `storage.sync` (`syncSettings: true`) = `storage-sync-v2.sqlite`,
  plain JSON per extension; `omarchy-darkreader` updates the `addon@darkreader.org` row and bumps
  `sync_change_counter`. Backups go to `~/.local/state/omarchy/darkreader/backups/`.
- Surfingkeys reads its config at startup from `storage.local` only: the `snippets` string in IndexedDB
  `webExtensions-storage-local`. The `storage.sync` copy in `storage-sync-v2.sqlite` is only for syncing and
  can hold an older config. Both are updated; only the theme block changes.
- Stylus: the styles must already be imported with the localhost update URLs (same `import.json`).
  - Styles live in IndexedDB `stylish`:
    `storage/default/moz-extension+++<uuid>/idb`, one row per style.
  - Values are SpiderMonkey structured clone compressed with snappy (system `libsnappy`). Large values
    sit in `<db>.files/<id>` as framed snappy. Written values go back into the row with `file_ids =
    NULL`, and the file refcount is lowered (`update_refcount` is Firefox's own SQL function; the
    triggers need it).
  - Backup before each write: `~/.local/state/omarchy/stylus/backups/<ts>-firefox-idb`.
  - Fallback `prime_firefox`: `lastUpdateTime = 1` in `storage.local` (IndexedDB
    `webExtensions-storage-local` under `moz-extension+++<uuid>^userContextId=4294967295`). Keys there are
    `0x30` + chars shifted by +1.
- Interface: `omarchy-firefox-chrome` keeps `<profile>/chrome/` in sync.
  - `userChrome.css`, `userContent.css`, `userColors.css` are links into
    `apps/browser/configs/firefox/chrome/`.
  - `omarchy/colors.css` holds `--om-*` colors from colors.toml and the profile fonts.
  - `omarchy/style.css` imports `stock.css` or `nihil.css`; both build on `base.css`, which maps
    Firefox's variables to the theme, including Firefox 15x names such as `--toolbar-background-color`.
  - No `@namespace xul` in these files. With it, selectors without a type (`.urlbar-background`) only
    match XUL elements, and the urlbar is HTML now.

### Firefox views by style

`omarchy-firefox-chrome` picks the userChrome view from the Customizer style (`~/.config/omarchy/style.json` id):
`chrome/<id>.css` — flat, glass, fluent, paper, neumorph, brutal, retro, neon (nihil → `nihil.css`). Without a style it
falls back to the font profile (Nihil profiles → `nihil.css`, otherwise `stock.css`). All views sit on `base.css` and the
theme's `--om-*`; `--om-font-title` is the profile's title font, `--om-texture` the Paper grain (light / dark variant,
linked into `chrome/omarchy/`). Visual check: a throwaway `--profile <scratch> --no-remote --new-instance` with only
`chrome/` + `user.js`, then grim the window — it does not touch profiles.ini.

## New machine

1. `install/install.py` links everything above (Linux entries in `install/install.conf.yaml`).
2. `omarchy pkg add python-plyvel`
3. `systemctl --user enable --now omarchy-stylus-server`
4. Run `omarchy-themes/scripts/omarchy-stylus sync`, then in Stylus: Manage → Import
   `~/.local/state/omarchy/stylus/www/import.json` (once). Do not edit the update interval field.

State and backups live in `~/.local/state/omarchy/{darkreader,stylus,surfingkeys}/`. Firefox needs `node`
for the Stylus build (falls back to `prime` without it).
