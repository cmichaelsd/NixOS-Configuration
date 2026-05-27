{ self, inputs, ... }: {
  flake.homeModules.vscode = { pkgs, ... }: {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium-fhs;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        hashicorp.terraform
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        enkia.tokyo-night
      ];
      profiles.default.userSettings = {
        "workbench.colorTheme" = "Tokyo Night Storm";
      };
    };
  };
}