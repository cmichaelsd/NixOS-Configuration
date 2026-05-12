{ self, inputs, ... }: {
  flake.nixosModules.myMachineHardwareModifications = { config, ... }: {
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      nvidia = {
        modesetting.enable = true;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        powerManagement.enable = true;
      };

      graphics = {
        enable = true;
        enable32Bit = true;
      };

      cpu = {
        amd.updateMicrocode = true;
      };
    };

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
