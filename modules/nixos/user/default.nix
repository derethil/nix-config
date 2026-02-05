{
  lib,
  config,
  ...
}: let
  inherit (lib) optional;
  cfg = config.glace.user;
  password = "users/${cfg.name}/hashedPassword";
in {
  config = {
    secrets.${password} = {
      neededForUsers = true;
    };

    users = {
      mutableUsers = false;
      users.${cfg.name} = {
        inherit (cfg) name uid home;
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.${password}.path;
        group = "users";
        extraGroups = cfg.extraGroups ++ (optional cfg.superuser "wheel");
      };
    };
  };
}
