{ self, inputs, ... }: {
  flake.nixosModules.myMachineBoot = { pkgs, ... }: {
    boot = {
      kernelParams = [
        "acpi_backlight=native"
        "nvidia-drm.fbdev=1"
      ];

      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };

        efi.canTouchEfiVariables = true;
      };

      kernelPackages = pkgs.linuxPackages_zen;
    };
  };
}

