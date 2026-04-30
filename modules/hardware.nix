{ config, ... }: {
  hardware = {
    bluetooth.enable = true;

    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    bluetooth.powerOnBoot = true;
  };
}
