{ self, inputs, ... }: {
  flake.nixosModules.myMachineHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd = {
        availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
        kernelModules = [ ];
      };

      kernelModules = [ "kvm-amd" ];

      extraModulePackages = [ ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/283c8d6e-122a-47a9-b4fd-0100d0348000";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/0954-33E0";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/3365055c-d63b-485f-bc26-e123beb9b770"; }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
