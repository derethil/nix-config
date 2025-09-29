{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkForce;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.mac-app-util;
in {
  options.glace.tools.mac-app-util = {
    enable = mkBoolOpt pkgs.stdenv.isDarwin "Whether to enable mac-app-util for Darwin systems.";
  };

  # Conditionally enable the mac-app-util.homeManagerModules.default option  based on the configuration
  # The mac-app-util.darwinModules.default module is enabled by default by mac-app-util if included
  config.targets.darwin.mac-app-util.enable = mkForce cfg.enable;
}
