{ self, inputs, ... }: {
  flake.homeModules.packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # dev tools
      terraform
      terraform-local
      jdk
      kotlin
      python3
      nodejs
      bun
      awscli2
      docker-compose
      jq
      zip
      gnumake
      gh

      # editors
      neovim
      jetbrains.idea-oss
      jetbrains.pycharm-oss

      # gui apps
      vesktop
      protonmail-desktop
      libreoffice-fresh
      mpv
      feh
      foot
      nautilus

      # cli enhancements
      lsd
      bat

      # other
      hunspell
      hunspellDicts.en_US

      # fonts
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono

      # icon theme for noctalia
      nordzy-icon-theme
      nordzy-cursor-theme
    ];
  };
}
