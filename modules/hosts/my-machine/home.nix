{ self, inputs, ... }: {
  flake.nixosModules.myMachineHome = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.cole = {
        imports = [
          self.homeModules.packages
          self.homeModules.shell
          self.homeModules.git
          self.homeModules.terminal
          self.homeModules.vscode
        ];

        home = {
          username = "cole";
          homeDirectory = "/home/cole";
          stateVersion = "25.11";
        };
      };
    };
  };
}
