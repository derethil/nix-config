{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.internal) mkOpt;

  cfg = config.user;
in {
  options.user = {
    name = mkOpt types.str "derethil" "The user account.";
    fullName = mkOpt types.str "Jaren Glenn" "The full name of the user.";
    email = mkOpt types.str "jarenglenn@gmail.com" "The email of the user.";
    uid = mkOpt (types.nullOr types.int) 501 "The uid for the user account.";
  };

  config = {
    users.users.${cfg.name} = {
      uid = mkIf (cfg.uid != null) cfg.uid;
    };
  };
}

