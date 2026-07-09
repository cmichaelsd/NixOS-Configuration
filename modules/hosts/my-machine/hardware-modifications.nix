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
    # NOTE: the trailing \n is required. The ACPI GPE sysfs handler rejects the
    # value without a newline (EINVAL); tmpfiles' `w` writes no newline of its
    # own, so we hand it one via a C-style escape (Nix "\\n" -> literal \n ->
    # tmpfiles resolves it to 0x0a). Without it the write silently fails at boot.
    systemd.tmpfiles.rules = [
      "w /sys/firmware/acpi/interrupts/gpe10 - - - - disable\\n"
    ];

    # The discrete ASMedia USB4/Thunderbolt controller (vendor 0x1b21: U4UP
    # bridge 0x242a, U4P2 bridge 0x242b, UXHC XHCI 0x242c) raises ACPI GPE 0x04
    # (SSDT7 handler self-labeled "FEA-ASL-DiscreteUSB4 \_GPE._L04") the instant
    # the machine enters s2idle, bouncing it back out after ~13s. It retried
    # every 30 min via Noctalia's idle-suspend, relighting the lock screen all
    # night. Diagnosed via pm_wakeup_irq=9 (ACPI SCI) + gpe04 count == suspend
    # count + the USB4 XHCI stuck in runtime_status=error. Disabling wakeup on
    # these three functions disarms the GPE 0x04 wake while leaving USB4/TB
    # hotplug working whenever the system is awake. ACTION add re-applies if the
    # (flaky) XHCI rebinds. See also the gpe10 SD-reader fix above.
    services.udev.extraRules = ''
      ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1b21", ATTR{device}=="0x242a", ATTR{power/wakeup}="disabled"
      ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1b21", ATTR{device}=="0x242b", ATTR{power/wakeup}="disabled"
      ACTION=="add|change", SUBSYSTEM=="pci", ATTR{vendor}=="0x1b21", ATTR{device}=="0x242c", ATTR{power/wakeup}="disabled"
    '';

    environment.sessionVariables = {
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
    };
  };
}
