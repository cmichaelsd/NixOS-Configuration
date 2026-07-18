---
name: noctalia
description: Expert reference for Noctalia v5, the user's Wayland desktop shell (bar, dock, launcher, notifications, lock screen, OSD, control center) — a native C++23 rewrite (no Quickshell/Qt). Covers the official flake + home-manager module (programs.noctalia), the TOML config.toml schema, the `noctalia msg` IPC catalog, bar widgets, layer-shell namespaces, and niri layer-rule integration. Use whenever the user is editing /etc/nixos/modules/features/noctalia.nix or their config.toml, binding a key to a `noctalia msg` call, configuring bar widgets / dock / launcher / control center, theming the shell, or troubleshooting it — also trigger when they describe panel/shell/launcher/notification/OSD behavior without naming Noctalia explicitly.
---

# Noctalia (v5)

Noctalia ("quiet by design") is a Wayland desktop shell — bar, dock, launcher, notifications, lock screen, OSD, control center, and desktop widgets. It runs on top of a Wayland compositor (niri, Hyprland, Sway, etc.).

**v5 is a native C++23 rewrite.** It is built directly on Wayland + OpenGL ES with **no Qt, GTK, or Quickshell dependency** — the UI, rendering, config, and IPC are one cohesive shell. This is a hard break from v4 (which was `noctalia-qs`, a Quickshell/QML fork). v5 is a *fresh install, not an upgrade*.

- GitHub: https://github.com/noctalia-dev/noctalia
- Docs: https://docs.noctalia.dev/v5/
- The running process and the CLI are both `noctalia`. IPC is `noctalia msg …`.

> **Migrating from v4?** Everything changed: package source (wrapper-modules → official flake), config format (`noctalia.json` → `config.toml`), config schema (camelCase → snake_case, different keys), IPC (`ipc call <target> <fn>` → `noctalia msg <command>`), and layer namespaces. Do not carry v4 knowledge forward — treat this skill as the source of truth. If you find v4-isms anywhere, they're stale.

---

## This User's Setup

- **Module**: `modules/features/noctalia.nix` — this is a flake-parts module that does two things:
  1. `perSystem.packages.myNoctalia = inputs.noctalia.packages.<sys>.default` — re-exports the v5 binary under the old name so niri's `spawn-at-startup` and keybinds (which reference `self'.packages.myNoctalia`, `mainProgram = "noctalia"`) keep resolving via `lib.getExe`.
  2. `flake.homeModules.noctalia` — imports `inputs.noctalia.homeModules.default` and sets `programs.noctalia = { enable = true; settings = { … }; }`.
- **Config**: the Nix attrset under `programs.noctalia.settings` is rendered to TOML at `~/.config/noctalia/config.toml`. **This attrset is the source of truth** — read `modules/features/noctalia.nix` directly when answering questions about the current bar layout, theme, wallpaper dir, idle timeouts, etc.
- **Imported by**: `modules/nixos/home.nix` (cole imports `self.homeModules.noctalia`).
- **Launched by**: niri `spawn-at-startup` (NOT the systemd user service — `programs.noctalia.systemd.enable` is off).
- **Cache**: `noctalia.cachix.org` substituter + key are in `modules/nixos/nix.nix`; the flake input has **no** `nixpkgs.follows` (following would disable the cache — see below).

### GUI edits do not persist (source-of-truth rule)
`config.toml` is a **symlink into the read-only Nix store** (`xdg.configFile`). Changes made in the Settings GUI are written to the store path's target and **lost on the next rebuild / logout**. Nix is the source of truth — always change `modules/features/noctalia.nix`, never the GUI, for anything that must stick. (Same discipline as v4.)

### Applying a config change to the running shell
`nixos-rebuild switch` updates `config.toml` on disk, and v5 **hot-reloads most settings via inotify** — so many changes apply live with no restart. Startup-only keys (noted inline in the schema, e.g. `shell.shared_gl_context`) need a shell restart. To force a reload: `noctalia msg config-reload`. To fully restart without logging out: kill the `noctalia` process and re-spawn it (`niri msg action spawn -- <getExe myNoctalia>`), or just log out / back in (re-runs niri's spawn-at-startup).

---

## NixOS Integration (official flake)

```nix
# flake.nix
inputs.noctalia.url = "github:noctalia-dev/noctalia";
# Do NOT add inputs.noctalia.inputs.nixpkgs.follows = "nixpkgs";
# following nixpkgs rebuilds noctalia from source and DISABLES the cachix cache.
# (A faster prebuilt branch exists: github:noctalia-dev/noctalia/cachix)
```

```nix
# modules/nixos/nix.nix — binary cache (skip the from-source compile)
nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
nix.settings.extra-trusted-public-keys = [
  "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
];
```

**Flake outputs** (`inputs.noctalia.*`):
- `packages.<system>.default` — the shell (there's also `.cuda` for CUDA-accelerated builds).
- `homeModules.default` — home-manager module; `imports = [ ./nix/home-module.nix ]` and defaults `programs.noctalia.package` to the flake package.
- `nixosModules.default`, `hjemModules.default` — same for system-level / hjem.
- `overlays.default` — adds `pkgs.noctalia`.

### `programs.noctalia` home-manager options

| Option | Type / default | Notes |
|--------|----------------|-------|
| `enable` | bool | Turns the module on. |
| `package` | package | Auto-defaulted by `homeModules.default` to the flake package; usually leave unset. |
| `settings` | TOML attrset \| TOML string \| path, default `{}` | Rendered to `~/.config/noctalia/config.toml` via `pkgs.formats.toml`. Only written when non-empty. Schema → **references/configuration.md**. |
| `validateConfig` | bool, default `true` | Runs `noctalia config validate` on the generated TOML **at build time** — a malformed config **fails the build**. |
| `customPalettes` | JSON attrset \| string \| path, default `{}` | Each entry `name = {…}` → `~/.config/noctalia/palettes/<name>.json`. Reference by name via `theme.community_palette` / `color-scheme-set`. |
| `systemd.enable` | bool, default false | Adds a `noctalia` user service (`PartOf` the wayland target). This user launches via niri spawn-at-startup instead, so leave off. |

`settings` accepts a **Nix attrset** (the normal case — snake_case keys mirroring `config.toml`), a raw TOML **string**, or a **path** to a `.toml` file.

---

## IPC — `noctalia msg`

v5 replaces v4's `ipc call <target> <function>` with a single flat command:

```bash
noctalia msg <command> [args…]
# discover everything at runtime:
noctalia msg --help
```

Most commands are **hyphenated tokens** (`panel-toggle`, `volume-up`, `dpms-off`, `screenshot-region`). A few group subcommands (`session lock`, `media next`, `plugins list`, `window-switcher`). Commands are organized into five families: **shell**, **surfaces**, **media & UI**, **plugins**, **system controls**.

Quick reference for the most-used:

```bash
noctalia msg panel-toggle launcher          # open/close app launcher
noctalia msg panel-toggle control-center    # open/close control center
noctalia msg session lock                   # lock screen
noctalia msg volume-up 5                     # +5%
noctalia msg brightness-set eDP-1 0.65
noctalia msg notification-show '{"summary":"Hi","body":"…","timeout_ms":3000,"icon":"clock"}'
noctalia msg config-reload
```

**Full catalog → references/ipc-commands.md.**

There is also a non-`msg` CLI surface for setup/build tasks: `noctalia config validate <file>`, `noctalia theme --list-templates`, etc. `noctalia msg` is only for talking to the *running* shell.

---

## Layer-Shell Namespaces (for compositor rules)

v5 surfaces use these `layer-shell` namespaces (match these in niri/Hyprland layer-rules):

| Namespace | Surface |
|-----------|---------|
| `noctalia-bar-<name>` | Bar instances (e.g. `noctalia-bar-main`) |
| `noctalia-panel` | Floating/centered panels (launcher, control center, …) |
| `noctalia-attached-panel` | Bar-attached panels |
| `noctalia-dock` | Dock |
| `noctalia-notification` | Notification toasts |
| `noctalia-osd` | Volume/brightness/etc. OSD popups |
| `noctalia-backdrop` | Blurred/tinted wallpaper copy for compositor overview backdrop |
| `noctalia-wallpaper` | Wallpaper surface |
| `noctalia-window-switcher` | Window switcher overlay |
| `noctalia-desktop-widget-<type>-<id>` | Each desktop widget (e.g. `noctalia-desktop-widget-clock-clock_main`) |

> v4's `noctalia-background-*`, `noctalia-launcher-overlay-*`, `noctalia-overview*` namespaces **no longer exist**. Do not use them.

---

## Niri Integration (this user)

In `modules/features/niri.nix`:

```nix
# Blur + effects on bar/panel/dock/notification/osd surfaces
layer-rules = [
  {
    matches = [{ namespace = "^noctalia-(bar-.*|panel|attached-panel|dock|notification|osd)$"; }];
    # background-effect = { blur = true; noise = 0.03; saturation = 1.0; };
  }
  {
    # Wallpaper-derived backdrop shown behind niri's overview
    matches = [{ namespace = "^noctalia-backdrop"; }];
    place-within-backdrop = true;
  }
];
```

Keybinds spawn `noctalia msg …` (note `spawn-sh` for anything with quoting/pipes):

```nix
"Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} msg panel-toggle launcher";
"Mod+T".spawn-sh = "… ${lib.getExe self'.packages.myNoctalia} msg notification-show '{\"summary\":…,\"body\":…,\"timeout_ms\":3000,\"icon\":\"clock\"}'";
```

`notification-show` fields: `app_name`, `summary`, `body`, `urgency` (low|normal|critical), `timeout_ms`, `icon`, `category`, `desktop_entry`. (v4's `title`/`message`/`timeout` are gone.)

To pair the backdrop with the overview, set `backdrop.enabled = true` in settings and use the `^noctalia-backdrop` layer-rule above.

---

## Reference Files

Load on demand:

- **references/ipc-commands.md** — complete `noctalia msg` catalog (shell, surfaces, media & UI, system controls, plugins), with args.
- **references/configuration.md** — the full `config.toml` schema: every section, key, default, and enum, plus bar widgets, control-center shortcuts, hooks, theming, and per-monitor overrides.

---

## Troubleshooting

- **Shell not starting**: `pgrep -a noctalia` (v5 process is literally `noctalia`, NOT `quickshell`/`.quickshell-wrapped` — that was v4). If absent, niri's spawn-at-startup didn't fire; check `journalctl --user` and `noctalia msg status`.
- **Build fails on config**: `validateConfig = true` runs `noctalia config validate` at build time — the error names the bad key/section. Cross-check against references/configuration.md (snake_case, valid enum values). Set `validateConfig = false` only to isolate a false positive.
- **IPC does nothing**: confirm the shell is running (`noctalia msg status`) and `WAYLAND_DISPLAY` is set in the calling env. `noctalia msg --help` lists valid commands; a typo just no-ops.
- **Setting change didn't apply**: most keys hot-reload via inotify — but startup-only keys (marked inline in the schema) need a restart. Force with `noctalia msg config-reload`; if still stale, restart the shell.
- **GUI changes vanished after rebuild/logout**: expected — `config.toml` is a read-only store symlink. Put the change in `modules/features/noctalia.nix`.
- **Blur/backdrop not working**: needs niri 25.x+; the layer-rule `namespace` regex must match the exact v5 names above (not v4's). Backdrop also needs `backdrop.enabled = true`.
- **Wrong bar widget / widget missing**: widget tokens are snake_case (`active_window`, `power_profile`, `keyboard_layout`, `control-center`) — see the widget list in references/configuration.md; an unknown token is dropped.
