{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.addons.dconf;
in {
  options.glace.desktop.addons.dconf = {
    enable = mkBoolOpt false "Whether to enable dconf.";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
  };
}