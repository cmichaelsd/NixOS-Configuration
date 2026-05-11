{ self, inputs, ... }: {
  flake.homeModules.vscode = { pkgs, ... }: {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium-fhs;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };
  };
}