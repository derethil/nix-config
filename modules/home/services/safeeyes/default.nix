{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.safeeyes;
in {
  options.glace.services.safeeyes = {
    enable = mkBoolOpt false "Whether to enable the Safe Eyes break reminder service.";
  };

  config = mkIf cfg.enable {
    services.safeeyes = {
      enable = true;
    };
  };
}
