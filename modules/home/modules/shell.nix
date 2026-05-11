{ self, inputs, ... }: {
  flake.homeModules.shell = { ... }: {
    programs.bash = {
      enable = true;

      shellAliases = {
        ls = "lsd";
        rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#myMachine";
      };

      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"
        eval "$(starship init bash)"
      '';
    };
  };
}
