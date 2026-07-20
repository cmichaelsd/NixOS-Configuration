{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }:
    let
      # Diagnostic: passive idle observer. It does NOT change any power state —
      # it only echoes a tagged line every time the session goes idle / wakes,
      # so we can pin down what keeps waking the Noctalia lock screen.
      # Read it with:  journalctl --user -t idle-logger
      idleLogger = pkgs.writeShellScriptBin "idle-logger" ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 30   'echo "IDLE   session reached idle"' \
          resume       'echo "RESUME session woke (activity reset the idle timer)"' \
          before-sleep 'echo "SLEEP  system is suspending"' \
          2>&1 | ${pkgs.systemd}/bin/systemd-cat -t idle-logger
      '';
    in {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        environment = {
          QS_ICON_THEME = "Nordzy";
          XMODIFIERS = "@im=fcitx";
          QT_IM_MODULE = "fcitx";
          NIXOS_OZONE_WL = "1";
        };

        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
          (lib.getExe pkgs.lxqt.lxqt-policykit)
          "/run/current-system/sw/bin/fcitx5"
          (lib.getExe idleLogger)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard = {
          xkb = {
            layout = "us";
          };
          repeat-rate = 40;
          repeat-delay = 250;
        };

        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

        outputs."eDP-1" = {
          mode = "1920x1200@240.002";
          scale = 1.25;
          position = _: { props = { x = 0; y = 0; }; };
        };

        outputs."HDMI-A-1" = {
          mode = "1920x1080@100.000";
          position = _: { props = { x = -1920; y = 0; }; };
          focus-at-startup = _: {};
        };

        layout = {
          gaps = 10;
          focus-ring = {
            active-gradient = _: {
              props = {
                from = "#7aa2f799";
                to = "#bb9af799";
                angle = 45;
              };
            };
          };
        };

        window-rules = [
          {
            geometry-corner-radius = 15;
            clip-to-geometry = true;
            draw-border-with-background = false;
          }

          {
            matches = [{ app-id = "fcitx"; title = "^Fcitx5 Input Window$"; }];
            open-floating = true;
          }

          {
            matches = [{ app-id = "^steam_app_1623730$"; }];
            open-fullscreen = true;
          }

          {
            matches = [{ is-active = false; }];
            opacity = 0.80;
          }

          {
            matches = [{ is-active = true; }];
            opacity = 0.90;
          }
        ];

        layer-rules = [
          {
            # v5 layer namespaces (native rewrite renamed these): bar is
            # noctalia-bar-<name>, panels are noctalia-(panel|attached-panel),
            # plus dock/notification/osd.
            matches = [{ namespace = "^noctalia-(bar-.*|panel|attached-panel|dock|notification|osd)$"; }];
            background-effect = {
              blur = false;
              noise = 0.03;
              saturation = 1.0;
            };
          }
          {
            # v5 renders a dedicated blurred/tinted wallpaper copy on the
            # noctalia-backdrop surface for the overview backdrop (settings:
            # backdrop.enabled = true).
            matches = [{ namespace = "^noctalia-backdrop"; }];
            place-within-backdrop = true;
          }
        ];

        cursor = {
          xcursor-theme = "Nordzy-cursors";
          xcursor-size = 24;

          hide-after-inactive-ms = 10000;
        };

        binds = {
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} msg panel-toggle launcher";
          # Default terminal. warp-terminal is a system package (see
          # modules/nixos/packages.nix); reference the system profile path since
          # it's unfree and not in the niri wrapper's perSystem pkgs.
          "Mod+Return".spawn-sh = "/run/current-system/sw/bin/warp-terminal";
          "Mod+E".spawn-sh = lib.getExe pkgs.nautilus;
          "Mod+Q".close-window = _: {};
          "Mod+F".maximize-column = _: {};
          "Mod+G".fullscreen-window = _: {};
          "Mod+Shift+F".toggle-window-floating = _: {};
          "Mod+C".center-column = _: {};

          "Mod+H".focus-column-left = _: {};
          "Mod+L".focus-column-right = _: {};
          "Mod+K".focus-window-up = _: {};
          "Mod+J".focus-window-down = _: {};

          "Mod+Shift+H".move-column-left = _: {};
          "Mod+Shift+L".move-column-right = _: {};
          "Mod+Shift+K".move-window-up = _: {};
          "Mod+Shift+J".move-window-down = _: {};

          "Mod+Ctrl+K".focus-workspace-up = _: {};
          "Mod+Ctrl+J".focus-workspace-down = _: {};

          "Mod+Ctrl+H".focus-monitor-left = _: {};
          "Mod+Ctrl+L".focus-monitor-right = _: {};
          "Mod+Ctrl+Shift+H".move-column-to-monitor-left = _: {};
          "Mod+Ctrl+Shift+L".move-column-to-monitor-right = _: {};

          "Mod+D".spawn-sh = self.mkWhichKeyExe pkgs [
            { key = "b"; desc = "LibreWolf"; cmd = pkgs.lib.getExe pkgs.librewolf; }
            { key = "d"; desc = "Vesktop"; cmd = pkgs.lib.getExe pkgs.vesktop; }
            { key = "v"; desc = "VSCodium"; cmd = pkgs.lib.getExe pkgs.vscodium-fhs; }
          ];

          "Mod+Shift+S".screenshot = _: {};
          "Mod+Ctrl+S".screenshot-screen = _: {};
          "Mod+Alt+S".screenshot-window = _: {};

          "Mod+T".spawn-sh = "PST=$(TZ=America/Los_Angeles date +'%a %H:%M %Z') KST=$(TZ=Asia/Seoul date +'%a %H:%M %Z') && ${lib.getExe self'.packages.myNoctalia} msg notification-show '{\"summary\":\"Time Zones\",\"body\":\"'\"$KST  |  $PST\"'\",\"timeout_ms\":3000,\"icon\":\"clock\"}'";


          "XF86AudioRaiseVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";                                    
          "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";                                          
          "XF86MonBrightnessUp".spawn-sh = "if [ \"$(niri msg --json focused-output | ${lib.getExe pkgs.jq} -r .name)\" = \"eDP-1\" ]; then ${lib.getExe pkgs.brightnessctl} set 5%+; else ${lib.getExe pkgs.ddcutil} setvcp 10 + 5; fi";
          "XF86MonBrightnessDown".spawn-sh = "if [ \"$(niri msg --json focused-output | ${lib.getExe pkgs.jq} -r .name)\" = \"eDP-1\" ]; then ${lib.getExe pkgs.brightnessctl} set 5%-; else ${lib.getExe pkgs.ddcutil} setvcp 10 - 5; fi";
        };

        extraConfig = ''
          include optional=true "/home/cole/.config/niri/noctalia.kdl"
        '';
      };
    };
  };
}
