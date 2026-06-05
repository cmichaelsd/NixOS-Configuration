{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.home-manager.nixosModules.home-manager
      # machine-specific
      self.nixosModules.myMachineHardware
      self.nixosModules.myMachineHardwareModifications
      self.nixosModules.myMachineBoot
      self.nixosModules.myMachineNetworking

      # host-agnostic, shared modules
      self.nixosModules.nix
      self.nixosModules.locale
      self.nixosModules.security
      self.nixosModules.services
      self.nixosModules.users
      self.nixosModules.packages
      self.nixosModules.fonts
      self.nixosModules.desktop
      self.nixosModules.home
      self.nixosModules.niri
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
