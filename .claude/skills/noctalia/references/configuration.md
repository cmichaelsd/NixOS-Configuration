# Noctalia v5 Configuration (`config.toml`)

## File & format

- **Location**: `~/.config/noctalia/config.toml` (TOML — v4's `~/.config/noctalia/settings.json` is gone).
- **On this system** it's generated from `programs.noctalia.settings` (Nix attrset → TOML) and symlinked read-only from the Nix store. Edit `modules/features/noctalia.nix`, not the file. GUI edits don't persist.
- **Hot reload**: most keys reload via inotify. Startup-only keys are marked *(startup)* below. Force a reload: `noctalia msg config-reload`.
- **Validation**: `validateConfig = true` runs `noctalia config validate` at build; a bad key/enum fails the build.
- **Nix ↔ TOML mapping**: TOML `[a.b] key = v` → Nix `a.b.key = v`. TOML `[[a.b]]` (array of tables) → Nix `a.b = [ {…} {…} ];`. Keys are **snake_case**. Section names with dashes (`[idle.behavior.screen-off]`) need quoting in Nix: `idle.behavior."screen-off" = {…};`.

The canonical, always-current schema is upstream `example.toml` (`github:noctalia-dev/noctalia`) and https://docs.noctalia.dev/v5/. What follows mirrors example.toml.

---

## `[accessibility]`
- `ui_scale` = 1.0 — global UI scale multiplier.
- `high_contrast` = false.

## `[shell]`
- `corner_radius_scale` = 1.0 — 0 = square, 1 = default, 2 = extra rounded.
- `font_family` = "sans-serif".
- `time_format` = "{:%H:%M}", `date_format` = "%A, %x" — default shell time/date (chrono/strftime tokens; see the date-format-tokens doc).
- `offline_mode` = false — block all outgoing HTTP.
- `telemetry_enabled` = false.
- `niri_overview_type_to_launch_enabled` = false — type-to-launch from niri overview.
- `polkit_agent` = false — run a polkit agent.
- `password_style` = "default" — default | random.
- `settings_show_advanced` = false.
- `middle_click_opens_widget_settings` = true.
- `show_location` = true — show weather location text.
- `app_icon_colorize` = false, `app_icon_color` = "on_surface" — recolor app icons (ColorSpec role or #hex).
- `clipboard_enabled` = true, `clipboard_history_max_entries` = 100 (10–10000), `clipboard_auto_paste` = "auto" (off | auto | ctrl_v | ctrl_shift_v | shift_insert), `clipboard_image_action_command` = "".
- `shared_gl_context` = true *(startup)* — false isolates GPU contexts for broken drivers.
- `lang` = "en", `avatar_path` = "" — user avatar image.

### `[shell.privacy]`
`mic_filter_regex`, `cam_filter_regex`, `screen_filter_regex` — app-name regexes to ignore in privacy indicators/OSD.

### `[shell.animation]`
`enabled` = true, `speed` = 1.0 (0.5 = 2× slower, 2.0 = 2× faster).

### `[shell.shadow]`
`direction` = "down" (center | up | down | left | right | up_left | up_right | down_left | down_right), `alpha` = 0.55.

### `[shell.panel]`
- `transparency_mode` = "solid" — solid | soft | glass.
- `borders` = true, `shadow` = true.
- `<surface>_placement` = attached | floating | centered, for: `launcher_placement` (default centered), `clipboard_placement` (centered), `control_center_placement` (attached), `wallpaper_placement` (attached), `session_placement` (attached).
- `open_near_click_<surface>` = false — for attached/floating, open near the bar click instead of bar-center (`_control_center`, `_launcher`, `_clipboard`, `_wallpaper`, `_session`).

### `[shell.launcher]`
`categories`=true, `show_icons`=true, `compact`=false, `app_grid`=false, `sort_by_usage`=true, `fetch_exchange_rates`=true, `provider_prefix`="/".

Providers are `[shell.launcher.providers.<name>]` with `prefix` (trigger word after `provider_prefix`, e.g. `/emo`) and `global` (also surface in unprefixed search). Built-ins: `calculator` (prefix "", global true), `emoji` (prefix "emo"), `session` (prefix "session", global false), `wallpaper` (prefix "wall"), `windows` (prefix "win").

### `[shell.mpris]`
`blacklist` = [] — ignore MPRIS players by bus/identity/desktop-entry token.

## `[wallpaper]`
- `enabled` = true.
- `fill_mode` = "crop" — center | crop | fit | stretch | repeat | span.
- `fill_color` = "" — fallback fill (color role token or #hex).
- `transition` = ["fade","wipe","disc","stripes","zoom","honeycomb"], `transition_duration` = 1500 (ms), `edge_smoothness` = 0.3, `transition_on_startup` = false.
- `directory` = "~/Pictures/Wallpapers"; optional `directory_light` / `directory_dark` for day/night dirs.
- `[wallpaper.default] path` = "" — initial wallpaper.
- `[wallpaper.automation]` `enabled`=false, `interval_minutes`=0 (0=disabled), `order`="random" (random | alphabetical), `recursive`=true.

## `[theme]`
- `mode` = "dark" — dark | light | auto (auto follows `[location]` sun times).
- `source` = "builtin" — builtin | wallpaper | community.
- `builtin` = "Noctalia" — Ayu | Catppuccin | Dracula | Eldritch | Gruvbox | Kanagawa | Noctalia | Nord | Rosé Pine | Tokyo-Night.
- `community_palette` = "…" — from api.noctalia.dev (source = community). Also matches a `customPalettes` entry name.
- `wallpaper_scheme` = "m3-content" (source = wallpaper) — m3-tonal-spot | m3-content | m3-fruit-salad | m3-rainbow | m3-monochrome | vibrant | faithful | dysfunctional | muted.
- `pure_black_dark` = false — anchor dark surfaces to true black (OLED).

### `[theme.templates]`
`enable_builtin_templates`=true, `builtin_ids`=[] (list via `noctalia theme --list-templates`), `enable_community_templates`=true, `community_ids`=[].
User templates: `[theme.templates.user.<name>]` with `input_path`, `output_path`, `post_hook` — render app themes from the palette (see theming/templates doc).

## `[backdrop]`
`enabled`=false, `blur_intensity`=0.5, `tint_intensity`=0.3 — the blurred/tinted wallpaper copy for the compositor overview (pair with the `^noctalia-backdrop` layer-rule).

## `[notification]`
`enable_daemon`=true, `show_app_name`=true, `show_actions`=true, `layer`="top" (top | overlay), `scale`=1.0, `background_opacity`=0.97, `offset_x`=20, `offset_y`=8.
Per-app filters: `[notification.filter.<name>]` with `enabled`, `match` (regex), `show_toast`, `save_history`, `play_sound`, `allowed_urgencies` (["low","normal","critical"]).

## `[osd]`
`position`="top_right" (top/bottom/center × right/left/center), `position_vertical`="top_center", `orientation`="horizontal" (horizontal | vertical), `scale`=1.0, `background_opacity`=0.97, `offset_x`=20, `offset_y`=8, `monitors`=[] (connectors; empty = all).
`[osd.kinds]` toggles per OSD type (all true): `volume`, `volume_output`, `volume_input`, `brightness`, `wifi`, `bluetooth`, `power_profile`, `caffeine`, `nightlight`, `dnd`, `lock_keys`, `keyboard_layout`, `privacy`.

## `[lockscreen]`
`enabled`=true, `blurred_desktop`=false (needs wlr-screencopy), `blur_intensity`=0.5, `tint_intensity`=0.3, `wallpaper`="" (empty = desktop wallpaper), `monitors`=[] (empty = all).

## `[system.monitor]`
`enabled`=true; poll intervals (seconds): `cpu_poll_seconds`=2.0, `gpu_poll_seconds`=5.0, `memory_poll_seconds`=2.0, `network_poll_seconds`=3.0, `disk_poll_seconds`=10.0.

## `[weather]`
`enabled`=false, `refresh_minutes`=30, `unit`="celsius" (celsius | fahrenheit), `effects`=true. Coordinates come from `[location]`.

## `[audio]`
`enable_overdrive`=false (allow >100% up to 150%), `enable_sounds`=false, `sound_volume`=0.5, `volume_change_sound`="" , `notification_sound`="".

## `[brightness]`
`enable_ddcutil`=false, `ignore_mmids`=[], `minimum_brightness`=0.0.
Per-monitor: `[brightness.monitor.<connector>]` `backend` = auto | none | backlight | ddcutil; `backlight_device` = sysfs name (list via `noctalia msg brightness-list-backlight-devices`).

## `[nightlight]`
`enabled`=false, `force`=false, `temperature_day`=6500, `temperature_night`=4000 (Kelvin).

## `[location]`
Single "where am I", feeds Weather + Night Light + Theme auto. `auto_locate`=false (resolve from IP), `address`="" (geocoded when auto_locate off), `latitude`/`longitude` (manual), `custom_schedule`/`sunset`/`sunrise` (fixed day/night times instead of coordinates).

## `[idle]`
Optional top-level `pre_action_fade_seconds` (fade a surface-color overlay before running an action; 0 = immediate, input cancels).
Behaviors are named tables — `[idle.behavior.<name>]` with `timeout` (s), `action`, `enabled`:
- `[idle.behavior.lock]` → action `lock`.
- `[idle.behavior.screen-off]` → action `screen_off` (Nix: `idle.behavior."screen-off"`).
- Other actions include `suspend` / commands. **This machine deliberately has NO suspend behavior** — s2idle firmware bounces out of suspend (see memory `project_noctalia_suspend_wake_cycle`); keep lock + screen_off only.

## `[keybinds]`
In-shell navigation keys (arrays of key names): `validate` = ["return","kp_enter","space"], `cancel` = ["escape"], `left`/`right`/`up`/`down`, `tab_next` = ["tab"], `tab_previous` = ["shift+iso_left_tab"].

## `[bar.<name>]` (e.g. `[bar.main]`)
`position` = top | bottom | left | right; `thickness`=34, `background_opacity`=1.0, `radius`=12, `margin_h`=180, `margin_v`=10, `padding`=14, `widget_spacing`=6, `scale`=1.0, `shadow`=true, `auto_hide`=false, `smart_auto_hide`, `show_on_workspace_switch`, `reserve_space`=true, `capsule`=false (+ `capsule_fill`/`capsule_radius`/`capsule_opacity`/`capsule_border`).
Widget slots — arrays of widget tokens: `start`, `center`, `end`.
Dead zone (bar margin outside widgets): `[bar.<name>.dead_zone]` `command`, `right_command`, `middle_command`, `scroll_up_command`, `scroll_down_command`.
Per-monitor override: `[bar.<name>.monitor.<key>]` with `match` = "<connector>" plus any bar fields to override (and a nested `.dead_zone`).

### Bar widget tokens (for `start`/`center`/`end`)
`launcher`, `workspaces`, `taskbar`, `active_window`, `clock`, `spacer`, `media`, `audio_visualizer`, `volume`, `brightness`, `battery`, `network`, `bluetooth`, `tray`, `notifications`, `clipboard`, `control-center`, `session`, `settings`, `wallpaper`, `screenshot`, `weather`, `sysmon`, `privacy`, `keyboard_layout`, `lock_keys`, `power_profile`, `caffeine`, `nightlight`, `theme_mode`, `custom_button`.

Per-widget config lives in `[widget.<token>]` tables (a widget appearing once). Examples from the schema:
- `[widget.clock]` `format`, `vertical_format`, `tooltip_format`, `scale`, `font_weight`, `interactive`.
- `[widget.launcher]` / `[widget.control-center]` `custom_image`, `custom_image_colorize`.
- `[widget.notifications]` `hide_when_no_unread`.
- `[widget.network_rx]` / `[widget.network_tx]` `network_speed_unit` (auto|kb|mb), `network_speed_compact`.
- `[widget.keyboard_layout]` `display` (short|full), `show_icon`, `show_label`, `hide_when_single_layout`, `cycle_command`, and `[widget.keyboard_layout.custom_labels]` map.
- `[widget.custom_button]` (also usable as a named `lock_button`-style widget): `type="custom_button"`, `glyph` (Tabler name), `tooltip`, `command`, `right_command`, `middle_command`, `scroll_up_command`, `scroll_down_command`.

## `[dock]`
`enabled`=false, `position`="bottom", `icon_size`=48, spacing/padding (`main_axis_padding`, `cross_axis_padding`, `item_spacing`), `background_opacity`=0.88, corner radii (`radius` + per-corner), `margin_h`/`margin_v`, `shadow`, `show_running`, `auto_hide`, `smart_auto_hide`, `reserve_space`, `active_scale`/`inactive_scale`, `magnification`/`magnification_scale`, `active_opacity`/`inactive_opacity`, `show_dots`, `show_instance_count`, `launcher_position` (none|start|end), `launcher_icon` (Tabler glyph), `active_monitor_only`, `pinned` = [] (e.g. ["firefox","code","kitty"]).

## `[desktop_widgets]` / `[lockscreen_widgets]`
`enabled`=false, `widget_order` = ordered id list. Grid: `[desktop_widgets.grid]` (`visible`, `cell_size`, `major_interval`, `center_guides_visible`, `snap_to_center`).
Each widget: `[desktop_widgets.widget.<id>]` with `type` (clock | weather | sysmon | …), `output` (connector), `cx`/`cy` (position), `scale`, `rotation`; and `[….widget.<id>.settings]` (widget-specific, e.g. clock `format`, `background_opacity`). `lockscreen_widgets` mirrors this.

## `[control_center]`
Dashboard shortcut buttons (array of tables, up to 6): `[[control_center.shortcuts]]` each `type` = wifi | bluetooth | nightlight | notification | wallpaper | screen_recorder | session.
Nix: `control_center.shortcuts = [ { type = "wifi"; } { type = "bluetooth"; } ];`

## `[hooks]`
`battery_low_percent_threshold`=0 (>0 enables the `battery_under_threshold` hook). Event → command (string or list): `started`, `wallpaper_changed`, `colors_changed`, `theme_mode_changed`, `session_locked`, `session_unlocked`, `logging_out`, `rebooting`, `shutting_down`, `wifi_enabled`/`wifi_disabled`, `bluetooth_enabled`/`bluetooth_disabled`, `battery_state_changed`, `battery_under_threshold`, `power_profile_changed`.
Hooks receive `$NOCTALIA_*` env vars (e.g. `$NOCTALIA_THEME_MODE`, `$NOCTALIA_BATTERY_STATE`, `$NOCTALIA_BATTERY_PERCENT`, `$NOCTALIA_POWER_PROFILE`).

---

## Required system services (NixOS)

| Feature | Option |
|---------|--------|
| Wi-Fi panel | `networking.networkmanager.enable = true` |
| Bluetooth | `hardware.bluetooth.enable = true` |
| Power profiles | `services.power-profiles-daemon.enable = true` |
| Battery info | `services.upower.enable = true` |
| External-monitor brightness | `hardware.i2c.enable = true` + `ddcutil` (and `brightness.enable_ddcutil = true`) |
| Internal brightness | `brightnessctl` |
| Weather/location auto | outbound HTTP (don't set `shell.offline_mode`) |

## Plugins

Managed at runtime with `noctalia msg plugins …` (see ipc-commands.md). Plugin ids are `author/plugin`; panel/IPC entries are `author/plugin:entry`. Official plugins include `noctalia/screen_recorder`. Declarative plugin config and manifest details live in the docs (plugins/development).
