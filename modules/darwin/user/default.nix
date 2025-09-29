{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.glace) mkOpt mkBoolOpt;

  cfg = config.glace.user;
in {
  options.glace.user = with types; {
    name = mkOpt str "derethil" "The name to use for the user account.";
    fullName = mkOpt str "Jaren Glenn" "The full name of the user.";
    email = mkOpt str "jarenglenn@gmail.com" "The email of the user.";
    uid = mkOpt (nullOr int) 501 "UID of the user.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    superuser = mkBoolOpt true "Whether the user is a superuser.";
    home = mkOpt str "/Users/${cfg.name}" "Home directory of the user";
  };

  config = {
    users.users.${cfg.name} = {
      inherit (cfg) name home;
      uid = mkIf (cfg.uid != null) cfg.uid;
    };
  };
}
