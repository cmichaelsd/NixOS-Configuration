{ self, inputs, lib, ... }: {
  flake.nixosModules.myMachineDesktop = { ... }: {
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
