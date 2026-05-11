{ ... }: {
  flake.mkWhichKeyExe = pkgs: menuList: let
    yamlFormat = pkgs.formats.yaml {};
    # wlr-which-key waits for the child process to exit before closing.
    # Wrapping with setsid -f forks into a new session and returns immediately.
    wrapCmd = cmd: "${pkgs.util-linux}/bin/setsid -f ${cmd}";
    wrappedMenu = map (item: item // { cmd = wrapCmd item.cmd; }) menuList;
    configFile = yamlFormat.generate "wlr-which-key-config.yaml" {
      font = "JetBrainsMono Nerd Font 14";
      background = "#1a1b2699";
      color = "#c0caf599";
      border = "#7aa2f799";
      separator = " ➜ ";
      border_width = 2;
      corner_r = 12;
      padding = 16;
      anchor = "center";
      menu = wrappedMenu;
    };
  in pkgs.lib.getExe (pkgs.writeShellScriptBin "wlr-which-key-menu" ''
    exec ${pkgs.lib.getExe pkgs.wlr-which-key} "${configFile}"
  '');
}
