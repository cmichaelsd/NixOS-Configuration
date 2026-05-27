# Window and Layer Rules

## Window Rules

```nix
window-rules = [
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
  { matches = [{ is-active = false; }]; opacity = 0.80; }
  { matches = [{ is-active = true;  }]; opacity = 0.90; }

  # Rounded corners on all windows
  { geometry-corner-radius = 20; clip-to-geometry = true; }

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

### Matcher Fields

`app-id` and `title` are regexes. Use `^…$` to anchor.

- `app-id` — Wayland `app_id`
- `title` — window title
- `is-active` — has the active focus ring
- `is-focused` — the single keyboard-focused window
- `is-active-in-column` — most recently focused in its column
- `is-floating`
- `is-urgent`
- `is-window-cast-target`
- `at-startup` — true for first 60 seconds after niri starts

`excludes` uses the same matcher shape and inverts the result.

### Opening Properties (applied once on open)

`open-floating`, `open-focused`, `open-fullscreen`, `open-maximized`, `open-maximized-to-edges`, `open-on-output`, `open-on-workspace`, `default-column-width`, `default-window-height`, `default-column-display`, `default-floating-position`

### Dynamic Properties (continuously applied)

`opacity`, `variable-refresh-rate`, `scroll-factor`, `block-out-from`, `draw-border-with-background`, `focus-ring`, `border`, `shadow`, `tab-indicator`, `geometry-corner-radius`, `clip-to-geometry`, `tiled-state`, `background-effect`, `min-width`, `max-width`, `min-height`, `max-height`

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

  # Noctalia (the user's shell) — blur on background/launcher/dock layers
  {
    matches = [{ namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; }];
    background-effect = { blur = true; noise = 0.03; saturation = 1.0; };
  }
];
```

Match field: `namespace` (regex on the layer surface namespace string).

`background-effect` requires niri 26.04+.
