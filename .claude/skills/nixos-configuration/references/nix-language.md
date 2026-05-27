# Nix Language

## Types

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

## Attribute Sets

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

## let / with / inherit

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

## Functions

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

## String Interpolation

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

## Key Operators

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

## nixpkgs Helpers (commonly used in modules)

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
