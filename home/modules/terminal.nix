{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile (pkgs.runCommand "starship-tokyo-night" {
      nativeBuildInputs = [ pkgs.gnused ];
    } ''
      ${pkgs.starship}/bin/starship preset tokyo-night -o $out
      sed -i "s/$(printf '\xee\x9c\x91')/❄/g" "$out"
    ''));
  };
  programs.kitty.enable = true;
}
