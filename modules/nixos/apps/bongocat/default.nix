{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.bongocat;
in {
  options.glace.apps.bongocat = {
    enable = mkBoolOpt false "Whether to enable Bongocat :).";
  };

  config = mkIf cfg.enable {
    glace.user.extraGroups = ["input"];

    programs.wayland-bongocat = {
      enable = true;
      autostart = true;

      catXOffset = 24;
      catYOffset = 12;

      catHeight = 48;
      catAlign = "center";

      overlayHeight = 48;
      overlayOpacity = 0;
      overlayPosition = "bottom";

      fps = 60;
      idleFrame = 0;
      keypressDuration = 150;

      idleSleepTimeout = 30;
      enableScheduledSleep = true;
      sleepBegin = "23:00";
      sleepEnd = "07:00";

      # Find input devices with bongocat-find-devices

      inputDevices = [
        "/dev/input/event8"
        "/dev/input/event9"
      ];
    };
  };
}
