{ ... }: {
  flake.nixosModules.myMachineHardwareModifications = { config, ... }: {
    hardware = {
      i2c.enable = true;

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

    services.xserver.videoDrivers = [ "nvidia" ];

    # NOTE: this machine cannot hold s2idle — it bounces out ~13s after every
    # suspend. Long investigation (masking ACPI GPEs 0x04/0x08/0x10/gpe09, udev
    # power/wakeup=disabled on the USB4 functions, disabling every device wakeup)
    # all FAILED: the waker is a firmware-programmed amd_gpio S0i3 wake pin on
    # pinctrl_amd (IRQ 7), not reachable from Linux. We stopped auto-suspending
    # instead (noctalia suspendTimeout=0). Do not re-add GPE masks or USB4 wakeup
    # udev rules here. Full diagnosis: memory project_noctalia_suspend_wake_cycle.

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
