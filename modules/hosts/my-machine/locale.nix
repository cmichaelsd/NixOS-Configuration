{ self, inputs, ... }: {
  flake.nixosModules.myMachineLocale = { pkgs, lib, ... }: {
    time.timeZone = "Asia/Seoul";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            fcitx5-hangul
            fcitx5-gtk
          ];
        };
      };
      extraLocaleSettings = {
        LC_ADDRESS = "ko_KR.UTF-8";
        LC_IDENTIFICATION = "ko_KR.UTF-8";
        LC_MEASUREMENT = "ko_KR.UTF-8";
        LC_MONETARY = "ko_KR.UTF-8";
        LC_NAME = "ko_KR.UTF-8";
        LC_NUMERIC = "ko_KR.UTF-8";
        LC_PAPER = "ko_KR.UTF-8";
        LC_TELEPHONE = "ko_KR.UTF-8";
        LC_TIME = "ko_KR.UTF-8";
      };
    };
  };
}
