{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.portals;
in {
  options.glace.services.portals = {
    enable = mkBoolOpt false "Whether to enable XDG portals";
    portals = mkOpt (types.listOf types.package) [] "Extra portals to install.";
    config = mkOpt types.attrs {common.default = "gtk";} "Portal configuration.";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      inherit (cfg) enable config;
      extraPortals = cfg.portals ++ [pkgs.xdg-desktop-portal-gtk];
    };
  };
}
