{ pkgs, ... }: {
  home.packages = with pkgs; [
  # dev tools
    terraform
    jdk
    kotlin
    python3
    nodejs
    awscli2
    docker-compose

    #editors
    neovim
    jetbrains.idea-oss
    jetbrains.pycharm-oss
    kdePackages.kate

    #gui apps
    brave
    vesktop
    protonmail-desktop
    libreoffice-fresh
    mpv
    feh

    #cli enhancements
    lsd
    bat
  ];
}
