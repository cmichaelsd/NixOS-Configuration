---
name: nixos-configuration
description: Expert reference for the user's NixOS flake at /etc/nixos — flake-parts + import-tree layout, the myMachine host module pattern, home-manager integration, plus general Nix language, lib functions, builtins, and common NixOS options. Use whenever the user is editing files under /etc/nixos/modules/, adding a new NixOS or home-manager module, rebuilding the system, debugging Nix evaluation errors, working with flake inputs/outputs/overlays, or asking how to wire something into their config — also trigger when they describe a system-level change (boot, services, packages, users, kernel, drivers) without explicitly saying 'NixOS'.
---

# NixOS Configuration

This user's NixOS flake lives at `/etc/nixos`. It uses **flake-parts** to compose outputs and **import-tree** to auto-discover every `.nix` file under `modules/`. The convention is one file = one module, each exposed via `flake.nixosModules.*` or `flake.homeModules.*`. Adding a feature usually means dropping a new file in the right directory and adding one line to a list of imports.

---

## This User's Setup

- **Flake**: `/etc/nixos/flake.nix` — outputs via `flake-parts.lib.mkFlake` + `import-tree ./modules`
- **Host**: `myMachine` — `flake.nixosConfigurations.myMachine` defined in `modules/hosts/my-machine/default.nix`
- **Rebuild alias**: `rebuild` = `sudo nixos-rebuild switch --flake /etc/nixos#myMachine`
- **Channel**: `nixos-unstable`
- **Home-manager**: integrated as NixOS module (`home-manager.nixosModules.home-manager`), user `cole`

### File Layout

```
/etc/nixos/
├── flake.nix
├── flake.lock
└── modules/
    ├── parts.nix                          # systems = [x86_64-linux, ...]
    ├── home/
    │   ├── options.nix                    # declares flake.homeModules option
    │   └── modules/
    │       ├── git.nix                    # flake.homeModules.git
    │       ├── packages.nix               # flake.homeModules.packages
    │       ├── shell.nix                  # flake.homeModules.shell (bash + starship)
    │       ├── terminal.nix               # flake.homeModules.terminal
    │       └── vscode.nix                 # flake.homeModules.vscode
    ├── features/
    │   ├── niri.nix                       # flake.nixosModules.niri + perSystem myNiri
    │   └── noctalia.nix                   # perSystem myNoctalia
    └── hosts/my-machine/
        ├── default.nix                    # nixosConfigurations.myMachine entry point
        ├── configuration.nix              # imports all myMachine* modules
        ├── hardware.nix                   # myMachineHardware
        ├── hardware-modifications.nix     # myMachineHardwareModifications
        ├── boot.nix                       # systemd-boot, zen kernel
        ├── locale.nix                     # Asia/Seoul, fcitx5+hangul
        ├── networking.nix                 # hostName=nixos, networkmanager
        ├── security.nix                   # rtkit, polkit, NOPASSWD sudo
        ├── services.nix                   # pipewire, flatpak, xdg portals, docker
        ├── users.nix                      # users.users.cole
        ├── packages.nix                   # systemPackages, nix-ld, steam
        ├── nix.nix                        # flakes, weekly gc, allowUnfree
        ├── desktop.nix                    # regreet greeter
        └── home.nix                       # home-manager config, imports homeModules
```

### Module Naming Convention

NixOS modules expose themselves as `flake.nixosModules.myMachine<Feature>`:
```nix
{ self, inputs, ... }: {
  flake.nixosModules.myMachineBoot = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
}
```

Home-manager modules expose themselves as `flake.homeModules.<name>`:
```nix
{ self, inputs, ... }: {
  flake.homeModules.shell = { ... }: {
    programs.bash.enable = true;
  };
}
```

### Adding a New NixOS Module

1. Create `modules/hosts/my-machine/mynewfeature.nix`:
   ```nix
   { self, inputs, ... }: {
     flake.nixosModules.myMachineMyNewFeature = { pkgs, lib, ... }: {
       # config here
     };
   }
   ```
2. Add `self.nixosModules.myMachineMyNewFeature` to the `imports` list in `modules/hosts/my-machine/configuration.nix`.
3. `import-tree` auto-discovers the file itself — no registration step beyond that.

### Adding a New Home-Manager Module

1. Create `modules/home/modules/mynewmodule.nix`:
   ```nix
   { self, inputs, ... }: {
     flake.homeModules.myNewModule = { pkgs, ... }: {
       # home-manager config here
     };
   }
   ```
2. Add `self.homeModules.myNewModule` to `imports` in `modules/hosts/my-machine/home.nix`.

---

## Basic Module Shape

```nix
{ config, pkgs, lib, options, ... }:
{
  imports = [ ./other.nix ];

  options.my.feature.enable = lib.mkOption {
    type    = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.my.feature.enable {
    environment.systemPackages = [ pkgs.git ];
  };
}
```

When only setting config (no custom options), omit the split:
```nix
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.git ];
}
```

Always include `...` in the destructured argset — modules receive many args and the rest must be ignored.

---

## Rebuild

```bash
rebuild   # alias for: sudo nixos-rebuild switch --flake /etc/nixos#myMachine
```

Debugging:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --show-trace
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --show-trace -L
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --option eval-cache false
```

See **references/rebuild.md** for all rebuild variants, flake management, and `nix` commands.

---

## Reference Files

Load on demand based on what the user is doing.

- **references/nix-language.md** — Nix language: types, attrsets, `let`/`with`/`inherit`, functions, string interpolation, operators, builtins, common nixpkgs helpers (`callPackage`, overlays, `writeShellScriptBin`, `symlinkJoin`)
- **references/lib-functions.md** — `lib.*` utilities: `mkOption`/`mkIf`/`mkMerge`/`mkForce`, types, strings, lists, attrs, package helpers
- **references/module-system.md** — option merging rules, `specialArgs` vs `_module.args`, flake schema, flake-parts (`mkFlake`, `perSystem`, `withSystem`), import-tree
- **references/home-manager.md** — HM as a NixOS module, common HM options
- **references/nixos-options.md** — common system options: `environment`, `boot`, `networking`, `users`, `nix`, `security`, `services`, `xdg.portal`, `i18n`, `programs`
- **references/rebuild.md** — `nixos-rebuild` variants, `nix flake` commands, useful `nix` commands

---

## Quick Patterns

```nix
# Conditional package list
environment.systemPackages = with pkgs; [
  git
] ++ lib.optionals config.virtualisation.docker.enable [ pkgs.docker-compose ];

# Conditional config block
config = lib.mkIf config.my.option.enable {
  services.foo.enable = true;
};

# Force override a value set by another module
services.foo.setting = lib.mkForce "my-value";

# Low-priority default another module can override
services.foo.port = lib.mkDefault 8080;

# Read a JSON file into Nix (used for noctalia.json)
builtins.fromJSON (builtins.readFile ./config.json)

# Expose a perSystem package as a nixos option
# (pattern used by niri.nix and noctalia.nix)
{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myThing = inputs.wrapper-modules.wrappers.thing.wrap { inherit pkgs; };
  };
  flake.nixosModules.myThing = { pkgs, ... }: {
    programs.myThing.package = self.packages.${pkgs.stdenv.hostPlatform.system}.myThing;
  };
}
```
