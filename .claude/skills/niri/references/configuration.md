# Niri Configuration Reference

Covers `layout`, `input`, `outputs`, `animations`, `cursor`, `environment`, and miscellaneous top-level options. All shown as Nix attrsets that the wrapper-modules library translates to KDL.

## Layout

```nix
layout = {
  gaps = 16;                              # logical pixels between windows
  center-focused-column = "never";        # "never" | "always" | "on-overflow"
  always-center-single-column = true;
  empty-workspace-above-first = true;     # extra empty workspace at top
  default-column-display = "normal";      # "normal" | "tabbed"
  background-color = "#003300";

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
        # relative-to = "workspace-view";
      };
    };
  };

  border = {
    # same options as focus-ring but draws an actual border (affects window size)
    active-color = "#ffc87f";
    width = 4;
  };

  shadow = {
    softness = 30;
    spread = 5;
    offset = { x = 0; y = 5; };
    color = "#00000070";
  };

  struts = { left = 64; right = 64; top = 0; bottom = 0; };

  tab-indicator = {
    width = 8;
    position = "right";          # "left" | "right" | "top" | "bottom"
    gap = 5;
    active-color = "#7fc8ff";
    inactive-color = "#505050";
  };
};
```

## Input

```nix
input = {
  keyboard = {
    xkb = {
      layout = "us";
      variant = "colemak_dh_ortho";
      options = "compose:ralt,ctrl:nocaps";
      # file = "~/.config/keymap.xkb";   # custom XKB file
    };
    repeat-delay = 250;     # ms before repeat starts
    repeat-rate = 40;       # chars/sec
    track-layout = "global"; # "global" | "window"
    numlock = true;
  };

  touchpad = {
    tap = true;
    dwt = true;             # disable-while-typing
    dwtp = true;            # disable-while-trackpointing
    natural-scroll = true;
    accel-speed = 0.2;      # -1.0 to 1.0
    accel-profile = "flat"; # "flat" | "adaptive"
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

## Outputs (Monitors)

```nix
outputs."eDP-1" = {
  mode = { width = 1920; height = 1080; refresh = 60.0; };
  # or shorthand string: mode = "1920x1200@240.002";
  scale = 1.5;
  transform = { rotation = 0; };       # 0 | 90 | 180 | 270
  position = { x = 0; y = 0; };
  variable-refresh-rate = "on";        # "off" | "on" | "on-demand"
  focus-at-startup = true;
  backdrop-color = "#001100";
};
```

Get the exact connector name with `niri msg --json outputs`.

## Animations

```nix
animations = {
  # off = true;          # disable all animations
  # slowdown = 3.0;      # global multiplier (default 1.0)

  workspace-switch.spring = { stiffness = 1000; damping-ratio = 1.0; epsilon = 0.0001; };

  window-open.easing = { duration-ms = 150; curve = "ease-out-expo"; };
  window-close.easing = { duration-ms = 150; curve = "ease-out-quad"; };

  horizontal-view-movement.spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
  window-movement.spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
  window-resize.spring = { stiffness = 800; damping-ratio = 1.0; epsilon = 0.0001; };
};
```

**Easing curves**: `linear`, `ease-out-quad`, `ease-out-cubic`, `ease-out-expo`, `cubic-bezier <a> <b> <c> <d>`

**Spring tuning**: `damping-ratio = 1.0` is critically damped (no bounce). Lower oscillates. Lower stiffness = slower. Lower epsilon = sharper stop.

**All animation slots**: `workspace-switch`, `window-open`, `window-close`, `horizontal-view-movement`, `window-movement`, `window-resize`, `config-notification-open-close`, `exit-confirmation-open-close`, `screenshot-ui-open`, `overview-open-close`, `recent-windows-close`

## Cursor

```nix
cursor = {
  xcursor-theme = "Nordzy-cursors";
  xcursor-size = 24;
  hide-when-typing = true;
  hide-after-inactive-ms = 10000;
};
```

## Environment

Top-level `environment` sets variables for processes spawned by niri:

```nix
environment = {
  QS_ICON_THEME = "Nordzy";
  ELECTRON_OZONE_PLATFORM_HINT = "auto";
  NIXOS_OZONE_WL = "1";
  XMODIFIERS = "@im=fcitx";
  QT_IM_MODULE = "fcitx";
};
```

## Miscellaneous Top-Level Options

```nix
prefer-no-csd = true;             # request server-side decorations
screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
clipboard.enable-primary = true;  # middle-click paste

hotkey-overlay = { skip-at-startup = true; };

spawn-at-startup = [
  (lib.getExe self'.packages.myShell)
  # …
];

xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
```
