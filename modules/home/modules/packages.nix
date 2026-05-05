{ self, inputs, ... }: {
  flake.homeModules.packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # dev tools
      terraform
      jdk
      kotlin
      python3
      nodejs
      awscli2
      docker-compose

      # editors
      neovim
      jetbrains.idea-oss
      jetbrains.pycharm-oss

      # gui apps
      brave
      vesktop
      protonmail-desktop
      libreoffice-fresh
      mpv
      feh
      foot    

      # cli enhancements
      lsd
      bat

      # other
      hunspell
      hunspellDicts.en_US

      # fonts
      nerd-fonts.jetbrains-mono

      # icon theme for noctalia
      nordzy-icon-theme
    ];
  };
}
