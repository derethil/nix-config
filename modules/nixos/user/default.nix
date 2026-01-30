{
  lib,
  config,
  ...
}: let
  inherit (lib) types optional;
  inherit (lib.glace) mkOpt mkBoolOpt;
  cfg = config.glace.user;
in {
  options.glace.user = with types; {
    name = mkOpt str "derethil" "The name to use for the user account.";
    fullName = mkOpt str "Jaren Glenn" "The full name of the user.";
    email = mkOpt str "jarenglenn@gmail.com" "The email of the user.";
    uid = mkOpt int 1000 "UID of the user.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    superuser = mkBoolOpt true "Whether the user is a superuser.";
    home = mkOpt str "/home/${cfg.name}" "Home directory of the user";
  };

  config = let
    passwordPath = "users/${cfg.name}/hashedPassword";
  in {
    secrets.${passwordPath} = {
      neededForUsers = true;
    };

    users = {
      mutableUsers = false;
      users.${cfg.name} = {
        inherit (cfg) name uid home;
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${passwordPath}.path;
        group = "users";
        extraGroups = cfg.extraGroups ++ (optional cfg.superuser "wheel");
      };
    };
  };
}
