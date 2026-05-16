{ self, inputs, lib, ... }: {
  flake.nixosModules.myMachineDesktop = { pkgs, ... }: let
    greeterSwayConfig = pkgs.writeText "greeter-sway.conf" ''
      output eDP-1 disable
      exec "${lib.getExe pkgs.regreet}; ${pkgs.sway}/bin/swaymsg exit"
    '';
  in {
    programs.dconf.enable = true;

    services.greetd.settings.default_session.command = lib.mkForce
      "${pkgs.sway}/bin/sway --unsupported-gpu --config ${greeterSwayConfig}";

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
