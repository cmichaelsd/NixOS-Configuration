{self, inputs, ... }: {
  flake.nixosModules.myMachineServices = { pkgs, ... }: {
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
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    virtualisation.docker.enable = true;
  };
}
