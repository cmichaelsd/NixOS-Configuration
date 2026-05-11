{ self, inputs, ... }: {
  flake.nixosModules.myMachineBoot = { pkgs, ... }: {
    boot = {
      kernelParams = [
        "acpi_backlight=native"
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

