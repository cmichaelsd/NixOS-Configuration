{ ... }: {
  flake.nixosModules.services = { pkgs, lib, ... }: {
    services = {
      xserver = {
        enable = false;
        xkb.layout = "us";
      };

      printing.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      pulseaudio.enable = false;

      flatpak = {
        enable = true;

        remotes = [{
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }];

        update.auto = {
          enable = true;
          onCalendar = "weekly";
        };

        packages = [
          "me.timschneeberger.GalaxyBudsClient"
        ];
      };

      power-profiles-daemon.enable = true;

      upower.enable = true;

      # Firmware updates via LVFS (fwupdmgr). Primary motivation: the Alienware
      # m18 R1's s2idle suspend-bounce is a firmware bug (BIOS-programmed amd_gpio
      # wake pins, unreachable from the kernel) — a BIOS update is the cleanest
      # remaining lever. See .claude/skills/machine-hardware. LVFS coverage for
      # Alienware is spotty, so `fwupdmgr get-updates` may show nothing.
      fwupd.enable = true;

      gnome.gnome-keyring.enable = true;

      gvfs.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.niri = {
        default = lib.mkForce [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "wlr" ];
      };
    };

    virtualisation.docker.enable = true;
  };
}
