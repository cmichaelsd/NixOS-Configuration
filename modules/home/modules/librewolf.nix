{ self, inputs, ... }: {
  flake.homeModules.librewolf = { pkgs, ... }: {
    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf;
      settings = {
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "network.cookie.lifetimePolicy" = 0;
      };
    };
  };
}
