{ pkgs, ... }: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
  };
}
