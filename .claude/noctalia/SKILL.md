# Noctalia Expertise

You are an expert on Noctalia, a minimal Wayland desktop shell. When invoked, bring full knowledge of Noctalia's IPC, configuration, NixOS integration, and component system to bear on whatever the user needs.

---

## What is Noctalia

Noctalia ("quiet by design") is a Wayland desktop shell providing a bar, dock, launcher, notifications, lock screen, and desktop widgets. It runs on top of a Wayland compositor (niri, Hyprland, Sway, etc.) and is built on **noctalia-qs** — a custom fork of Quickshell (Qt6/QML).

- GitHub: https://github.com/noctalia-dev/noctalia-shell
- Docs: https://docs.noctalia.dev/v4/

The underlying process is `qs` (quickshell). When installed via the NixOS flake or wrapper-modules, it appears as `.quickshell-wrapped` in `pgrep`.

---

## This User's Setup

- **Config file**: `modules/features/noctalia.nix` — defines `packages.myNoctalia` via `wrapper-modules.wrappers.noctalia-shell.wrap`
- **Settings**: `modules/features/noctalia.json` — JSON, read with `builtins.fromJSON`, `settingsVersion = 59`
- **IPC invocation**: `${lib.getExe self'.packages.myNoctalia} ipc call <target> <function>` (used in niri keybinds)
- **Niri keybind**: `"Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle"`
- **Spawn-at-startup**: `lib.getExe self'.packages.myNoctalia` in niri's `spawn-at-startup`
- **Color scheme**: Tokyo Night, dark mode, `useWallpaperColors = true`, generation method `fruit-salad`
- **Bar**: floating, top, always visible, `backgroundOpacity = 0.8`

### Current bar widgets (left → center → right)
Left: Launcher, Clock, SystemMonitor, ActiveWindow, MediaMini  
(center and right configured in noctalia.json)

---

## NixOS Integration — wrapper-modules (BirdeeHub)

**Repo**: https://github.com/BirdeeHub/nix-wrapper-modules  
**Docs**: https://birdeehub.github.io/nix-wrapper-modules/

```nix
# modules/features/noctalia.nix
{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
    };
  };
}
```

**All available wrap options:**
```nix
wrapper-modules.wrappers.noctalia-shell.wrap {
  inherit pkgs;
  settings = { /* noctalia.json content as attrset or fromJSON */ };
  colors = { mPrimary = "#..."; /* all Material 3 tokens */ };
  plugins = { sources = []; states = {}; version = 2; };
  pluginSettings = { my-plugin = {}; };
  user-templates = "";              # string, path, or attrset
  preInstalledPlugins = [];         # list of plugin packages
  outOfStoreConfig = "/home/cole/.config/noctalia";  # enables GUI editing
  autoCopyConfig = true;            # auto-copy config on startup if missing
  enableDumpScript = true;          # adds dump-noctalia-shell utility
}
```

**Three modes:**
1. **Settings-only** (just `settings`): Sets `NOCTALIA_SETTINGS_FILE` → store path (immutable, GUI cannot save)
2. **Full store config** (settings + other options, no `outOfStoreConfig`): Sets `NOCTALIA_CONFIG_DIR` → store path (immutable)
3. **Out-of-store** (`outOfStoreConfig = "/path"`): Copies to mutable location at runtime — GUI can save changes and install plugins

**Key limitation**: Without `outOfStoreConfig`, GUI settings changes are lost on restart. Use mode 3 if the user wants to configure Noctalia via its GUI and persist changes.

### Official home-manager module (alternative)

```nix
# flake.nix
inputs.noctalia.url = "github:noctalia-dev/noctalia-shell";

# Binary cache
nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
nix.settings.extra-trusted-public-keys = [
  "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
];
```

---

## IPC System

All IPC goes through the Quickshell `ipc call` mechanism:

```bash
# Generic format
noctalia-shell ipc call <target> <function> [args...]

# This user's format (via wrapper-modules binary)
${lib.getExe self'.packages.myNoctalia} ipc call <target> <function> [args...]

# Discover all available IPC endpoints at runtime
noctalia-shell ipc show
```

### Launcher
```bash
ipc call launcher toggle        # open/close app launcher
ipc call launcher clipboard     # open clipboard history (>clip mode)
ipc call launcher emoji         # open emoji picker (>emoji mode)
ipc call launcher command       # quick command runner (>cmd mode)
ipc call launcher windows       # window switcher (>win mode)
ipc call launcher settings      # settings search
```

### Settings / Control Center
```bash
ipc call controlCenter toggle
ipc call settings toggle
ipc call settings open
ipc call settings openTab $tab
ipc call settings toggleTab $tab
```
Valid `$tab`: `general`, `bar`, `dock`, `wallpaper`, `color-scheme`, `user-interface`, `control-center`, `desktop-widgets`, `launcher`, `notifications`, `osd`, `lock-screen`, `session-menu`, `audio`, `display`, `network`, `location`, `system-monitor`, `plugins`, `hooks`, `about`. Subtab: `bar/2`

### Session / Lock
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

### Volume / Audio
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

### Media
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

### Brightness / Display
```bash
ipc call brightness increase
ipc call brightness decrease
ipc call brightness set $value         # 0–100
ipc call nightLight toggle
ipc call monitors on
ipc call monitors off
```

### Network / Bluetooth
```bash
ipc call wifi toggle | enable | disable
ipc call network togglePanel
ipc call bluetooth toggle | enable | disable
ipc call bluetooth togglePanel
ipc call airplaneMode toggle | enable | disable
```

### Power Profile
```bash
ipc call powerProfile cycle
ipc call powerProfile cycleReverse
ipc call powerProfile set powersaver | balanced | performance
ipc call powerProfile toggleNoctaliaPerformance
ipc call battery togglePanel
```

### Bar / Dock / Desktop Widgets
```bash
ipc call bar toggle | showBar | hideBar | peek
ipc call bar setDisplayMode $mode $screen   # modes: always_visible, auto_hide, non_exclusive
ipc call bar setPosition $position $screen  # positions: top, bottom, left, right
ipc call dock toggle
ipc call desktopWidgets enable | disable | toggle | edit
```
Use `screen="all"` to target all monitors.

### Notifications
```bash
ipc call notifications toggleHistory
ipc call notifications toggleDND | enableDND | disableDND
ipc call notifications clear
ipc call notifications dismissOldest | dismissAll
ipc call notifications getHistory
ipc call notifications removeOldestHistory
ipc call notifications removeFromHistory $id
```

### Wallpaper
```bash
ipc call wallpaper toggle
ipc call wallpaper get $monitor
ipc call wallpaper set $path $monitor   # $monitor = screen name or "all"
ipc call wallpaper random $monitor
ipc call wallpaper toggleAutomation | enableAutomation | disableAutomation
ipc call wallpaper refresh
```

### Theme / Dark Mode
```bash
ipc call darkMode toggle | setDark | setLight
ipc call colorScheme set $theme
ipc call colorScheme setGenerationMethod $method
```

### Toast
```bash
ipc call toast send "Title" "Message" 3000 "icon-name"
ipc call toast dismiss
```

### State Export
```bash
ipc call state all                        # full JSON state snapshot
ipc call state all | jq .settings         # inspect current settings
```

### Plugin IPC
```bash
ipc call plugin openSettings $pluginId
ipc call plugin openPanel $pluginId
ipc call plugin closePanel $pluginId
ipc call plugin togglePanel $pluginId

# Plugin-defined custom targets
ipc call plugin:my-plugin toggle
ipc call plugin:my-plugin setMessage "Hello"
```

---

## Configuration

**Config directory**: `~/.config/noctalia/`  
**Settings file**: `~/.config/noctalia/settings.json` (or via `NOCTALIA_SETTINGS_FILE`)  
**Cache**: `~/.cache/noctalia/`  
**Plugins**: `~/.config/noctalia/plugins/`

With the wrapper-modules approach, the settings file location is controlled by `NOCTALIA_SETTINGS_FILE` (settings-only mode) or `NOCTALIA_CONFIG_DIR` (full config mode). The user's config lives in `modules/features/noctalia.json` and is baked in at build time.

**Settings hierarchy**: defaults → settings.json → per-screen overrides

**Schema version**: `settingsVersion = 59`

### Key settings sections in noctalia.json

```jsonc
{
  "settingsVersion": 59,
  "bar": { "barType": "floating|simple|framed", "position": "top|bottom|left|right",
           "displayMode": "always_visible|auto_hide|non_exclusive",
           "backgroundOpacity": 0.8, "density": "comfortable|default|compact",
           "widgets": { "left": [], "center": [], "right": [] } },
  "colorSchemes": { "useWallpaperColors": true, "predefinedScheme": "Tokyo Night",
                    "darkMode": true, "generationMethod": "fruit-salad" },
  "notifications": { "excludedApps": "discord,firefox,chrome,chromium,edge" },
  "idle": { "enabled": true, "screenOffTimeout": 600, "lockTimeout": 660 },
  "hooks": { "enabled": false, "wallpaperChange": "", "startup": "" },
  "osd": { "enabled": true, "location": "bottom", "autoHideMs": 2000 }
}
```

---

## Layer Namespaces (for compositor rules)

| Pattern | Layer | Component |
|---------|-------|-----------|
| `noctalia-background-*` | Background | Desktop widgets, wallpaper |
| `noctalia-launcher-overlay-*` | Top | App launcher overlay |
| `noctalia-dock-*` | Top | Dock |
| `noctalia-overview*` | Top | Overview/workspace backdrop |
| `noctalia-wallpaper*` | Background | Wallpaper rendering |

**This user's niri layer rule** (blur on background/launcher/dock):
```nix
layer-rules = [{
  matches = [{ namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; }];
  background-effect = { blur = true; noise = 0.03; saturation = 1.0; };
}];
```

---

## Components

**Bar types**: `simple`, `floating`, `framed`

**Bar widgets** (usable in `widgets.left`, `widgets.center`, `widgets.right`):
`Launcher`, `Clock`, `SystemMonitor`, `ActiveWindow`, `MediaMini`, `Workspaces`, `Tray`, `Network`, `Battery`, `Volume`, `Bluetooth`, `Language`, `KeyboardLayout`, and plugin-provided widgets.

**Launcher built-in providers**:
- Default — app search (desktop entries, 13 categories)
- `>clip` — clipboard history (requires `cliphist`)
- `>cmd` — quick command runner
- `>win` — window switcher
- Settings search, session actions

---

## Plugin System

**Plugin manifest** (`~/.config/noctalia/plugins/<id>/manifest.json`) requires: `id`, `name`, `version`, `author`, `description`, `entryPoints`

**Entry points**: `main`, `barWidget`, `desktopWidget`, `desktopWidgetSettings`, `controlCenterWidget`, `launcherProvider`, `panel`, `settings`

**Plugin IPC target**: `plugin:<manifest-id>`

---

## Required System Services

| Feature | NixOS option |
|---------|-------------|
| WiFi panel | `networking.networkmanager.enable = true` |
| Bluetooth | `hardware.bluetooth.enable = true` |
| Power profiles | `services.power-profiles-daemon.enable = true` |
| Battery info | `services.upower.enable = true` |
| Clipboard in launcher | `cliphist` in packages |
| Brightness | `brightnessctl` in packages |
| Calendar | `services.gnome.evolution-data-server.enable = true` |

---

## Niri-Specific Config

Blur on Noctalia layers (niri 26.04+):
```nix
layer-rules = [{
  matches = [{ namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; }];
  background-effect = { blur = true; noise = 0.03; saturation = 1.0; };
}];
```

Wallpaper as niri backdrop:
```nix
# Option A — overview wallpaper enabled in settings
layer-rules = [{ matches = [{ namespace = "^noctalia-overview.*$"; }]; place-within-backdrop = true; }];

# Option B — overview wallpaper disabled in settings
layer-rules = [{ matches = [{ namespace = "^noctalia-wallpaper.*$"; }]; place-within-backdrop = true; }];
layout.background-color = "transparent";
```

---

## Troubleshooting

- **Noctalia not starting**: Check `pgrep -a fcitx5` — if `.quickshell-wrapped` not in `pgrep` output, spawn-at-startup didn't fire; also check `journalctl --user` for QML errors
- **IPC not responding**: `noctalia-shell ipc show` to verify endpoints; ensure `WAYLAND_DISPLAY` is set in the calling shell
- **GUI settings not persisting**: Using wrapper-modules without `outOfStoreConfig` — config is in the immutable Nix store; add `outOfStoreConfig` to enable mutable config
- **Settings lost after rebuild**: Same issue as above — without `outOfStoreConfig`, each rebuild overwrites the settings
- **Color scheme not applying**: Check `colorSchemes.useWallpaperColors` and `generationMethod`; run `ipc call colorScheme set $theme` to force a theme
- **Blur not working**: Requires niri 26.04+; check `background-effect` in layer-rules matches the correct namespace regex
- **Layer not blurring**: The regex in `matches.namespace` must match — use `^noctalia-(background|launcher-overlay|dock)-.*$` exactly
