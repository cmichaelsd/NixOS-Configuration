{ ... }: {
  services = {
    desktopManager = {
      # Enable the KDE Plasma Desktop Environment.
      plasma6.enable = true;
    };

    displayManager = {
      sddm.enable = true;
    };
  };
}
