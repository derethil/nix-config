{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.system.sudo;
in {
  options.glace.system.sudo = {
    enable = mkBoolOpt true "Whether to enable sudo for the system.";
  };

  config = mkIf cfg.enable {
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults env_keep += "DISPLAY EDITOR PATH";
      '';
    };

    glace.system.impermanence.extraDirectories = [
      "/var/db/sudo"
    ];
  };
}
