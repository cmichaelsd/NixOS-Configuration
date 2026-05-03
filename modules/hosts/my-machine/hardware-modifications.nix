{ self, inputs, ... }: {
  flake.nixosModules.myMachineHardwareModifications = { config, ... }: {
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      cpu = {
        amd.updateMicrocode = true;
      };
    };
  };
}
