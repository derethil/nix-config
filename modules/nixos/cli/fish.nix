{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.cli.fish;
  userCfg = config.glace.user;
in {
  options.cli.fish = {
    enable = mkBoolOpt false "Whether to enable fish shell system-wide.";
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.${userCfg.name}.shell = pkgs.fish;
  };
}
