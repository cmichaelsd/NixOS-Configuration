{ ... }: {
  flake.nixosModules.nix = { ... }: {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];

        # Noctalia v5 prebuilt binary cache. Requires the noctalia flake input
        # NOT follow nixpkgs (see flake.nix).
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    nixpkgs.config.allowUnfree = true;
  };
}
