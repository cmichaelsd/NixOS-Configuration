# home-manager

## NixOS Integration

```nix
# In any NixOS module:
home-manager = {
  useGlobalPkgs       = true;   # use system pkgs, not HM's own nixpkgs
  useUserPackages     = true;   # install to users.users.<n>.packages
  extraSpecialArgs    = { inherit inputs; };
  sharedModules       = [ ./hm-shared.nix ];

  users.cole = { config, pkgs, osConfig, ... }: {
    home.stateVersion = "25.11";
    # ...
  };
};
```

`osConfig` inside any HM module = read-only access to NixOS system config.

## Key Home-Manager Options

```nix
# Packages
home.packages = with pkgs; [ htop git ripgrep ];

# Dotfiles
home.file.".config/foo/config".text   = "content";
home.file.".config/foo/config".source = ./config-file;

# Environment
home.sessionVariables.EDITOR = "nvim";
home.sessionPath             = [ "$HOME/.local/bin" ];

# XDG config files
xdg.configFile."app/config".text   = "content";
xdg.configFile."app/config".source = ./config;

# Programs (declarative)
programs.git = {
  enable    = true;
  userName  = "Cole";
  userEmail = "cole@example.com";
};

programs.bash = {
  enable       = true;
  shellAliases = { ls = "lsd"; };
  initExtra    = ''eval "$(starship init bash)"'';
};

# State version — set once at install, never change
home.stateVersion = "25.11";
```
