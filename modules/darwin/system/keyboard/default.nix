{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.system.keyboard;
in {
  options.system.keyboard = {
    enable = mkBoolOpt false "Whether or not to enable keyboard management.";
  };

  config = mkIf cfg.enable {
    system.keyboard = {
      remapCapsLockToEscape = true;
    };
  };
}
