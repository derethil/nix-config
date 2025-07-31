{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.cli.fish;
in {
  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.${config.user.name}.shell = pkgs.fish;
    environment.shells = [ pkgs.fish ];
  };
}
