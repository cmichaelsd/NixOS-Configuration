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
      obsidian
      umu-launcher

      # cli enhancements
      lsd
      bat
    ];
  };
}
