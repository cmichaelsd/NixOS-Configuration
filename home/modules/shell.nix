{ ... }: {
  programs.bash = {
    enable = true;

    shellAliases = {
      ls = "lsd";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };

    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      eval "$(starship init bash)"
    '';
  };
}
