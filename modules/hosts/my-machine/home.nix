{ self, inputs, ... }: {
  flake.nixosModules.myMachineHome = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.cole = import ../../../home/home.nix;
    };
  };
}
