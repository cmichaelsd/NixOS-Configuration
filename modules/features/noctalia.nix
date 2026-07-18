{ self, inputs, ... }: {
  # Noctalia v5 (native rewrite — no longer Quickshell/Qt, ships from the
  # official flake). The v4 wrapper-modules package + noctalia.json JSON config
  # are gone; v5 uses TOML and the upstream home-manager module.

  # Expose the v5 binary under the old name so niri's spawn-at-startup / keybinds
  # (which reference self'.packages.myNoctalia) keep resolving. mainProgram is
  # "noctalia", so lib.getExe returns .../bin/noctalia.
  perSystem = { pkgs, ... }: {
    packages.myNoctalia =
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # Home-manager module: enables Noctalia for the user. The config is a full
  # TOML file exported from the Settings GUI (noctalia-full-config.toml), so this
  # commits the complete resolved config rather than a minimal starter. The
  # upstream module defaults programs.noctalia.package to the flake package and
  # validates the config at build time (validateConfig = true; runs
  # `noctalia config validate`). GUI edits do NOT persist across rebuild — the
  # TOML file is the source of truth. Re-export from the GUI to update it.
  flake.homeModules.noctalia = { ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;

      # Full config as a committed TOML file. `settings` accepts a Nix attrset, a
      # raw TOML string, OR a path to a .toml file — this uses the path form so
      # the export stays verbatim. Rendered to ~/.config/noctalia/config.toml.
      # Schema: https://docs.noctalia.dev/v5. NOTE: idle has lock + screen-off
      # only, NO suspend action — this machine's s2idle firmware bounces out of
      # suspend (see memory project_noctalia_suspend_wake_cycle); keep it that way
      # when re-exporting.
      settings = ./noctalia-full-config.toml;
    };
  };
}
