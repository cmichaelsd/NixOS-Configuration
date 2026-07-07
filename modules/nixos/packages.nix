{ ... }: {
  flake.nixosModules.packages = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      vim
      brightnessctl
      nautilus
      warp-terminal # default terminal (Mod+Return in niri); unfree
      pipewire.jack # provides `pw-jack` wrapper for JACK apps (e.g. qsynth)

      # spell checking
      hunspell
      hunspellDicts.en_US

      # icon/cursor theme for noctalia
      nordzy-icon-theme
      nordzy-cursor-theme
    ];

    programs = {
      nix-ld.enable = true;
      steam.enable = true;

      appimage = {
        enable = true;
        binfmt = true; # run AppImages directly (e.g. Monsters & Memories launcher)
      };
    };
  };
}
