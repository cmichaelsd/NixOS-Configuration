{ self, inputs, ... }: {
  flake.nixosModules.myMachinePackages = { pkgs, ... }: {
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
