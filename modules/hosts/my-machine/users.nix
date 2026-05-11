{ self, inputs, ... }: {
  flake.nixosModules.myMachineUsers = { ... }: {
    users.users.cole = {
      isNormalUser = true;
      description = "Cole";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
    };
  };
}
