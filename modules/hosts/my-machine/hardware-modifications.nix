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

    # The empty SD card reader (Realtek RTS5260, rtsx_pci, mmc0) polls for card
    # insertion and its ACPI wake line (GPE 0x10) yanks the machine out of s2idle
    # ~every 30 min, relighting the Noctalia lock screen all night. Disabling the
    # PCIe port PME did nothing because the wake arrives via this GPE, not PME.
    # This disables GPE 0x10 at boot; the reader still works while awake, it just
    # can't wake the system from suspend. Diagnosed via the idle-logger
    # (journalctl --user -t idle-logger): suspend->~15s->resume loop, not DPMS.
    systemd.tmpfiles.rules = [
      "w /sys/firmware/acpi/interrupts/gpe10 - - - - disable"
    ];

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
