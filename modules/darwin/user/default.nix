{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;

  cfg = config.glace.user;
in {
  config = {
    users.users.${cfg.name} = {
      inherit (cfg) name home;
      uid = mkIf (cfg.uid != null) cfg.uid;
    };
  };
}
