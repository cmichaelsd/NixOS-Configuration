# Noctalia IPC Commands

All IPC goes through the Quickshell `ipc call` mechanism:

```bash
# Generic format
noctalia-shell ipc call <target> <function> [args...]

# This user's format (via wrapper-modules binary)
${lib.getExe self'.packages.myNoctalia} ipc call <target> <function> [args...]

# Discover all available IPC endpoints at runtime
noctalia-shell ipc show
```

## Launcher
```bash
ipc call launcher toggle        # open/close app launcher
ipc call launcher clipboard     # open clipboard history (>clip mode)
ipc call launcher emoji         # open emoji picker (>emoji mode)
ipc call launcher command       # quick command runner (>cmd mode)
ipc call launcher windows       # window switcher (>win mode)
ipc call launcher settings      # settings search
```

## Settings / Control Center
```bash
ipc call controlCenter toggle
ipc call settings toggle
ipc call settings open
ipc call settings openTab $tab
ipc call settings toggleTab $tab
```
Valid `$tab`: `general`, `bar`, `dock`, `wallpaper`, `color-scheme`, `user-interface`, `control-center`, `desktop-widgets`, `launcher`, `notifications`, `osd`, `lock-screen`, `session-menu`, `audio`, `display`, `network`, `location`, `system-monitor`, `plugins`, `hooks`, `about`. Subtab: `bar/2`

## Session / Lock
```bash
ipc call lockScreen lock
ipc call sessionMenu toggle
ipc call sessionMenu lockAndSuspend
ipc call calendar toggle
ipc call systemMonitor toggle
ipc call idleInhibitor toggle
ipc call idleInhibitor enable
ipc call idleInhibitor disable
```

## Volume / Audio
```bash
ipc call volume increase
ipc call volume decrease
ipc call volume muteOutput
ipc call volume increaseInput
ipc call volume decreaseInput
ipc call volume muteInput
ipc call volume togglePanel
ipc call volume openPanel
ipc call volume closePanel
```

## Media
```bash
ipc call media playPause
ipc call media play
ipc call media pause
ipc call media stop
ipc call media next
ipc call media previous
ipc call media seekRelative $seconds   # float, e.g. 10.0
ipc call media seekByRatio $position   # 0.0–1.0
ipc call media toggle
```

## Brightness / Display
```bash
ipc call brightness increase
ipc call brightness decrease
ipc call brightness set $value         # 0–100
ipc call nightLight toggle
ipc call monitors on
ipc call monitors off
```

## Network / Bluetooth
```bash
ipc call wifi toggle | enable | disable
ipc call network togglePanel
ipc call bluetooth toggle | enable | disable
ipc call bluetooth togglePanel
ipc call airplaneMode toggle | enable | disable
```

## Power Profile
```bash
ipc call powerProfile cycle
ipc call powerProfile cycleReverse
ipc call powerProfile set powersaver | balanced | performance
ipc call powerProfile toggleNoctaliaPerformance
ipc call battery togglePanel
```

## Bar / Dock / Desktop Widgets
```bash
ipc call bar toggle | showBar | hideBar | peek
ipc call bar setDisplayMode $mode $screen   # modes: always_visible, auto_hide, non_exclusive
ipc call bar setPosition $position $screen  # positions: top, bottom, left, right
ipc call dock toggle
ipc call desktopWidgets enable | disable | toggle | edit
```
Use `screen="all"` to target all monitors.

## Notifications
```bash
ipc call notifications toggleHistory
ipc call notifications toggleDND | enableDND | disableDND
ipc call notifications clear
ipc call notifications dismissOldest | dismissAll
ipc call notifications getHistory
ipc call notifications removeOldestHistory
ipc call notifications removeFromHistory $id
```

## Wallpaper
```bash
ipc call wallpaper toggle
ipc call wallpaper get $monitor
ipc call wallpaper set $path $monitor   # $monitor = screen name or "all"
ipc call wallpaper random $monitor
ipc call wallpaper toggleAutomation | enableAutomation | disableAutomation
ipc call wallpaper refresh
```

## Theme / Dark Mode
```bash
ipc call darkMode toggle | setDark | setLight
ipc call colorScheme set $theme
ipc call colorScheme setGenerationMethod $method
```

## Toast
```bash
ipc call toast send "Title" "Message" 3000 "icon-name"
ipc call toast dismiss
```

## State Export
```bash
ipc call state all                        # full JSON state snapshot
ipc call state all | jq .settings         # inspect current settings
```

## Plugin IPC
```bash
ipc call plugin openSettings $pluginId
ipc call plugin openPanel $pluginId
ipc call plugin closePanel $pluginId
ipc call plugin togglePanel $pluginId

# Plugin-defined custom targets
ipc call plugin:my-plugin toggle
ipc call plugin:my-plugin setMessage "Hello"
```
