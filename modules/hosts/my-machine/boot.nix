{ ... }: {
  flake.nixosModules.myMachineBoot = { pkgs, ... }: {
    boot = {
      kernelParams = [
        "nvidia-drm.fbdev=1"

        # NOTE: do NOT re-add acpi_mask_gpe=* to "fix" the s2idle suspend bounce.
        # That whole approach was disproven 2026-07-10: with 0x04/0x08/0x10 (and
        # gpe09) all masked AND every device power/wakeup disabled, the box still
        # bounces out of s2idle in ~13s. The real waker is a firmware-programmed
        # amd_gpio level-triggered S0i3 wake pin (pinctrl_amd / IRQ 7), not any
        # ACPI GPE — no kernel param or sysfs toggle reaches it. We instead stopped
        # auto-suspending (noctalia suspendTimeout=0); screen still locks + blanks.
        # Full diagnosis: memory project_noctalia_suspend_wake_cycle.
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

