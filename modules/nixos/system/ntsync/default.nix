{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.glace.system.ntsync;
in {
  options.glace.system.ntsync = {
    enable = lib.mkEnableOption "Enable ntsync support";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = ["ntsync"];

    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];

    assertions = [
      {
        assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
        message = "Option `glace.programs.ntsync.enable` requires Linux 6.14+.";
      }
    ];
  };
}
