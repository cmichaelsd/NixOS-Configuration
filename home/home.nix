{ config, pkgs, ... }: {

  imports = [
    ./modules/stylix.nix
    ./modules/packages.nix
    ./modules/terminal.nix
    ./modules/shell.nix
    ./modules/git.nix
  ];

  home = {
    username = "cole";
    homeDirectory = "/home/cole";
    stateVersion = "25.11";
  };
}
