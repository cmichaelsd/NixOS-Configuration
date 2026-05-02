{ pkgs, ... }: {
  stylix= {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-storm.yaml";
    image = ../../wallpapers/power-lines.png;
    polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 13;
        terminal = 13;
        desktop = 11;
        popups = 11;
      };
    };

    targets = {
      kde.enable = true;
      qt.enable = false;
    };
  };
}
