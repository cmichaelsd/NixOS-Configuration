---
name: noctalia
description: Expert reference for Noctalia, the user's Wayland desktop shell (bar, dock, launcher, notifications, lock screen, built on quickshell) — covers the wrapper-modules wrap options, IPC commands (launcher, settings, volume, media, brightness, notifications, wallpaper, theme, etc.), bar/layer config, the noctalia.json schema, plugins, and niri layer-rule integration. Use whenever the user is editing /etc/nixos/modules/features/noctalia.nix or noctalia.json, binding a key to a Noctalia IPC call, configuring bar widgets or the launcher, troubleshooting the shell, or asking how to make Noctalia do something — also trigger when they describe panel/shell/launcher/notification behavior without naming Noctalia explicitly.
---

# Noctalia

Noctalia ("quiet by design") is a Wayland desktop shell providing a bar, dock, launcher, notifications, lock screen, and desktop widgets. It runs on top of a Wayland compositor (niri, Hyprland, Sway, etc.) and is built on **noctalia-qs** — a custom fork of Quickshell (Qt6/QML).

- GitHub: https://github.com/noctalia-dev/noctalia-shell
- Docs: https://docs.noctalia.dev/v4/

The underlying process is `qs` (quickshell). When installed via the NixOS flake or wrapper-modules, it appears as `.quickshell-wrapped` in `pgrep`.

---

## This User's Setup

- **Wrapper module**: `modules/features/noctalia.nix` — defines `packages.myNoctalia` via `wrapper-modules.wrappers.noctalia-shell.wrap`
- **Settings**: `modules/features/noctalia.json` — JSON, read with `builtins.fromJSON`. Read this file directly when answering questions about current bar widgets, color scheme, opacity, etc. — it is the source of truth and the `settingsVersion` may change.
- **IPC invocation**: `${lib.getExe self'.packages.myNoctalia} ipc call <target> <function>` (used in niri keybinds and from shell)
- **Spawn-at-startup**: handled by niri's `spawn-at-startup`

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

IPC uses the Quickshell `ipc call` mechanism. The general pattern:

```bash
${lib.getExe self'.packages.myNoctalia} ipc call <target> <function> [args...]
```

Common targets: `launcher`, `volume`, `media`, `brightness`, `wallpaper`, `darkMode`, `colorScheme`, `bar`, `dock`, `notifications`, `lockScreen`, `sessionMenu`, `settings`, `controlCenter`, `wifi`, `bluetooth`, `powerProfile`, `toast`, `state`.

For the full IPC command reference, see **references/ipc-commands.md**.

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

## Reference Files

Load on demand based on what the user is doing.

- **references/ipc-commands.md** — full IPC catalog: launcher, settings, volume, media, brightness, network, bluetooth, power, bar, dock, notifications, wallpaper, theme, toast, state, plugins
- **references/configuration.md** — noctalia.json schema, bar types, widgets, launcher providers, plugin system, required NixOS services

---

## Troubleshooting

- **Noctalia not starting**: Check `pgrep -a quickshell` — if `.quickshell-wrapped` not in the output, spawn-at-startup didn't fire; also check `journalctl --user` for QML errors
- **IPC not responding**: `noctalia-shell ipc show` to verify endpoints; ensure `WAYLAND_DISPLAY` is set in the calling shell
- **GUI settings not persisting**: Using wrapper-modules without `outOfStoreConfig` — config is in the immutable Nix store; add `outOfStoreConfig` to enable mutable config
- **Settings lost after rebuild**: Same issue as above — without `outOfStoreConfig`, each rebuild overwrites the settings
- **Color scheme not applying**: Check `colorSchemes.useWallpaperColors` and `generationMethod`; run `ipc call colorScheme set $theme` to force a theme
- **Blur not working**: Requires niri 26.04+; check `background-effect` in layer-rules matches the correct namespace regex
- **Layer not blurring**: The regex in `matches.namespace` must match — use `^noctalia-(background|launcher-overlay|dock)-.*$` exactly
