---
name: niri
description: Expert reference for niri, the scrollable-tiling Wayland compositor — covers its KDL/Nix configuration, layout/input/output settings, window and layer rules, keybindings, animations, IPC (niri msg), xwayland-satellite, and NixOS integration via wrapper-modules. Use whenever the user is editing /etc/nixos/modules/features/niri.nix, asking about niri actions or behavior, debugging window or layer rules, troubleshooting xwayland or IME issues under niri, configuring keybinds, or generally working on their niri setup — also trigger when they describe a tiling/Wayland window-manager problem without naming niri explicitly.
---

# Niri

Niri is a scrollable-tiling Wayland compositor. It arranges windows in an infinite horizontal strip — opening a new window never resizes existing ones, it just extends the strip. Workspaces are dynamic and arranged vertically; each monitor has its own independent workspace stack. Similar in spirit to GNOME PaperWM or KDE Karousel.

**Mental model:**
- Horizontal axis = columns of windows
- Vertical axis = workspaces
- Scroll/move horizontally through columns, switch workspaces vertically
- "Focus ring" = visual indicator on focused window (doesn't affect window size)
- "Border" = visual frame that affects window size/layout

---

## This User's Setup

- **Config**: `/etc/nixos/modules/features/niri.nix` — the source of truth. Read this for the user's current layout, keybinds, opacity, rules, etc. Don't trust snapshots; they drift.
- **Wrapper**: `inputs.wrapper-modules.wrappers.niri.wrap` from `github:BirdeeHub/nix-wrapper-modules` (this is **not** sodiboo's niri-flake — it's a separate library). Settings declared as a Nix attrset get translated to KDL.
- **Modifier key**: `Mod` (Super on TTY, Alt in nested session)
- **Companion services**: noctalia shell, lxqt-policykit, xwayland-satellite, fcitx5 (via the system wrapper at `/run/current-system/sw/bin/fcitx5` — see references/ime-and-quirks.md for why)

---

## Configuration Format

Niri's native format is **KDL** (kdl-lang.org). The wrapper-modules approach generates this from Nix attribute sets.

- Raw KDL path: `$XDG_CONFIG_HOME/niri/config.kdl`
- Live reload: niri reloads on file save. Invalid config preserves the last working state (no crash).
- Validate manually with `niri validate`.

Color formats accepted everywhere: CSS names, `#RRGGBB`, `#RRGGBBAA`, `rgb()`, `rgba()`.

---

## NixOS Integration

```nix
perSystem = { pkgs, lib, self', ... }: {
  packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
    inherit pkgs;
    settings = {
      # all niri settings as Nix attrs
    };
  };
};
```

A `flake.nixosModules.niri` then sets `programs.niri.enable = true` and `programs.niri.package = self.packages.${system}.myNiri`.

**Common system-level packages needed alongside niri:**
- `xwayland-satellite` — X11 app support
- `xdg-desktop-portal-gnome` / `xdg-desktop-portal-gtk` — file picker, screenshare
- `lxqt.lxqt-policykit` / `polkit-kde-agent` — auth dialogs
- A status bar / shell (Noctalia in this user's case)
- A notification daemon (mako, dunst, or Noctalia's built-in)
- A launcher (fuzzel, rofi-wayland, or Noctalia's built-in)

---

## IPC (niri msg)

```bash
niri msg outputs            # list monitors
niri msg --json outputs     # JSON output (use for connector names)
niri msg workspaces
niri msg windows
niri msg focused-window
niri msg action close-window
niri msg action focus-workspace 2
niri msg action spawn -- alacritty
niri msg event-stream       # stream events (debug)
niri msg --json event-stream
```

Socket lives at `$NIRI_SOCKET`. JSON requests can be sent programmatically.

---

## Xwayland

Since niri 25.08, xwayland-satellite is auto-managed. Set `xwayland-satellite.path` in the config and niri spawns/restarts it. Requires xwayland-satellite >= 0.7.

Verify it's running: `journalctl --user -u niri | grep "X11 socket"`

---

## Reference Files

Read these on demand — don't load them speculatively.

- **references/configuration.md** — `layout`, `input`, `outputs`, `animations`, `cursor`, `environment`, miscellaneous top-level options
- **references/window-and-layer-rules.md** — full window-rule and layer-rule matcher/property reference
- **references/keybindings.md** — bind syntax, all actions, modifiers, mouse/scroll binds, bind properties
- **references/ime-and-quirks.md** — fcitx5/Korean input setup, application-specific quirks (Electron, Java, etc.), troubleshooting

---

## Troubleshooting (quick triage)

- **Config not applying**: `niri validate` for KDL syntax errors
- **Black screen / no panel**: `journalctl --user -u niri`
- **Xwayland apps missing**: check xwayland-satellite is in PATH and niri >= 25.08
- **Cursor invisible**: `xcursor-theme` set and the cursor package installed
- **Portals not working**: `xdg-desktop-portal-gnome` or `-gtk` installed, `xdg.portal.enable = true`
- **NVIDIA**: requires kernel modesetting (`nvidia-drm.modeset=1`) and GBM-supporting drivers
- For IME-specific issues, see references/ime-and-quirks.md
