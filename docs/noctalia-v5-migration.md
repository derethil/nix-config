# Noctalia v5 migration research

Research date: 2026-09-19

## Bottom line

Noctalia v5 is a credible replacement for the DMS surface in this configuration. Nearly all of the DMS functionality in use is either native to Noctalia, has a maintained official/community v5 plugin, or can be reduced to a custom button/keybind. The only meaningful feature gap is the custom OpenHue/Hue Manager integration; there is no direct v5 replacement in the current official or community catalogs.

The calendar situation is better than expected: Noctalia has a native calendar service, not a plugin. It can read the same local vdir tree maintained by vdirsyncer/khal, watches it with inotify, shows the events in a month/event view, and opens a meeting URL when an event is clicked. That makes it a practical replacement for the DMS `dankCalendarAgenda` surface, although it is deliberately read-only.

## What is currently in use

The DMS-specific configuration is in `modules/surfaces/lib/panel/dankmaterialshell/`. The configured third-party plugins and custom widgets are:

| Current DMS capability | Configuration evidence |
| --- | --- |
| AI usage/control for Codex and Claude | `aiOverviewControl` |
| Dynamic Niri cast-window action | `dankActions:variant_cast_window` |
| Bitwarden launcher | `dankBitwarden`, prefix `:bw` |
| Calendar agenda | `dankCalendarAgenda` + `dank-calendar` |
| EasyEffects status/control | `easyEffects` |
| Emoji launcher | `emojiLauncher`, prefix `:e` |
| Philips Hue/OpenHue control | local `hueManager` plugin |
| Niri screenshots | `niriScreenshot` |
| Detailed CPU/GPU/RAM monitor | `systemMonitorPlus` |
| Web search launcher | `webSearch` |
| DMS built-in settings search, clipboard search, power | `builtInPluginSettings` |

The bar also uses native DMS controls for the launcher, workspaces, privacy, media, clock, weather, audio, network, Bluetooth, notifications, power/session actions, dock, wallpaper, and control center.

## Direct mapping

| DMS item | Noctalia v5 replacement | Recommendation |
| --- | --- | --- |
| `dankCalendarAgenda` / Dank Calendar | **Built-in Calendar service + Calendar control-center tab** | Use this. It supports CalDAV, Google, ICS, and local vdirs. See the calendar plan below. |
| `dankBitwarden` | **Official `noctalia/bitwarden`** | Use this. It supplies a `/bw` launcher provider, local unlock/login panels, vault search, password/username/TOTP/URI copying, and uses `bw serve` only on loopback. Requires `bitwarden-cli`. Set a non-`never` vault timeout. |
| `emojiLauncher` | **Built-in launcher emoji provider** | No plugin. Its `/emo` provider searches and copies emoji. |
| `niriScreenshot` | **Built-in `screenshot` widget and IPC** | No plugin for ordinary captures. It uses `wlr-screencopy`, supports Niri, region/fullscreen/all-display capture, clipboard/file policy, and a confirmation/editable region flow. |
| DMS color picker | **Community `oldirtty/color_picker`** or `alexander/screen-toolkit` | Prefer `oldirtty/color_picker` for the small focused replacement; it adds history and uses `hyprpicker`. Prefer Screen Toolkit only if OCR, QR scanning, annotation, palette extraction, and recording are desirable; it has a substantial external-tool dependency set. |
| `webSearch` | **Community `notfinaldev/web-search`** | Direct launcher equivalent for favorite sites and web search. |
| `aiOverviewControl` | **Community `felipeartur/ai-usagebar`** | Best functional match for the Codex/Claude usage view. It reads the Rust `ai-usagebar` CLI's JSON, supports Codex and Claude among other providers, and presents bar gauges plus a panel. It does not control agent sessions. |
| `systemMonitorPlus` | **Built-in `sysmon` widget + System control-center tab** | Start native. It can sample CPU temp/usage/frequency/load, GPU temp/usage/VRAM, RAM, network, disk, and swap with polling disabled for metrics you do not display. If the one-line DMS-style capsule is important, try community `tmelik/system-monitor`. |
| `easyEffects` | **No direct current match** | Keep EasyEffects running and let its tray entry remain visible; Noctalia's native Audio tab handles PipeWire input/output/device/stream controls but not EasyEffects effects/presets. A custom button can launch EasyEffects. |
| Local Hue Manager | **No direct current match** | Keep `openhue` as the backend. The community catalog has Home Assistant controls, but no direct OpenHue/Philips Hue plugin. A small native Noctalia plugin that shells out to `openhue`, or a few custom buttons/keybinds for the existing commands, is the sensible porting target. |
| `dankActions:variant_cast_window` | **Built-in custom button / Niri keybind** | No plugin needed. Preserve the existing `niri msg action set-dynamic-cast-window ...` command in a Noctalia custom button or keep it entirely in Niri. |
| DMS settings search | **Built-in Settings + launcher panel provider** | No dedicated plugin necessary. The launcher can search/open registered panels, including Settings and Control Center tabs. |
| DMS clipboard search | **Built-in clipboard history/widget** | No plugin necessary. Confirm retention and privacy behavior before importing the DMS history policy. |
| DMS power plugin | **Built-in session actions + launcher `/session` provider** | No plugin necessary. |
| DMS launcher, dock, taskbar, workspaces, media, clock, tray, weather, network, Bluetooth, volume, notifications, privacy, wallpaper, lock screen, OSD, control center | **Built in** | These are core Noctalia surfaces/widgets/services, not migration plugins. |
| Dank Greeter | **Noctalia Greeter** | Use this as the greeter migration. It is a separate greetd greeter (not part of the shell binary) and can optionally sync wallpaper, palette, font, and output appearance from Noctalia. |

## Plugin choices worth making

### Recommended initial set

1. Official `noctalia/bitwarden`.
2. Community `notfinaldev/web-search`.
3. Community `felipeartur/ai-usagebar`, if the current AI overview is regularly useful.
4. Community `oldirtty/color_picker`, if a lightweight screen color picker matters.

Use the built-in screenshot widget, system monitor, emoji provider, calendar, launcher, control center, dock, and session controls rather than adding overlapping plugins.

### Defer until the base shell is comfortable

- `alexander/screen-toolkit`: excellent but deliberately broad; it depends on tools such as `slurp`, `grim`, `hyprpicker`, `tesseract`, ImageMagick, zbar, and optional recorder/annotation tools. It can replace the color picker and add OCR/QR decoding, annotation, measurement, and recording on Niri.
- `tmelik/system-monitor`: only if native `sysmon` does not give the compact presentation wanted.
- Any Hue solution: port the local plugin only after the native Noctalia UI/layout has settled.

All plugins are trusted Luau code with access to the user account; treat community plugins as code to review, not as sandboxed extensions. The official Bitwarden plugin also has an important local-security trade-off: while `bw serve` is unlocked, any local process able to reach its loopback port can request vault data. Configure an auto-lock timeout and lock it when away.

## Calendar migration: retain vdirsyncer/khal

### Recommended design

Keep the existing sync/edit stack as the source of truth:

```text
CalDAV providers
      │
      ▼
vdirsyncer ──► local vdir collections ◄──► khal (view/edit/create)
                       │
                       └──► Noctalia Calendar (read-only display + join links)
```

Noctalia recursively discovers vdir collections up to five levels deep, reads standard `displayname`, `color`, and `order` metadata, and watches the tree with inotify. A vdirsyncer-created/changed/deleted `.ics` file therefore updates Noctalia without a second sync loop or a manual refresh.

This has two useful consequences:

- No credentials are duplicated in Noctalia for calendars already owned by vdirsyncer.
- khal remains the tool for creation and edits, while Noctalia becomes the fast visual agenda and meeting launcher.

This repository currently contains Dank Calendar's direct CalDAV setup (including an iCloud workaround), but it does **not** contain vdirsyncer or khal configuration. Before implementation, identify the actual local vdir root used on the machine; do not assume the documentation example path.

### Declarative Noctalia shape

The eventual Home Manager settings should express the same TOML structure as this example, with the actual vdir root substituted:

```toml
[calendar]
enabled = true
refresh_minutes = 15
event_date_format = "%A %e %B"
event_time_format = "%H:%M"

[calendar.account.local_vdir]
type = "vdir"
name = "Local Calendars"
path = "/absolute/path/to/the/vdir/root"
calendars = [] # all discovered collections

[control_center.calendar]
show_events_card = true
show_week_numbers = false
```

### Joining meetings

This is the key parity point: clicking an event that includes an HTTP(S) link opens the default browser. Noctalia searches in this order:

1. A meeting URL in the event location.
2. A provider-specific meeting URL (for example a Teams join URL) in the description.
3. A generic event URL.

For reliable one-click joining, make sure vdirsyncer preserves event `LOCATION` and `DESCRIPTION` fields and that the corresponding calendar client writes the actual meeting URL into one of them. Noctalia does not create or edit events, and it does not offer a full scheduling client; khal or another CalDAV client remains necessary for that work.

### Alternative: direct Noctalia CalDAV

Noctalia can also talk directly to iCloud and generic CalDAV, with passwords in Secret Service or an absolute password file (suitable for agenix/sops-nix). This is viable if the vdir stack is retired, but it duplicates network sync responsibility and makes khal's local data a different view. The local-vdir route is lower risk and better matches the requested existing workflow.

## Migration sequence

1. Add Noctalia as a pinned flake input and use its Home Manager module; v5 configuration is separate from the old Quickshell-based v4 configuration.
2. Add Noctalia Greeter as a separate pinned input or use the nixpkgs module. Replace the current `dank-greeter` module only after a login test from a TTY/recovery path; it changes greetd's default session command. Preserve `/var/lib/noctalia-greeter` through impermanence rather than the current `/var/lib/dms-greeter`. Do not enable both available Noctalia Greeter NixOS modules at once.
3. Build a minimal Noctalia configuration first: theme/palette, wallpaper, one bar, dock, launcher, control center, screenshot, native sysmon, and Niri IPC keybind replacements. Enable optional Greeter appearance sync only after both sides work independently.
4. Configure the local-vdir calendar and verify event titles, colors, time zones, recurring events, and at least one Zoom/Teams/Meet URL before removing Dank Calendar.
5. Add the recommended plugins one at a time. Test Bitwarden auto-lock, web-search behavior, and AI usage data before giving them permanent bar space.
6. Port the cast-window control as a custom button/keybind. Keep EasyEffects and OpenHue external at this stage.
7. Run Noctalia as the active shell during verification while retaining the DMS modules in the repository. Only remove DMS/Dank Calendar and their Niri IPC bindings after the Noctalia replacement has been used through a normal workweek.

Avoid making both full shells active in the same session during the final trial: they can both own overlapping desktop surfaces and integration points. Keeping both configurations installed is fine; activate one shell at a time.

## Sources

https://noctalia.dev/plugins

https://docs.noctalia.dev/noctalia/services/calendar/

https://docs.noctalia.dev/noctalia/control-center/

https://docs.noctalia.dev/noctalia/launcher/

https://docs.noctalia.dev/noctalia/bar/widgets/screenshot/

https://docs.noctalia.dev/noctalia/services/system-monitor/

https://docs.noctalia.dev/noctalia/plugins/

https://docs.noctalia.dev/noctalia/getting-started/nixos/

https://docs.noctalia.dev/greeter/installation/

https://docs.noctalia.dev/greeter/configuration/

https://github.com/noctalia-dev/noctalia-greeter

https://github.com/noctalia-dev/official-plugins

https://raw.githubusercontent.com/noctalia-dev/official-plugins/main/catalog.toml

https://github.com/noctalia-dev/official-plugins/tree/main/bitwarden

https://github.com/noctalia-dev/community-plugins

https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/catalog.toml

https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/ai-usagebar/README.md

https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/screen-toolkit/README.md

https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/color_picker/README.md

https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/nix-monitor/README.md
