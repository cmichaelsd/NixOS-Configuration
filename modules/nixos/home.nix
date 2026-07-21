{ self, ... }: {
  flake.nixosModules.home = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.cole = {
        imports = [
          self.homeModules.packages
          self.homeModules.shell
          self.homeModules.git
          self.homeModules.vscode
          self.homeModules.fcitx5
          self.homeModules.librewolf
          self.homeModules.theme
          self.homeModules.noctalia
        ];

        home = {
          username = "cole";
          homeDirectory = "/home/cole";
          stateVersion = "25.11";
        };
      };

      users.work = {
        imports = [
          self.homeModules.packages
          self.homeModules.shell
          self.homeModules.vscode
          self.homeModules.fcitx5
          self.homeModules.librewolf
          self.homeModules.theme
          self.homeModules.noctalia
        ];

        programs.git = {
          enable = true;
          settings.user = {
            name = "Cole Michaels";
            email = "cole.michaels@ns.rocks";
          };
        };

        home = {
          username = "work";
          homeDirectory = "/home/work";
          stateVersion = "25.11";
        };
      };
    };
  };
}
