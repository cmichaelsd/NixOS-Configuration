# NixOS Configuration Expertise

You are an expert on NixOS configuration, the Nix language, flake-parts, import-tree, and home-manager. When invoked, bring full knowledge of these tools to bear on whatever the user needs.

---

## This User's Setup

- **Flake**: `/etc/nixos/flake.nix` — outputs via `flake-parts.lib.mkFlake` + `import-tree ./modules`
- **Host**: `myMachine` — `flake.nixosConfigurations.myMachine` defined in `modules/hosts/my-machine/default.nix`
- **Rebuild alias**: `rebuild` = `sudo nixos-rebuild switch --flake /etc/nixos#myMachine`
- **Channel**: `nixos-unstable`
- **Home-manager**: integrated as NixOS module (`home-manager.nixosModules.home-manager`), user `cole`
- **Pattern**: one file = one module, exposed via `flake.nixosModules.*` or `flake.homeModules.*`

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

Each NixOS module exposes itself as `flake.nixosModules.myMachine<Feature>`:
```nix
{ self, inputs, ... }: {
  flake.nixosModules.myMachineBoot = { pkgs, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
}
```

Each home-manager module exposes itself as `flake.homeModules.<name>`:
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
3. `import-tree` will auto-discover the new file — no registration needed.

### Adding a New Home Module

1. Create `modules/home/modules/mynewmodule.nix`:
```nix
{ self, inputs, ... }: {
  flake.homeModules.myNewModule = { pkgs, ... }: {
    # home-manager config here
  };
}
```
2. Add `self.homeModules.myNewModule` to the `imports` list in `modules/hosts/my-machine/home.nix`.

---

## Nix Language

### Types

| Type | Example |
|------|---------|
| String | `"hello"` |
| Multiline string | `''line one\nline two''` |
| Integer | `42` |
| Float | `3.14` |
| Boolean | `true` / `false` |
| Null | `null` |
| Path | `/etc/nixos` or `./relative` |
| Attribute set | `{ x = 1; y = "a"; }` |
| List | `[ 1 "foo" ./bar.nix ]` |

### Attribute Sets

```nix
{ x = 1; y = 2; }

# Nested — these are equivalent
{ foo.bar = 1; }
{ foo = { bar = 1; }; }

# Recursive — attrs can reference each other
rec { x = "foo"; y = x + "bar"; }

# Access
set.attr
set."quoted-attr"
set.x or "default"           # returns "default" if x is missing

# Merge — right side wins on conflict
{ a = 1; } // { b = 2; }    # => { a = 1; b = 2; }
{ a = 1; } // { a = 2; }    # => { a = 2; }
```

### let / with / inherit

```nix
let
  x = "foo";
  y = "bar";
in x + y                     # => "foobar"

with pkgs; [ git vim curl ]  # pkgs attrs enter scope

# inherit — pull names into an attrset
let x = 1; y = 2; in { inherit x y; }       # => { x = 1; y = 2; }
{ inherit (pkgs) git vim; }                  # => { git = pkgs.git; vim = pkgs.vim; }
```

### Functions

```nix
# Single argument
x: x + 1

# Curried (multi-arg)
x: y: x + y

# Destructured set — listed attrs required
{ x, y }: x + y

# With defaults
{ x, y ? "default" }: x + y

# Ignore extra attrs (always include ... in module functions)
{ x, y, ... }: x + y

# @-pattern — bind whole set AND destructure
{ x, y, ... } @ args: x + args.z
args @ { x, y, ... }: x + args.z

# NixOS module style
{ config, pkgs, lib, ... }: { ... }
```

### String Interpolation

```nix
"Hello, ${name}!"
"${pkgs.bash}/bin/bash"

# In multiline strings
''
  export PATH=${pkgs.git}/bin:$PATH
  literal ''${not-interpolated}
''
# Leading common whitespace is stripped automatically
```

### Key Operators

| Operator | Meaning |
|----------|---------|
| `set.attr` | attribute access |
| `set ? attr` | has attribute → bool |
| `set.x or fallback` | access with default |
| `//` | merge sets (right wins) |
| `++` | concatenate lists |
| `+` | add numbers / concat strings |
| `->` | logical implication (`!a \|\| b`) |

---

## Builtins

```nix
# Files
builtins.readFile ./file.txt        # → string
builtins.toJSON value               # → JSON string
builtins.fromJSON str               # → Nix value (used for noctalia.json)
builtins.toString x                 # → string (works on int, bool, path, drv)

# Lists
builtins.map f list
builtins.filter pred list
builtins.length list
builtins.elem x list                # → bool
builtins.elemAt list n
builtins.concatLists [[1 2] [3]]    # → [1 2 3]
builtins.concatStringsSep "," ["a" "b"]  # → "a,b"
builtins.sort (a: b: a < b) list

# Attribute sets
builtins.attrNames set              # → sorted list of names
builtins.attrValues set
builtins.hasAttr "key" set          # → bool
builtins.mapAttrs (name: val: ...) set
builtins.listToAttrs [{name="a"; value=1;}]  # → { a = 1; }

# Type checking
builtins.typeOf x                   # "int"|"bool"|"string"|"path"|"null"|"set"|"list"|"lambda"
builtins.isString x
builtins.isList x
builtins.isAttrs x
builtins.isNull x
```

---

## lib Functions

Access as `lib.*` (passed as module arg) or `pkgs.lib.*`.

### Module System

```nix
lib.mkOption {
  type        = lib.types.str;            # required
  default     = "value";
  description = "What this option does.";
  example     = "example-value";
}

lib.mkDefault value    # priority 1000 — easily overridden by bare assignments
lib.mkForce value      # priority 50  — wins over everything
lib.mkOverride n value # explicit priority — lower n = higher precedence

lib.mkIf condition { ... }         # include config block only when true
lib.mkMerge [ block1 block2 ]      # merge multiple config blocks in one module
lib.mkBefore list                  # list ordering
lib.mkAfter list
```

**Priority reference** (lower = higher precedence):
- `mkForce` = 50
- bare assignment = 100
- `mkDefault` = 1000
- option's `default` field = 1500

### Types

```nix
lib.types.str
lib.types.int
lib.types.bool
lib.types.path
lib.types.package
lib.types.lines            # strings merged with newlines
lib.types.listOf t         # list, concatenated across definitions
lib.types.attrsOf t        # attr set, merged per key
lib.types.lazyAttrsOf t    # like attrsOf but lazy
lib.types.nullOr t         # t or null
lib.types.either t1 t2
lib.types.enum ["a" "b"]
lib.types.submodule { options = { ... }; }
lib.types.anything         # any value, merged recursively
lib.types.raw              # pass-through, no merging
```

### Strings

```nix
lib.concatStringsSep sep list    # join with separator
lib.optionalString cond str      # str if cond else ""
lib.hasPrefix prefix str
lib.hasSuffix suffix str
lib.removePrefix prefix str
lib.removeSuffix suffix str
lib.toLower str
lib.toUpper str
lib.escapeShellArg str           # quote single arg for shell
lib.escapeShellArgs list         # quote list of args
lib.splitString sep str          # → list
```

### Lists

```nix
lib.optional cond x          # [x] if cond else []
lib.optionals cond list      # list if cond else []
lib.flatten list             # recursively flatten
lib.any pred list            # → bool
lib.all pred list            # → bool
lib.unique list              # remove duplicates
lib.filter pred list
lib.concatMap f list         # map then flatten one level
lib.take n list
lib.drop n list
lib.last list
lib.range from to            # [from .. to] inclusive
```

### Attribute Sets

```nix
lib.hasAttr name set
lib.attrByPath ["a" "b"] default set   # nested access with default
lib.mapAttrs (name: val: ...) set
lib.filterAttrs (name: val: ...) set
lib.nameValuePair name value           # { name; value; }
lib.listToAttrs [{name="a"; value=1;}]
lib.recursiveUpdate base overlay       # deep merge, overlay wins
lib.removeAttrs set ["key1" "key2"]
lib.mapAttrsToList (name: val: ...) set  # → list
```

### Packages

```nix
lib.getExe pkg               # pkg's main binary path
lib.getExe' pkg "name"       # specific binary from pkg
lib.getBin pkg               # pkg.bin output or pkg itself
```

---

## NixOS Module System

### Module Shape

```nix
{ config, pkgs, lib, options, ... }:
{
  imports = [ ./other.nix ];     # pull in more modules

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

### Option Merging

- **bool/string**: must be unique — error if two modules set same value at same priority
- **`types.lines`**: multiple defs joined with `\n`
- **`types.listOf`**: concatenated across all definitions
- **`types.attrsOf`**: merged per key
- Use `lib.mkForce` to override what another module set
- Use `lib.mkDefault` to provide a low-priority default another module can override

### specialArgs vs `_module.args`

**`specialArgs`** — pass at `nixosSystem` call time:
```nix
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; };
  modules = [ ./configuration.nix ];
}
# In any module: { inputs, self, config, pkgs, ... }: { ... }
```
Available in all modules including `imports = [...]` expressions. Safe for flake inputs.

**`_module.args`** — set from within a module:
```nix
config._module.args.myArg = "value";
# Other modules: { myArg, ... }: { ... }
```
Evaluated after module collection — do NOT use in `imports` (causes infinite recursion).

**Rule**: use `specialArgs` for flake inputs. Use `_module.args` only for inter-module values.

---

## Flake Structure

### flake.nix Schema

```nix
{
  description = "My config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # pin to same nixpkgs
    };
    flake-parts.url  = "github:hercules-ci/flake-parts";
    import-tree.url  = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

### Standard Output Attributes

```nix
{
  # Per-system (via perSystem in flake-parts):
  packages.x86_64-linux.my-pkg = ...;
  devShells.x86_64-linux.default = ...;
  checks.x86_64-linux.my-check = ...;
  formatter.x86_64-linux = ...;

  # Static (via flake block in flake-parts):
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem { ... };
  nixosModules.my-module       = ./module.nix;
  homeModules.my-hm-module     = ./hm.nix;
  overlays.default             = final: prev: { };
}
```

### Input URL Formats

```nix
"github:owner/repo"                    # latest default branch
"github:owner/repo/branch-name"        # specific branch
"github:owner/repo/abc123def"          # pinned commit
inputs.foo.inputs.nixpkgs.follows = "nixpkgs";  # deduplicate
inputs.foo.flake = false;              # non-flake source
```

---

## flake-parts

### mkFlake Structure

```nix
flake-parts.lib.mkFlake { inherit inputs; } {
  systems = [ "x86_64-linux" "aarch64-linux" ];

  perSystem = { pkgs, config, self', inputs', lib, system, ... }: {
    packages.default  = pkgs.callPackage ./pkg.nix {};
    packages.my-tool  = pkgs.callPackage ./tool.nix {};
    devShells.default = pkgs.mkShell { nativeBuildInputs = [ pkgs.git ]; };
    formatter         = pkgs.alejandra;
  };

  flake = {
    nixosConfigurations.my-machine = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/my-machine/default.nix ];
    };
    nixosModules.my-feature = ./modules/my-feature.nix;
    homeModules.my-hm       = ./hm-modules/my-hm.nix;
  };
}
```

### perSystem Arguments

| Argument | Description |
|----------|-------------|
| `pkgs` | `nixpkgs.legacyPackages.${system}` |
| `config` | merged perSystem config for current system |
| `self'` | `self.${attr}.${system}` — current system's own outputs |
| `inputs'` | `inputs.X.packages.${system}` — inputs' per-system outputs |
| `lib` | nixpkgs lib |
| `system` | e.g. `"x86_64-linux"` |

`self'.packages.myNoctalia` is shorthand for `self.packages.${system}.myNoctalia`.

### Accessing perSystem from the flake block

```nix
flake = { withSystem, ... }: {
  nixosConfigurations.my-machine = withSystem "x86_64-linux" ({ pkgs, self', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    }
  );
};
```

---

## import-tree

Recursively discovers all `.nix` files under a directory and returns them as a module list. Files/directories with path components starting with `_` are excluded.

```nix
# In flake.nix:
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);

# In a module's imports:
{ inputs, ... }: {
  imports = [ (inputs.import-tree ./submodules) ];
}
```

Each discovered file receives standard NixOS module args. import-tree adds nothing special — it just collects file paths into an `imports` list.

**Exclusion**: prefix a file or directory with `_` to exclude it:
```
modules/
├── _helpers/          # excluded
│   └── util.nix
└── features/
    └── niri.nix       # included
```

**This user's usage**: `(inputs.import-tree ./modules)` at the top of `mkFlake` — every `.nix` file under `modules/` is auto-discovered. No manual registration needed when adding new files.

---

## home-manager

### NixOS Integration

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

### Key Home-Manager Options

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

---

## nixpkgs Patterns

### Package Lists

```nix
with pkgs; [ git vim curl ]

# Conditional
with pkgs; [ git ] ++ lib.optionals config.services.xserver.enable [ firefox ]
```

### callPackage

```nix
pkgs.callPackage ./package.nix { }
pkgs.callPackage ./package.nix { dep = pkgs.something-else; }
```

### writeShellScriptBin

```nix
pkgs.writeShellScriptBin "my-script" ''
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Hello"
''
```

### Overlay Pattern

```nix
# final = complete final pkg set (use for overridden derivation deps)
# prev  = previous set (use to reference original derivations)
final: prev: {
  my-pkg = final.callPackage ./my-pkg.nix {};
  vim    = prev.vim.override { guiSupport = false; };
}

# Apply in NixOS config:
nixpkgs.overlays = [ (import ./overlays/default.nix) ];

# Apply when building pkgs manually:
pkgs = import nixpkgs {
  inherit system;
  overlays = [ self.overlays.default ];
  config.allowUnfree = true;
};
```

### Unfree Packages

```nix
nixpkgs.config.allowUnfree = true;

# Selective:
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (lib.getName pkg) [ "vscode" "steam" ];
```

### symlinkJoin + makeWrapper

```nix
pkgs.symlinkJoin {
  name = "wrapped-tool";
  paths = [ pkgs.some-tool ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/some-tool \
      --set MY_VAR "value" \
      --prefix PATH : ${pkgs.dep}/bin
  '';
}
```

---

## Common NixOS Options

### Environment

```nix
environment.systemPackages     = with pkgs; [ git wget vim ];
environment.variables          = { EDITOR = "vim"; };    # all sessions + services
environment.sessionVariables   = { XDG_DATA_HOME = "$HOME/.local/share"; };  # login shells
environment.shellAliases       = { ll = "ls -lah"; };
environment.etc."app/config".text = "content";           # writes to /etc/app/config
```

### Boot

```nix
boot.loader.systemd-boot.enable      = true;
boot.loader.systemd-boot.configurationLimit = 10;
boot.loader.efi.canTouchEfiVariables = true;
boot.kernelPackages                  = pkgs.linuxPackages_zen;
boot.kernelParams                    = [ "quiet" "splash" ];
boot.kernelModules                   = [ "kvm-intel" ];
```

### Networking

```nix
networking.hostName              = "nixos";
networking.networkmanager.enable = true;
networking.firewall.enable       = true;
networking.firewall.allowedTCPPorts = [ 80 443 ];
networking.nameservers           = [ "1.1.1.1" ];
```

### Users

```nix
users.users.cole = {
  isNormalUser = true;
  description  = "Cole";
  shell        = pkgs.bash;
  extraGroups  = [ "wheel" "networkmanager" "docker" ];
};
users.mutableUsers = false;   # declarative-only (no passwd/useradd)
```

### Nix Daemon

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

### Security

```nix
security.rtkit.enable = true;         # needed for PipeWire
security.polkit.enable = true;
security.sudo.extraRules = [{
  users    = [ "cole" ];
  commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
}];
```

### Services

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

### i18n

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

### Programs

```nix
programs.niri.enable  = true;
programs.nix-ld.enable = true;    # run unpatched binaries
programs.steam.enable = true;
programs.dconf.enable = true;     # needed by GTK/GNOME apps
```

---

## Rebuild Commands

### nixos-rebuild

| Command | Effect |
|---------|--------|
| `nixos-rebuild switch` | Build, activate now, set default boot entry |
| `nixos-rebuild boot` | Build, set default boot entry, activate on next reboot |
| `nixos-rebuild test` | Build and activate now, do NOT change boot entry |
| `nixos-rebuild build` | Build only → `./result` symlink, no activation |
| `nixos-rebuild dry-activate` | Show what would change, don't apply |
| `nixos-rebuild build-vm` | Build a QEMU VM for testing |

```bash
# This user's alias:
rebuild   # = sudo nixos-rebuild switch --flake /etc/nixos#myMachine

# Debugging:
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --show-trace
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --show-trace -L
sudo nixos-rebuild switch --flake /etc/nixos#myMachine --option eval-cache false
```

### Flake Management

```bash
nix flake update                          # update all inputs
nix flake update nixpkgs                  # update one input
nix flake metadata                        # show lock file state
nix flake show                            # show all flake outputs
nix flake check                           # run checks

# Pin input to specific commit:
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/abc123
```

### Useful nix Commands

```bash
nix build .#packages.x86_64-linux.my-pkg  # build a flake output
nix run nixpkgs#hello                      # run without installing
nix develop                                # enter dev shell
nix eval .#nixosConfigurations.myMachine.config.networking.hostName
nix repl                                   # interactive REPL
nix repl .#                                # REPL with flake outputs loaded
nix-collect-garbage -d                     # delete all old generations
```

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

# Multiple config blocks in one module
config = lib.mkMerge [
  { environment.systemPackages = [ pkgs.git ]; }
  (lib.mkIf config.programs.zsh.enable {
    environment.systemPackages = [ pkgs.zsh-completions ];
  })
];

# Force override a value set by another module
services.foo.setting = lib.mkForce "my-value";

# Low-priority default another module can override
services.foo.port = lib.mkDefault 8080;

# Read a JSON file into Nix (used for noctalia.json)
builtins.fromJSON (builtins.readFile ./config.json)

# Pass inputs to all modules
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; };
  modules = [ ./configuration.nix ];
}
# Then in any module: { inputs, self, config, pkgs, ... }: { ... }

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
