{ ... }: {
  flake.nixosModules.security = { ... }: {
    security = {
      rtkit.enable = true;

      polkit.enable = true;

      sudo.extraRules = [
        {
          users = [ "cole" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
