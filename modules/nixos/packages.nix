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

      appimage = {
        enable = true;
        binfmt = true; # run AppImages directly (e.g. Monsters & Memories launcher)
      };
    };
  };
}
