# Niri Expertise

You are an expert on niri, a scrollable-tiling Wayland compositor. When invoked, bring full knowledge of niri's configuration, behavior, IPC, and NixOS integration to bear on whatever the user needs.

---

## What is Niri

Niri arranges windows in an infinite horizontal strip. Unlike traditional tiling WMs, opening a new window never resizes existing ones — it just extends the strip. Workspaces are dynamic and arranged vertically; each monitor has its own independent workspace stack. This is similar to GNOME PaperWM or KDE Karousel.

**Key mental model:**
- Horizontal axis = columns of windows
- Vertical axis = workspaces
- You scroll/move horizontally through columns, switch workspaces vertically
- "Focus ring" = visual indicator on the focused window (doesn't affect window size)
- "Border" = visual frame that affects window size/layout

---

## This User's Setup

The niri config lives at `/etc/nixos/modules/features/niri.nix`.

It uses `inputs.wrapper-modules.wrappers.niri.wrap` from `github:BirdeeHub/nix-wrapper-modules` — this wraps niri into a custom derivation (`myNiri`) with settings declared in Nix. This is **not** sodiboo's niri-flake; it's a separate wrapper library. The settings Nix attribute set gets translated to KDL config.

Current setup highlights:
- **Shell/panel**: Noctalia (`self'.packages.myNoctalia`) — spawned at startup, also used for IPC (`noctalia ipc call launcher toggle`)
- **Policykit agent**: lxqt-policykit
- **Xwayland**: xwayland-satellite (auto-managed by niri since 25.08)
- **Terminal**: foot (`pkgs.foot`)
- **File manager**: nautilus
- **Audio**: wireplumber (`wpctl`)
- **Brightness**: brightnessctl
- **Cursor/icons**: Nordzy-cursors, Nordzy icon theme
- **Corner radius**: 20px on all windows
- **Opacity**: active windows 0.90, inactive 0.80
- **Layer rules**: blur + noise on noctalia background/launcher-overlay/dock layers
- **Modifier key**: `Mod` (Super on TTY, Alt in nested session)

---

## Configuration Format

Niri's native format is **KDL** (kdl-lang.org). The wrapper-modules approach generates this from Nix attribute sets.

Config file location (raw KDL): `$XDG_CONFIG_HOME/niri/config.kdl`

Live reload: niri automatically reloads on file save. Invalid config preserves last working state (no crash). Validate manually with `niri validate`.

---

## Layout Configuration

```nix
layout = {
  gaps = 16;                              # logical pixels between windows
  center-focused-column = "never";        # "never" | "always" | "on-overflow"
  always-center-single-column = true;     # center when only one column exists
  empty-workspace-above-first = true;     # add empty workspace at top too
  default-column-display = "normal";      # "normal" | "tabbed"
  background-color = "#003300";           # workspace background

  preset-column-widths = [
    { proportion = 0.33333; }
    { proportion = 0.5; }
    { fixed = 1280; }
  ];
  default-column-width = { proportion = 0.5; };

  preset-window-heights = [
    { proportion = 0.33333; }
    { proportion = 0.5; }
  ];

  focus-ring = {
    # "on" to enable, "off" to disable
    active-color = "#7fc8ff";
    inactive-color = "#505050";
    urgent-color = "#ff0000";
    width = 4;
    # OR gradient:
    active-gradient = _: {
      props = {
        from = "#7aa2f7";
        to = "#bb9af7";
        angle = 45;
        # relative-to = "workspace-view";  # gradient relative to whole view
      };
    };
  };

  border = {
    # same options as focus-ring but draws an actual border (affects window size)
    active-color = "#ffc87f";
    width = 4;
  };

  shadow = {
    # "on" to enable
    softness = 30;
    spread = 5;
    offset = { x = 0; y = 5; };
    color = "#00000070";
  };

  struts = {
    left = 64;
    right = 64;
    top = 0;
    bottom = 0;
  };

  tab-indicator = {
    # "on" to enable
    width = 8;
    position = "right";   # "left" | "right" | "top" | "bottom"
    gap = 5;
    active-color = "#7fc8ff";
    inactive-color = "#505050";
  };
};
```

**Color formats**: CSS named colors, `#RRGGBB`, `#RRGGBBAA`, `rgb()`, `rgba()`.

---

## Input Configuration

```nix
input = {
  keyboard = {
    xkb = {
      layout = "us";
      variant = "colemak_dh_ortho";
      options = "compose:ralt,ctrl:nocaps";
      # file = "~/.config/keymap.xkb";  # custom XKB file
    };
    repeat-delay = 250;   # ms before repeat starts
    repeat-rate = 40;     # chars/sec
    track-layout = "global";  # "global" | "window"
    numlock = true;
  };

  touchpad = {
    tap = true;
    dwt = true;              # disable-while-typing
    dwtp = true;             # disable-while-trackpointing
    natural-scroll = true;
    accel-speed = 0.2;       # -1.0 to 1.0
    accel-profile = "flat";  # "flat" | "adaptive"
    scroll-method = "two-finger";  # "two-finger" | "edge" | "no-scroll"
    click-method = "clickfinger";  # "clickfinger" | "button-areas"
    scroll-factor = 1.0;
    disabled-on-external-mouse = true;
  };

  mouse = {
    natural-scroll = false;
    accel-speed = 0.0;
    accel-profile = "flat";
    scroll-factor = 1.0;
    left-handed = false;
    middle-emulation = true;
  };

  focus-follows-mouse.enable = true;
  workspace-auto-back-and-forth = true;
  warp-mouse-to-focus = true;
};
```

---

## Output / Monitor Configuration

```nix
outputs."eDP-1" = {
  mode = { width = 1920; height = 1080; refresh = 60.0; };
  scale = 1.5;
  transform = { rotation = 0; };    # 0 | 90 | 180 | 270
  position = { x = 0; y = 0; };
  variable-refresh-rate = "on";     # "off" | "on" | "on-demand"
  focus-at-startup = true;
  backdrop-color = "#001100";
};
```

Use `niri msg --json outputs` to get the exact connector name for your display.

---

## Window Rules

```nix
window-rules = [
  # Matchers: app-id and title are regexes
  {
    matches = [{ app-id = "^org.gnome.Nautilus$"; }];
    excludes = [{ title = ".*Private.*"; }];
    open-floating = true;
    open-focused = true;
    default-column-width = { fixed = 800; };
    default-window-height = { fixed = 600; };
    open-on-workspace = "files";
    open-on-output = "eDP-1";
  }

  # Opacity by focus state
  {
    matches = [{ is-active = false; }];
    opacity = 0.80;
  }
  {
    matches = [{ is-active = true; }];
    opacity = 0.90;
  }

  # Rounded corners on all windows
  {
    geometry-corner-radius = 20;
    clip-to-geometry = true;
  }

  # Block from screencast
  {
    matches = [{ app-id = "^1Password$"; }];
    block-out-from = "screencast";
  }

  # Picture-in-picture
  {
    matches = [{ app-id = "firefox"; title = "^Picture-in-Picture$"; }];
    open-floating = true;
    default-floating-position = { x = 20; y = 20; relative-to = "bottom-right"; };
  }
];
```

**Matcher fields:**
- `app-id` — regex on the app ID (Wayland app_id)
- `title` — regex on window title
- `is-active` — bool (window has active focus ring)
- `is-focused` — bool (the single keyboard-focused window)
- `is-active-in-column` — bool (most recently focused in its column)
- `is-floating` — bool
- `is-urgent` — bool
- `is-window-cast-target` — bool
- `at-startup` — bool (true for first 60 seconds after niri starts)

**Opening properties** (applied once on open): `open-floating`, `open-focused`, `open-fullscreen`, `open-maximized`, `open-maximized-to-edges`, `open-on-output`, `open-on-workspace`, `default-column-width`, `default-window-height`, `default-column-display`, `default-floating-position`

**Dynamic properties** (continuously applied): `opacity`, `variable-refresh-rate`, `scroll-factor`, `block-out-from`, `draw-border-with-background`, `focus-ring`, `border`, `shadow`, `tab-indicator`, `geometry-corner-radius`, `clip-to-geometry`, `tiled-state`, `background-effect`, `min-width`, `max-width`, `min-height`, `max-height`

---

## Layer Rules

Layer rules apply to layer-shell surfaces (panels, overlays, docks, wallpapers).

```nix
layer-rules = [
  {
    matches = [{ namespace = "^waybar$"; }];
    shadow = true;
    geometry-corner-radius = 8;
    clip-to-geometry = true;
    background-effect = {
      blur = true;
      noise = 0.03;
      saturation = 1.0;
    };
  }
];
```

Match field: `namespace` (regex on layer surface namespace string).

---

## Keybindings

```nix
binds = {
  # spawn: run a program
  "Mod+T".spawn = lib.getExe pkgs.alacritty;

  # spawn-sh: run with shell (supports env vars, pipes)
  "Mod+Return".spawn-sh = lib.getExe pkgs.foot;

  # Actions (use `_: {}` as value)
  "Mod+Q".close-window = _: {};
  "Mod+F".maximize-column = _: {};
  "Mod+G".fullscreen-window = _: {};
  "Mod+Shift+F".toggle-window-floating = _: {};
  "Mod+C".center-column = _: {};

  # Navigation
  "Mod+H".focus-column-left = _: {};
  "Mod+L".focus-column-right = _: {};
  "Mod+J".focus-window-down = _: {};
  "Mod+K".focus-window-up = _: {};
  "Mod+Shift+H".move-column-left = _: {};
  "Mod+Shift+L".move-column-right = _: {};
  "Mod+Shift+J".move-window-down = _: {};
  "Mod+Shift+K".move-window-up = _: {};

  # Workspaces
  "Mod+U".focus-workspace-down = _: {};
  "Mod+I".focus-workspace-up = _: {};
  "Mod+Shift+U".move-column-to-workspace-down = _: {};
  "Mod+1".focus-workspace = 1;

  # Column sizing
  "Mod+R".switch-preset-column-width = _: {};
  "Mod+Shift+R".switch-preset-window-height = _: {};
  "Mod+Minus".set-column-width = "-10%";
  "Mod+Equal".set-column-width = "+10%";

  # Screenshots
  "Print".screenshot = _: {};
  "Ctrl+Print".screenshot-screen = _: {};
  "Alt+Print".screenshot-window = _: {};

  # Media keys
  "XF86AudioRaiseVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
  "XF86AudioLowerVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 5%+";
  "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 5%-";
};
```

**Valid modifiers**: `Ctrl`/`Control`, `Shift`, `Alt`, `Super`/`Win`, `Mod` (Super on TTY, Alt nested), `ISO_Level3_Shift`/`Mod5`

**Scroll/mouse binds**: `WheelScrollDown`, `WheelScrollUp`, `WheelScrollLeft`, `WheelScrollRight`, `TouchpadScrollDown`, `TouchpadScrollUp`, `MouseLeft`, `MouseRight`, `MouseMiddle`, `MouseForward`, `MouseBack`

**Bind properties** (annotate the bind):
- `repeat = false` — no key repeat
- `cooldown-ms = 500` — rate limit
- `allow-when-locked = true` — works during screen lock
- `allow-inhibiting = false` — ignore application inhibitors

**All available actions:**
`spawn`, `spawn-sh`, `quit`, `close-window`, `maximize-column`, `fullscreen-window`, `toggle-window-floating`, `center-column`, `focus-column-left`, `focus-column-right`, `focus-window-up`, `focus-window-down`, `move-column-left`, `move-column-right`, `move-window-up`, `move-window-down`, `focus-workspace`, `focus-workspace-down`, `focus-workspace-up`, `move-column-to-workspace`, `move-column-to-workspace-down`, `move-column-to-workspace-up`, `switch-preset-column-width`, `switch-preset-window-height`, `set-column-width`, `set-window-height`, `screenshot`, `screenshot-screen`, `screenshot-window`, `toggle-keyboard-shortcuts-inhibit`, `do-screen-transition`, `toggle-window-rule-opacity`, `focus-monitor-left/right/up/down`, `move-column-to-monitor-left/right/up/down`, `switch-layout`, `show-hotkey-overlay`

---

## Animations

```nix
animations = {
  # off = true;   # disable all animations
  # slowdown = 3.0;  # global multiplier (default 1.0)

  workspace-switch = {
    spring = { stiffness = 1000; damping-ratio = 1.0; epsilon = 0.0001; };
  };

  window-open = {
    easing = { duration-ms = 150; curve = "ease-out-expo"; };
    # custom-shader = ''
    #   vec4 open_color(vec3 coords_geo, vec3 size_geo) {
    #     ...
    #   }
    # '';
  };

  window-close = {
    easing = { duration-ms = 150; curve = "ease-out-quad"; };
  };

  horizontal-view-movement = {
    spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
  };

  window-movement.spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
  window-resize.spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
};
```

**Easing curves**: `linear`, `ease-out-quad`, `ease-out-cubic`, `ease-out-expo`, `cubic-bezier 0.05 0.7 0.1 1`

**Spring guidance**: `damping-ratio = 1.0` is critically damped (no bounce). Lower values oscillate. Higher values not recommended. Lower stiffness = slower. Lower epsilon = sharper stop.

**All animation slots**: `workspace-switch`, `window-open`, `window-close`, `horizontal-view-movement`, `window-movement`, `window-resize`, `config-notification-open-close`, `exit-confirmation-open-close`, `screenshot-ui-open`, `overview-open-close`, `recent-windows-close`

---

## IPC (niri msg)

```bash
niri msg outputs           # list monitors
niri msg --json outputs    # JSON output
niri msg workspaces        # list workspaces
niri msg windows           # list open windows
niri msg focused-window    # currently focused window
niri msg action close-window          # trigger any action
niri msg action focus-workspace 2
niri msg action spawn -- alacritty
niri msg event-stream      # stream events (debug)
niri msg --json event-stream
```

Socket is at `$NIRI_SOCKET`. You can send JSON requests programmatically.

---

## Miscellaneous Config

```nix
prefer-no-csd = true;  # request apps to use server-side decorations

screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

cursor = {
  xcursor-theme = "Nordzy-cursors";
  xcursor-size = 24;
  hide-when-typing = true;
  hide-after-inactive-ms = 10000;
};

environment = {
  QS_ICON_THEME = "Nordzy";
  ELECTRON_OZONE_PLATFORM_HINT = "auto";
  NIXOS_OZONE_WL = "1";
};

clipboard.enable-primary = true;  # middle-click paste

hotkey-overlay = {
  skip-at-startup = true;
};

xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
```

---

## Xwayland

Since niri 25.08, xwayland-satellite is auto-managed. Set `xwayland-satellite.path` in the config and niri handles spawning/restarting it. Requires xwayland-satellite >= 0.7.

To verify it's running: `journalctl --user -u niri | grep "X11 socket"`

---

## NixOS Integration

This user uses `inputs.wrapper-modules.wrappers.niri.wrap` from `github:BirdeeHub/nix-wrapper-modules`. The pattern:

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

The `programs.niri` NixOS module then uses `package = self.packages.${...}.myNiri`.

For system-level setup (polkit, portals, PAM), the `flake.nixosModules.niri` module sets `programs.niri.enable = true` and `programs.niri.package = myNiri`.

**Common NixOS packages needed alongside niri:**
- `xwayland-satellite` — X11 app support
- `xdg-desktop-portal-gnome` or `xdg-desktop-portal-gtk` — file picker, screenshare
- `lxqt.lxqt-policykit` or `polkit-kde-agent` — authentication dialogs
- `waybar` — status bar
- `swaylock` / `swayidle` — screen lock/idle
- `mako` or `dunst` — notifications
- `fuzzel` / `rofi-wayland` — app launcher

---

## Application Quirks

| App | Problem | Fix |
|-----|---------|-----|
| Electron apps | Don't use Wayland by default | Set `ELECTRON_OZONE_PLATFORM_HINT "auto"` or `--ozone-platform=wayland` |
| VSCode | Some hotkeys broken | Run with `DISPLAY=:0` for keymap queries |
| JetBrains | Java rendering | Set `-Dawt.toolkit.name=WLToolkit` in VM options |
| WezTerm | Zero-size configure event | Add window rule with empty `default-column-width {}` |
| Ghidra / Java apps | Blank under xwayland-satellite | Set `_JAVA_AWT_WM_NONREPARENTING=1` |
| Steam | Black window | Disable GPU-accelerated web views |
| Waybar | Black pixels on rounded corners | Set opacity to `0.99` |
| GTK4 | Dead keys broken since GTK 4.20 | Run fcitx5 or set `GTK_IM_MODULE "simple"` |
| Zen Browser | Screencasting disabled | Set `widget.dmabuf.force-enabled = true` in about:config |

---

## IME / Korean Input (fcitx5 + Hangul)

### NixOS Setup

```nix
# locale.nix
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5 = {
    waylandFrontend = true;   # correct fix for GTK_IM_MODULE conflict — do NOT use mkForce "" instead
    addons = with pkgs; [
      fcitx5-hangul
      fcitx5-gtk
    ];
  };
};
```

### Environment Variables (in niri.nix `environment` block)

```nix
environment = {
  XMODIFIERS = "@im=fcitx";    # required for XWayland apps
  QT_IM_MODULE = "fcitx";      # required for Qt apps
  # DO NOT set GTK_IM_MODULE — GTK4 uses text-input-v3 natively on Wayland
  # setting it causes fcitx5 to warn and can break input
};
```

### Launching fcitx5

Add to `spawn-at-startup` in niri.nix. The NixOS wiki says to use the system wrapper (the `fcitx5` binary in PATH) rather than the package derivation directly. Currently using `lib.getExe pkgs.fcitx5` — if Korean input doesn't work, this may be the cause and the fix is to reference the system wrapper instead.

XKB layout stays as `us` — fcitx5 handles Korean switching internally. Do not add `kr` to the XKB layout.

Default toggle key is `Ctrl+Space`. Change it in `fcitx5-config-qt` if desired (e.g. `Alt+Shift`).

### Known Niri Bug — Input Window Tiling

fcitx5's candidate/input window can appear as a full tiled column in niri instead of a floating popup. Workaround via window rule:

```nix
{
  matches = [{ app-id = "fcitx"; title = "^Fcitx5 Input Window$"; }];
  open-floating = true;
}
```

This is an open issue in niri — the window should not enter the tiled layout at all but currently does.

### Troubleshooting

- `pgrep fcitx5` — check if it's running at all; if not, spawn-at-startup didn't fire it
- If `waylandFrontend = true` is not set, NixOS auto-sets `GTK_IM_MODULE = "fcitx"` which conflicts with Wayland native IME — fcitx5 will show a warning notification
- Do NOT add `fcitx5-hangul` or `fcitx5-gtk` to `environment.systemPackages` directly — let `i18n.inputMethod.fcitx5.addons` manage them or input switching may show "Not available"

---

## Troubleshooting

- **Config not applying**: Run `niri validate` to check for KDL syntax errors
- **Black screen / no panel**: Check `journalctl --user -u niri` for errors
- **Xwayland apps not appearing**: Check xwayland-satellite is in PATH and niri version >= 25.08
- **Cursor invisible**: Ensure `xcursor-theme` is set and the cursor package is installed
- **Portals not working**: Ensure `xdg-desktop-portal-gnome` or `xdg-desktop-portal-gtk` is installed and `services.xdg.portal.enable = true`
- **IME not working (fcitx5)**: Do NOT set `GTK_IM_MODULE` or `QT_IM_MODULE` environment variables in niri config — fcitx5 handles this via its own portal mechanism on Wayland
- **NVIDIA**: Requires kernel modesetting (`nvidia-drm.modeset=1`) and GBM-supporting drivers
