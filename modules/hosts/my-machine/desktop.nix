{ self, inputs, ... }: {
  flake.nixosModules.myMachineDesktop = { ... }: {
    services = {
      desktopManager = {
        # Enable the KDE Plasma Desktop Environment.
        plasma6.enable = false;
      };

      displayManager = {
        sddm.enable = true;
      };
    };
  };
}
