{self, inputs, ... }: {
  flake.nixosModules.myMachineServices = { pkgs, lib, ... }: {
    services = {
      xserver = {
        enable = false;
        xkb.layout = "us";
        videoDrivers = [ "nvidia" ];
      };

      printing.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
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
