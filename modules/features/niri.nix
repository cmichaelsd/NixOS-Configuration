{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
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
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard = {
          xkb = {
            layout = "us";
          };
          repeat-rate = 40;
          repeat-delay = 250;
        };

        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";

        outputs."eDP-1" = {
          mode = "1920x1200@240.002";
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
            geometry-corner-radius = 20;
            clip-to-geometry = true;
          }

          {
            matches = [{ app-id = "fcitx"; title = "^Fcitx5 Input Window$"; }];
            open-floating = true;
          }

          {
            matches = [{ is-active = false; }];
            opacity = 0.80;
          }

          {
            matches = [{ is-active = true; }];
            opacity = 0.90;
            draw-border-with-background = false;
          }
        ];

        layer-rules = [
          {
            matches = [{ namespace = "^noctalia-(background|launcher-overlay|dock)-.*$"; }];
            background-effect = {
              blur = true;
              noise = 0.03;
              saturation = 1.0;
            };
          }
        ];

        cursor = {
          xcursor-theme = "Nordzy-cursors";
          xcursor-size = 24;

          hide-after-inactive-ms = 10000;
        };

        binds = {
          "Mod+S".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          "Mod+Return".spawn-sh = lib.getExe pkgs.foot;
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

          "XF86AudioRaiseVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";                                    
          "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";                                          
          "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 5%+";                                                              
          "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} set 5%-";   
        };
      };
    };
  };
}
