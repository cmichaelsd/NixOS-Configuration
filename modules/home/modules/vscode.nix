{ self, inputs, ... }: {
  flake.homeModules.vscode = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium-fhs;
      extensions = with pkgs.vscodium-extensions; [
        jnoortheen.nix-ide
      ];
    }
  };
}