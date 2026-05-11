{ self, inputs, ... }: {
  # flake.nixosModules.noctalia = { pkgs, ... }: {
  #   environment.systemPackages = [
  #     self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia
  #   ];
  # };

  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
    };
  };
}
