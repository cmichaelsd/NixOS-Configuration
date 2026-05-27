# Common NixOS Options

## Environment

```nix
environment.systemPackages     = with pkgs; [ git wget vim ];
environment.variables          = { EDITOR = "vim"; };    # all sessions + services
environment.sessionVariables   = { XDG_DATA_HOME = "$HOME/.local/share"; };  # login shells
environment.shellAliases       = { ll = "ls -lah"; };
environment.etc."app/config".text = "content";           # writes to /etc/app/config
```

## Boot

```nix
boot.loader.systemd-boot.enable      = true;
boot.loader.systemd-boot.configurationLimit = 10;
boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages                  = pkgs.linuxPackages_zen;
boot.kernelParams                    = [ "quiet" "splash" ];
boot.kernelModules                   = [ "kvm-intel" ];
```

## Networking

```nix
networking.hostName              = "nixos";
networking.networkmanager.enable = true;
networking.firewall.enable       = true;
networking.firewall.allowedTCPPorts = [ 80 443 ];
networking.nameservers           = [ "1.1.1.1" ];
```

## Users

```nix
users.users.cole = {
  isNormalUser = true;
  description  = "Cole";
  shell        = pkgs.bash;
  extraGroups  = [ "wheel" "networkmanager" "docker" ];
};
users.mutableUsers = false;   # declarative-only (no passwd/useradd)
```

## Nix Daemon

```nix
nix.settings = {
  experimental-features = [ "nix-command" "flakes" ];
  auto-optimise-store   = true;
  substituters          = [ "https://cache.nixos.org" "https://mycache.cachix.org" ];
  trusted-public-keys   = [ "cache.nixos.org-1:..." "mycache.cachix.org-1:..." ];
};
nix.gc = {
  automatic = true;
  dates     = "weekly";
  options   = "--delete-older-than 7d";
};
nixpkgs.config.allowUnfree = true;
```

## Security

```nix
security.rtkit.enable = true;         # needed for PipeWire
security.polkit.enable = true;
security.sudo.extraRules = [{
  users    = [ "cole" ];
  commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
}];
```

## Services

```nix
services.pipewire = {
  enable            = true;
  alsa.enable       = true;
  alsa.support32Bit = true;
  pulse.enable      = true;
};
services.pulseaudio.enable = false;   # must be false with PipeWire

services.xserver.enable     = false;  # not needed for Wayland-only
services.printing.enable    = true;
services.openssh.enable     = true;
services.power-profiles-daemon.enable = true;
services.upower.enable      = true;
services.gnome.gnome-keyring.enable = true;
services.gvfs.enable        = true;   # for nautilus / trash support
```

## XDG Portals

```nix
xdg.portal = {
  enable       = true;
  extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
  config.niri = {
    default = lib.mkForce [ "wlr" "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast"  = lib.mkForce [ "wlr" ];
    "org.freedesktop.impl.portal.Screenshot"  = lib.mkForce [ "wlr" ];
  };
};
```

## i18n

```nix
i18n.defaultLocale = "en_US.UTF-8";
i18n.extraLocaleSettings = { LC_TIME = "ko_KR.UTF-8"; };
i18n.inputMethod = {
  enable = true;
  type   = "fcitx5";
  fcitx5 = {
    waylandFrontend = true;
    addons = with pkgs; [ fcitx5-hangul fcitx5-gtk ];
  };
};
time.timeZone = "Asia/Seoul";
```

## Programs

```nix
programs.niri.enable  = true;
programs.nix-ld.enable = true;    # run unpatched binaries
programs.steam.enable = true;
programs.dconf.enable = true;     # needed by GTK/GNOME apps
```
