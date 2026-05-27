# Noctalia Configuration

## File Locations

**Config directory**: `~/.config/noctalia/`
**Settings file**: `~/.config/noctalia/settings.json` (or via `NOCTALIA_SETTINGS_FILE`)
**Cache**: `~/.cache/noctalia/`
**Plugins**: `~/.config/noctalia/plugins/`

With the wrapper-modules approach, the settings file location is controlled by `NOCTALIA_SETTINGS_FILE` (settings-only mode) or `NOCTALIA_CONFIG_DIR` (full config mode). The user's config lives in `modules/features/noctalia.json` and is baked in at build time.

**Settings hierarchy**: defaults → settings.json → per-screen overrides

## Key settings sections in noctalia.json

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

## Plugin System

**Plugin manifest** (`~/.config/noctalia/plugins/<id>/manifest.json`) requires: `id`, `name`, `version`, `author`, `description`, `entryPoints`

**Entry points**: `main`, `barWidget`, `desktopWidget`, `desktopWidgetSettings`, `controlCenterWidget`, `launcherProvider`, `panel`, `settings`

**Plugin IPC target**: `plugin:<manifest-id>`

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
