{ self, inputs, ... }: {
  flake.nixosModules.myMachineUsers = { ... }: {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.cole = {
      isNormalUser = true;
      description = "Cole";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
    };
  };
}
