{
  description = "Cole's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";

    stylix.url = "github:danth/stylix/release-25.11";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, stylix, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ stylix.homeModules.stylix ];
          home-manager.users.cole = import ./home/home.nix;
        }
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
