{
  self,
  lib,
  ...
}: let
  inherit (lib) mkDefault mkIf optional;
in {
  config.flake.factory.user = {
    name,
    passwordSecret,
    email ? "",
    extraGroups ? [],
    fullName ? "",
    primary ? true,
    superuser ? true,
    uid ? 1000,
  }: let
    internal-user = {inherit email fullName name;};
    module-name = "user-${name}";
  in {
    # NIXOS

    nixos.${module-name} = {config, ...}: {
      imports = [
        self.modules.nixos.normal-users
        self.modules.nixos.primary-user
        self.modules.nixos.secrets
      ];

      home-manager.users.${name}.imports = [
        self.modules.homeManager.${module-name}
      ];

      internal = {
        boot.impermanence.extraDirectories = ["/var/lib/AccountsService"];
        users.normalUsers = [name];
      };

      nix.settings.trusted-users = [name];
      services.accounts-daemon.enable = true;

      sops = {
        secrets.${passwordSecret}.neededForUsers = true;
      };

      users = {
        mutableUsers = false;

        users.${name} = {
          inherit name uid;
          description = fullName;
          extraGroups = extraGroups ++ optional superuser "wheel";
          group = "users";
          hashedPasswordFile = config.sops.secrets.${passwordSecret}.path;
          home = "/home/${name}";
          isNormalUser = true;
          isPrimary = mkDefault primary;
        };
      };
    };

    # DARWIN

    darwin.${module-name} = {
      imports = [
        self.modules.darwin.normal-users
        self.modules.darwin.secrets
      ];

      home-manager.users.${name}.imports = [
        self.modules.homeManager.${module-name}
      ];

      internal.users.normalUsers = [name];
      nix.settings.trusted-users = [name];
      system.primaryUser = mkIf superuser name;

      users.users.${name} = {
        inherit name;
        home = "/Users/${name}";
      };
    };

    # HOME MANAGER

    homeManager.${module-name} = {pkgs, ...}: {
      imports = [
        self.modules.generic.user-options
        self.modules.homeManager.user-dirs
      ];

      home = {
        homeDirectory =
          if pkgs.stdenv.isDarwin
          then "/Users/${name}"
          else "/home/${name}";

        username = name;
      };

      internal.user = internal-user;
    };
  };
}
