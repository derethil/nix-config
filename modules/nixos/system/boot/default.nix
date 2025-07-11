{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.system.boot;
in {
  options.system.boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable the boot loader.";
    timeout = mkOpt int 5 "Timeout (in seconds) for the bootloader.";
    plymouth.enable = mkBoolOpt false "Whether or not to enable Plymouth boot splash.";
  };

  config = mkIf cfg.enable {
    consoleLogLevel = mkIf cfg.plymouth.enable 3;

    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.timeout = cfg.timeout;
      efi.canTouchEfiVariables = true;
    };

    plymouth = {
      enable = cfg.plymouth.enable;
    };

    kernelParams = mkIf cfg.plymouth.enable [
      "quiet"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
  };
}
