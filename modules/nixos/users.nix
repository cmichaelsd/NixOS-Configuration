{ ... }: {
  flake.nixosModules.users = { ... }: {
    users.users.cole = {
      isNormalUser = true;
      description = "Cole";
      extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
    };

    # Temporary. To tear down: drop this block and the users.work entry in
    # modules/nixos/home.nix, rebuild, then `sudo rm -rf /home/work`.
    # In wheel for sudo access; NOPASSWD sudo stays cole-only (see modules/nixos/security.nix).
    users.users.work = {
      isNormalUser = true;
      description = "Work";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
    };
  };
}
