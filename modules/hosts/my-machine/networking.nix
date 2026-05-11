{ self, inputs, ... }: {
  flake.nixosModules.myMachineNetworking = { ... }: {
    networking = {
      hostName = "nixos";
      networkmanager.enable = true;

      firewall = {
        # allowedTCPPorts = [ ... ];
        # allowedUDPPorts = [ ... ];
        # enable = false;
      };
    };
  };
}
