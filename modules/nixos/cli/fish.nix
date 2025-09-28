{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.programs.fish;
  userCfg = config.user;
in {
  options.programs.fish = {
    enable = mkBoolOpt false "Whether to enable fish shell system-wide.";
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.${userCfg.name}.shell = pkgs.fish;
  };
}
