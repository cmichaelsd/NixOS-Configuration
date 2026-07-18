# Noctalia v5 IPC Commands (`noctalia msg`)

v5 uses a single flat command surface. There is **no** `ipc call <target> <function>` (that was v4).

```bash
noctalia msg <command> [args…]      # talk to the running shell
noctalia msg --help                 # authoritative runtime list — check here first
```

Most commands are hyphenated tokens; a handful group subcommands (`session`, `media`, `plugins`, `window-switcher`, `plugin`). `[brackets]` = optional arg. `<angle>` = required. `[monitor-selector]` = a connector name (`DP-1`), `*`/`all` for every monitor, or omit for the focused/preferred one.

Commands are grouped below the way the docs are (shell, surfaces, media & UI, system controls, plugins).

---

## Shell

```bash
noctalia msg status                      # basic shell state as JSON
noctalia msg config-reload               # reload the merged config stack now
noctalia msg log-level-status            # current console log level
noctalia msg log-level-set <level>       # debug | info | warn | error

noctalia msg settings-open [context]     # open/focus Settings, optionally at a section
noctalia msg settings-close
noctalia msg settings-toggle [context]

noctalia msg window-switcher             # show switcher on preferred monitor
noctalia msg window-switcher close       # hide it (alias: hide)

# Session (power) actions
noctalia msg session lock
noctalia msg session suspend             # suspend WITHOUT locking first
noctalia msg session lock-and-suspend    # lock, then suspend once lock is active
noctalia msg session logout
noctalia msg session reboot
noctalia msg session shutdown
```

## Surfaces (bar / panels / dock / widgets)

```bash
# Bar  ([bar-name] defaults to all bars; e.g. "main")
noctalia msg bar-show   [bar-name] [monitor-selector]
noctalia msg bar-hide   [bar-name] [monitor-selector]     # also blocks edge/pointer reveal
noctalia msg bar-toggle [bar-name] [monitor-selector]     # toggle without blocking edge reveal
noctalia msg bar-reserve-toggle [bar-name] [monitor-selector]
noctalia msg bar-auto-hide-set <on|off> [bar-name] [monitor-selector]
noctalia msg bar-layer-set <top|overlay> [bar-name] [monitor-selector]

# Panels
noctalia msg panel-open  <id> [context]        # open by id, no toggle-closed
noctalia msg panel-close [id]                   # close active or named panel
noctalia msg panel-toggle launcher [query]      # app launcher (optional prefilled query)
noctalia msg panel-toggle session               # logout/reboot/shutdown menu
noctalia msg panel-toggle clipboard             # clipboard history
noctalia msg panel-toggle wallpaper             # wallpaper picker
noctalia msg panel-toggle control-center [tab]  # optional tab
noctalia msg panel-toggle <author/plugin:entry> [context]   # plugin panel

# Dock
noctalia msg dock-show
noctalia msg dock-hide
noctalia msg dock-toggle
noctalia msg dock-reload

# Desktop widgets (runtime state; layout lives in config)
noctalia msg desktop-widgets-edit | desktop-widgets-exit | desktop-widgets-toggle-edit
noctalia msg desktop-widgets-show | desktop-widgets-hide | desktop-widgets-toggle

# Lockscreen widgets
noctalia msg lockscreen-widgets-edit | lockscreen-widgets-exit | lockscreen-widgets-toggle-edit
```

## Media & UI

### Notifications
```bash
noctalia msg notification-dnd-set <on|off>     # hide/show toasts
noctalia msg notification-dnd-toggle
noctalia msg notification-dnd-status
noctalia msg notification-show <json>          # Noctalia-origin notification (payload below)
noctalia msg notification-invoke-latest        # trigger default action of newest active toast
noctalia msg notification-clear-active         # dismiss all visible toasts
noctalia msg notification-clear-history        # wipe notification history
```

`notification-show` JSON payload (all fields optional except `summary`):
```json
{"app_name":"…","summary":"…","body":"…","urgency":"low|normal|critical",
 "timeout_ms":3000,"icon":"…","category":"…","desktop_entry":"…"}
```
(Field names differ from v4 — it's `summary`/`body`/`timeout_ms`, not `title`/`message`/`timeout`.)

### Clipboard
```bash
noctalia msg clipboard-clear                   # clear history without opening the panel
# (open the panel via: panel-toggle clipboard)
```

### Media (MPRIS)
```bash
noctalia msg media toggle | play | pause | stop
noctalia msg media next | previous
noctalia msg media next-player | previous-player   # switch active MPRIS player
```

### Wallpaper
```bash
noctalia msg wallpaper-random   [connector]    # omit connector = all monitors
noctalia msg wallpaper-next     [connector]
noctalia msg wallpaper-previous [connector]
noctalia msg wallpaper-get      [connector]    # print effective (or default) path
noctalia msg wallpaper-set <path>              # every monitor
noctalia msg wallpaper-set <connector> <path>  # one monitor
```

### Theme
```bash
noctalia msg theme-mode-get                    # dark | light
noctalia msg theme-mode-toggle
noctalia msg theme-mode-set <dark|light|auto>
noctalia msg color-scheme-get
noctalia msg color-scheme-set <builtin|wallpaper|community|custom> <name>
noctalia msg templates-apply                   # re-render enabled theme templates
```

### Screenshots
```bash
noctalia msg screenshot-region                 # interactive region capture
noctalia msg screenshot-fullscreen             # focused monitor
noctalia msg screenshot-fullscreen pick        # display picker
noctalia msg screenshot-fullscreen <connector> # named output
noctalia msg screenshot-fullscreen all         # one combined PNG across all monitors
```

## System Controls

```bash
# Volume (output). Accepts N, N%, or 0.0–1.0
noctalia msg volume-set <value>
noctalia msg volume-up [amount]                # default step 5%
noctalia msg volume-down [amount]
noctalia msg volume-mute                        # toggle output mute

# Microphone (input)
noctalia msg mic-volume-set <value>
noctalia msg mic-volume-up [amount]
noctalia msg mic-volume-down [amount]
noctalia msg mic-mute

# Brightness
noctalia msg brightness-set <value>             # current monitor
noctalia msg brightness-set <connector> <value> # e.g. DP-1 0.65
noctalia msg brightness-set * <value>           # all monitors (e.g. * 40%)
noctalia msg brightness-up [amount]
noctalia msg brightness-down [amount]
noctalia msg brightness-osd <value>             # show OSD only, don't change brightness
noctalia msg brightness-list-backlight-devices  # enumerate sysfs backlight devices

# Night light
noctalia msg nightlight-enable | nightlight-disable | nightlight-toggle
noctalia msg nightlight-force-toggle            # force on vs. return to schedule

# Wi-Fi / Bluetooth
noctalia msg wifi-enable | wifi-disable | wifi-toggle | wifi-status
noctalia msg bluetooth-enable | bluetooth-disable | bluetooth-toggle | bluetooth-status

# Caffeine (idle inhibitor)
noctalia msg caffeine-enable | caffeine-disable | caffeine-toggle

# Power profile (UPower/PPD)
noctalia msg power-set <powersaver|balanced|performance>
noctalia msg power-cycle                        # next profile in UPower's order

# Display power (DPMS)
noctalia msg dpms-on
noctalia msg dpms-off
```

## Plugins

```bash
# Dispatch an event to a plugin entry's onIpc(event, payload) handler
noctalia msg plugin <author/plugin:entry> <target[:bar-name]> <event> [payload]
#   target: focused | <connector> | focused:<bar> | <connector>:<bar> | all
# e.g.
noctalia msg plugin noctalia/screen_recorder:service all toggle
noctalia msg plugin noctalia/example:hello focused set "New label"

# Manage plugins
noctalia msg plugins list
noctalia msg plugins enable  <author/plugin>
noctalia msg plugins disable <author/plugin>
noctalia msg plugins update  <source>

# Plugin sources
noctalia msg plugins source list
noctalia msg plugins source add <name> git  <url>
noctalia msg plugins source add <name> path <local-path>
noctalia msg plugins source remove <name>
```

---

## Non-`msg` CLI (setup / build, not the running shell)

```bash
noctalia                       # launch the shell
noctalia config validate <f>   # validate a config.toml (what validateConfig=true runs at build)
noctalia theme --list-templates
```
