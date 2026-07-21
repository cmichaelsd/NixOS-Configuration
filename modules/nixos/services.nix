{ ... }: {
  flake.nixosModules.services = { pkgs, lib, ... }: {
    services = {

      envfs = {
        enable = true;
        # envfs resolves /bin/<name> against the caller's $PATH, else a fixed
        # fallback path that by default only has `env` + `sh`. Add `bash` so
        # /bin/bash always exists even for callers without bash in PATH
        # (systemd units, #!/bin/bash shebangs in stripped environments).
        extraFallbackPathCommands = ''
          ln -s ${pkgs.bashInteractive}/bin/bash $out/bash
        '';
      };

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

      # Firmware updates via LVFS (fwupdmgr). NB: the Alienware BIOS is NOT on
      # LVFS — it was flashed manually (F12 → BIOS Flash Update; now 1.23.0).
      # fwupd stays for what LVFS *does* cover here: the UEFI dbx Secure-Boot
      # revocation update, and potential NVMe / USB4-TB controller firmware.
      # See .claude/skills/machine-hardware.
      fwupd.enable = true;

      gnome.gnome-keyring.enable = true;

      gvfs.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.niri = {
        default = lib.mkForce [ "gnome" "gtk" ];
        # niri drives screencasting through the GNOME portal; the wlr portal's
        # wlr-screencopy path only ever captured a single frame here (screen
        # share showed a frozen "photo" in Vesktop).
        "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = lib.mkForce [ "gnome" ];
      };
    };

    virtualisation.docker.enable = true;
  };
}
