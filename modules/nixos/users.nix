{ ... }: {
  flake.nixosModules.users = { ... }: {
    users.users.cole = {
      isNormalUser = true;
      description = "Cole";
      extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
    };

    # Temporary. To tear down: drop this block and the users.work entry in
    # modules/nixos/home.nix, rebuild, then `sudo rm -rf /home/work`.
    # Deliberately not in wheel — see also modules/nixos/security.nix.
    users.users.work = {
      isNormalUser = true;
      description = "Work";
      extraGroups = [ "networkmanager" ];
    };
  };
}
