# Rebuild and Flake Commands

## nixos-rebuild

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

## Flake Management

```bash
nix flake update                          # update all inputs
nix flake update nixpkgs                  # update one input
nix flake metadata                        # show lock file state
nix flake show                            # show all flake outputs
nix flake check                           # run checks

# Pin input to specific commit:
nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/abc123
```

## Useful nix Commands

```bash
nix build .#packages.x86_64-linux.my-pkg  # build a flake output
nix run nixpkgs#hello                      # run without installing
nix develop                                # enter dev shell
nix eval .#nixosConfigurations.myMachine.config.networking.hostName
nix repl                                   # interactive REPL
nix repl .#                                # REPL with flake outputs loaded
nix-collect-garbage -d                     # delete all old generations
```
