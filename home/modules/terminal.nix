{ ... }: {
  programs.starship = {
    enable = true;
      #  settings = pkgs.lib.importTOML (pkgs.runCommand "starship-preset" {} ''
      #    ${pkgs.starship}/bin/starship preset gruvbox-rainbow -o $out
    # '');
  };
  programs.kitty.enable = true;
}
