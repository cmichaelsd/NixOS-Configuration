{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, ... }: {
    # Edit this configuration file to define what should be installed on
    # your system.  Help is available in the configuration.nix(5) man page
    # and in the NixOS manual (accessible by running ‘nixos-help’).
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.myMachineHardware
      self.nixosModules.myMachineHardwareModifications
      self.nixosModules.myMachineBoot
      self.nixosModules.myMachineLocale
      self.nixosModules.myMachineNetworking
      self.nixosModules.myMachineSecurity
      self.nixosModules.myMachineServices
      self.nixosModules.myMachineUsers
      self.nixosModules.myMachinePackages
      self.nixosModules.myMachineNix
      self.nixosModules.myMachineDesktop
      self.nixosModules.myMachineHome
      self.nixosModules.niri
      # self.nixosModules.noctalia
    ];


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
