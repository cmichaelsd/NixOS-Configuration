{ ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      vim
      brightnessctl
    ];

    programs = {
      nix-ld.enable = true;
      steam.enable = true;
    };
  };
}
