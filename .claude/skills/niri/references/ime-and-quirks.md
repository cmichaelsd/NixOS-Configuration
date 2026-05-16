# IME and Application Quirks

## fcitx5 + Hangul (Korean Input)

### NixOS Setup

```nix
# locale.nix or equivalent
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5 = {
    waylandFrontend = true;   # the correct fix for the GTK_IM_MODULE conflict.
                              # Do NOT do `mkForce ""` on GTK_IM_MODULE instead —
                              # waylandFrontend = true prevents NixOS from auto-setting it.
    addons = with pkgs; [
      fcitx5-hangul
      fcitx5-gtk
    ];
  };
};
```

Do NOT add `fcitx5-hangul` or `fcitx5-gtk` to `environment.systemPackages` directly — let `i18n.inputMethod.fcitx5.addons` manage them, otherwise input switching may show "Not available".

### Environment Variables (in niri's `environment` block)

```nix
environment = {
  XMODIFIERS = "@im=fcitx";    # required for XWayland apps
  QT_IM_MODULE = "fcitx";      # required for Qt apps
  # DO NOT set GTK_IM_MODULE.
  # GTK4 uses text-input-v3 natively on Wayland. Setting GTK_IM_MODULE
  # makes fcitx5 warn and can break input. waylandFrontend = true (above)
  # is what handles the GTK side correctly.
};
```

### Launching fcitx5

Add to `spawn-at-startup` in niri.nix. Use the **system wrapper** path, not `lib.getExe pkgs.fcitx5`:

```nix
spawn-at-startup = [
  "/run/current-system/sw/bin/fcitx5"
  # …
];
```

Why: the system wrapper picks up the `i18n.inputMethod` addons and environment. Bypassing it (by referencing the package's binary directly) misses that wiring and Korean input silently fails.

XKB layout stays as `us` — fcitx5 handles Korean switching internally. Do NOT add `kr` to the XKB layout.

Default toggle key is `Ctrl+Space`. Change it in `fcitx5-config-qt` if desired (e.g. `Alt+Shift`).

### Known Niri Bug — Input Window Tiling

fcitx5's candidate/input popup can appear as a full tiled column instead of a floating popup. Workaround with a window rule:

```nix
{
  matches = [{ app-id = "fcitx"; title = "^Fcitx5 Input Window$"; }];
  open-floating = true;
}
```

This is an open issue in niri — the window shouldn't enter the tiled layout at all.

### Troubleshooting

- `pgrep fcitx5` — is it running? If not, `spawn-at-startup` didn't fire it.
- If `waylandFrontend = true` is missing, NixOS auto-sets `GTK_IM_MODULE = "fcitx"`, which conflicts with native Wayland IME — fcitx5 shows a warning notification.
- If text input works in some apps but not others: usually a missing `QT_IM_MODULE` / `XMODIFIERS` (Qt / XWayland respectively).

---

## Application-Specific Quirks

| App | Problem | Fix |
|-----|---------|-----|
| Electron apps | Don't use Wayland by default | `ELECTRON_OZONE_PLATFORM_HINT = "auto"` or pass `--ozone-platform=wayland` |
| Brave / Chromium opacity broken | Active window washed out | Set `NIXOS_OZONE_WL = "1"` in niri's `environment`; requires re-login |
| VSCode | Some hotkeys broken under Wayland | Run with `DISPLAY=:0` for keymap queries |
| JetBrains IDEs | Java rendering issues | Add `-Dawt.toolkit.name=WLToolkit` to VM options |
| WezTerm | Zero-size configure event on open | Window rule with empty `default-column-width {}` |
| Ghidra / Java apps under xwayland | Blank window | `_JAVA_AWT_WM_NONREPARENTING=1` |
| Steam | Black window | Disable GPU-accelerated web views |
| Waybar | Black pixels on rounded corners | Set window opacity to `0.99` |
| GTK4 | Dead keys broken since GTK 4.20 | Run fcitx5 or set `GTK_IM_MODULE = "simple"` |
| Zen Browser | Screencasting disabled | `widget.dmabuf.force-enabled = true` in about:config |
