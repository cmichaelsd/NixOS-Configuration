# Keybindings

```nix
binds = {
  # spawn: run a program directly (argv form)
  "Mod+T".spawn = lib.getExe pkgs.alacritty;

  # spawn-sh: run via shell (supports env vars, pipes, ${} interpolation)
  "Mod+Return".spawn-sh = lib.getExe pkgs.foot;

  # Actions — value is `_: {}` (a function ignoring its arg, returning empty attrs)
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
  "Mod+1".focus-workspace = 1;       # numeric arg, not _: {}

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

## Modifiers

`Ctrl`/`Control`, `Shift`, `Alt`, `Super`/`Win`, `Mod` (Super on TTY, Alt nested), `ISO_Level3_Shift`/`Mod5`.

## Mouse / Scroll Binds

`WheelScrollDown`, `WheelScrollUp`, `WheelScrollLeft`, `WheelScrollRight`, `TouchpadScrollDown`, `TouchpadScrollUp`, `MouseLeft`, `MouseRight`, `MouseMiddle`, `MouseForward`, `MouseBack`

## Bind Properties

Annotate a bind with extra behavior:

- `repeat = false` — no key repeat
- `cooldown-ms = 500` — rate limit
- `allow-when-locked = true` — works during screen lock
- `allow-inhibiting = false` — ignore application inhibitors

## All Actions

`spawn`, `spawn-sh`, `quit`, `close-window`, `maximize-column`, `fullscreen-window`, `toggle-window-floating`, `center-column`,
`focus-column-left`, `focus-column-right`, `focus-window-up`, `focus-window-down`,
`move-column-left`, `move-column-right`, `move-window-up`, `move-window-down`,
`focus-workspace`, `focus-workspace-down`, `focus-workspace-up`,
`move-column-to-workspace`, `move-column-to-workspace-down`, `move-column-to-workspace-up`,
`switch-preset-column-width`, `switch-preset-window-height`, `set-column-width`, `set-window-height`,
`screenshot`, `screenshot-screen`, `screenshot-window`,
`toggle-keyboard-shortcuts-inhibit`, `do-screen-transition`, `toggle-window-rule-opacity`,
`focus-monitor-left/right/up/down`, `move-column-to-monitor-left/right/up/down`,
`switch-layout`, `show-hotkey-overlay`
