# Module System, Flake Schema, flake-parts, import-tree

## Option Merging

How values from multiple modules combine, per option type:

- **bool / string** (no list/lines/attrs type): must be unique — error if two modules set the same value at the same priority.
- **`types.lines`**: definitions joined with `\n`.
- **`types.listOf`**: concatenated across all definitions.
- **`types.attrsOf`**: merged per key.
- Use `lib.mkForce` to override what another module set.
- Use `lib.mkDefault` to provide a low-priority default another module can override.

## specialArgs vs `_module.args`

**`specialArgs`** — pass at `nixosSystem` call time:

```nix
nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; };
  modules = [ ./configuration.nix ];
}
# In any module: { inputs, self, config, pkgs, ... }: { ... }
```

Available in all modules including `imports = [ ... ]` expressions. Safe for flake inputs.

**`_module.args`** — set from within a module:

```nix
config._module.args.myArg = "value";
# Other modules: { myArg, ... }: { ... }
```

Evaluated after module collection — do **not** use in `imports` (causes infinite recursion).

**Rule of thumb**: `specialArgs` for flake inputs; `_module.args` only for inter-module values.

---

## Flake Schema

### flake.nix

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

Recursively discovers all `.nix` files under a directory and returns them as a module list. Files/directories whose path components start with `_` are excluded.

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
