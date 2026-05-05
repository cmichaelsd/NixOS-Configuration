{ self, inputs, lib, ... }: {
  flake.nixosModules.myMachineDesktop = { ... }: {
    services = {
      desktopManager.plasma6.enable = false;
      displayManager.sddm.enable = false;
    };

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
