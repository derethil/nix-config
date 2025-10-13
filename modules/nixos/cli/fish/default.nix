{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.cli.fish;
  userCfg = config.glace.user;
in {
  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.${userCfg.name}.shell = pkgs.fish;
  };
}
