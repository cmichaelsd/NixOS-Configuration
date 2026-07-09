{ ... }: {
  flake.homeModules.shell = { ... }: {
    programs.bash = {
      enable = true;

      shellAliases = {
        ls = "lsd";
        update = "nix flake update --flake /etc/nixos";
        rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#myMachine";
      };

      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"
      '';
    };
  };
}
