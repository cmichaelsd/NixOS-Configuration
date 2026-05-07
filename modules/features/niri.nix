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
        };

        spawn-at-startup = [
          (lib.getExe self'.packages.myNoctalia)
          (lib.getExe pkgs.lxqt.lxqt-policykit)
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input.keyboard = {
          xkb.layout = "us";
        };

        prefer-no-csd = true;

        layout = {
          gaps = 10;
          focus-ring = {
            active-gradient = _: {
              props = {
                from = "#7aa2f7";
                to = "#bb9af7";
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
