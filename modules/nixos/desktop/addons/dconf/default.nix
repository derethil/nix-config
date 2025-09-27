{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.desktop.addons.dconf;
in {
  options.desktop.addons.dconf = {
    enable = mkBoolOpt false "Whether to enable dconf.";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
  };
}