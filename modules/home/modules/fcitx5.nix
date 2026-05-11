{ self, inputs, ... }: {
  flake.homeModules.fcitx5 = { ... }: {
    home.file.".config/fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        # Group Name
        Name=Default
        # Layout
        Default Layout=us
        # Default Input Method
        DefaultIM=hangul

        [Groups/0/Items/0]
        # Name
        Name=keyboard-us
        # Layout
        Layout=

        [Groups/0/Items/1]
        # Name
        Name=hangul
        # Layout
        Layout=

        [GroupOrder]
        0=Default
      '';
    };

  };
}
