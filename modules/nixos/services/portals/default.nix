{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  inherit (lib) types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.portals;
in {
  options.glace.services.portals = {
    enable = mkBoolOpt false "Whether to enable XDG portals";
    portals = mkOpt (types.listOf types.package) [] "Extra portals to install.";
    config = mkOpt types.attrs {} "Portal configuration.";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      inherit (cfg) enable config;
      extraPortals = cfg.portals;
    };
  };
}
