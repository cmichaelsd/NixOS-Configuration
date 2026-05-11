{ self, inputs, ... }: {
  flake.nixosModules.myMachineHome = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # sharedModules = [ inputs.stylix.homeModules.stylix ];
      users.cole = {
        imports = [
          self.homeModules.packages
          self.homeModules.shell
          self.homeModules.git
          self.homeModules.terminal
          self.homeModules.vscode
          self.homeModules.fcitx5
          # self.homeModules.stylix
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
