{ ... }: {
  flake.nixosModules.users = { ... }: {
    users.users.cole = {
      isNormalUser = true;
      description = "Cole";
      extraGroups = [ "networkmanager" "wheel" "docker" "i2c" ];
    };
  };
}
