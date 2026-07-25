{ ... }: {
  flake.homeModules.packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # dev tools
      terraform
      terraform-local
      jdk
      kotlin
      kotlin-language-server
      python3
      pyright
      nodejs
      bun
      typescript
      typescript-language-server
      rustup
      gcc
      awscli2
      docker-compose
      jq
      zip
      gnumake
      gh
      ansible
      qemu
      ipxe
      dig
      protontricks

      # editors
      neovim
      jetbrains.idea-oss
      jetbrains.pycharm-oss
      zed-editor

      # gui apps
      qsynth
      vesktop
      protonmail-desktop
      libreoffice-fresh
      mpv
      obsidian
      umu-launcher
      lutris

      # cli enhancements
      lsd
      bat
    ];
  };
}
