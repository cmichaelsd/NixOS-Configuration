{ self, lib, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: let
    greeterNiriConfig = pkgs.writeText "greeter-niri.kdl" ''
      hotkey-overlay {
          skip-at-startup
      }

      output "eDP-1" {
          off
      }

      cursor {
          xcursor-theme "Nordzy-cursors"
          xcursor-size 24
      }
    '';
    greeterStart = pkgs.writeShellScript "greeter-start" ''
      GSK_RENDERER=cairo ${lib.getExe pkgs.regreet}
      ${pkgs.niri}/bin/niri msg action quit -s
    '';
  in {
    programs.dconf.enable = true;

    services.greetd.settings.default_session.command = lib.mkForce
      "${pkgs.niri}/bin/niri --config ${greeterNiriConfig} -- ${greeterStart}";

    programs.regreet = {
      enable = true;
      settings = {
        background = {
          path = "${self}/wallpapers/grainy-ocean.jpeg";
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
          font_name = lib.mkForce "Noto Sans 13";
        };
      };
    };
  };
}
