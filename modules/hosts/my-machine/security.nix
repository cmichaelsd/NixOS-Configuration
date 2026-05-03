{ self, inputs, ... }: {
  flake.nixosModules.myMachineSecurity = { ... }: {
    security = {
      rtkit.enable = true;

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
