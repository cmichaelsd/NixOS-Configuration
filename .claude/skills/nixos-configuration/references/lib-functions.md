# lib Functions

Access as `lib.*` (passed as module arg) or `pkgs.lib.*`.

## Module System

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

## Types

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

## Strings

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

## Lists

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

## Attribute Sets

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

## Packages

```nix
lib.getExe pkg               # pkg's main binary path
lib.getExe' pkg "name"       # specific binary from pkg
lib.getBin pkg               # pkg.bin output or pkg itself
```
