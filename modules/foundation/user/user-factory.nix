{
  self,
  lib,
  ...
}: let
  inherit (lib) mkDefault optional mkIf;
in {
  config.flake.factory.user = {
    name,
    passwordSecret,
    fullName ? "",
    email ? "",
    uid ? 1000,
    extraGroups ? [],
    superuser ? true,
    primary ? true,
  }: let
    internal-user = {inherit name fullName email;};
    module-name = "user-${name}";
  in {
    # NIXOS

    nixos.${module-name} = {config, ...}: {
      imports = [
        self.modules.nixos.primary-user
        self.modules.nixos.normal-users
        self.modules.nixos.secrets
      ];

      home-manager.users.${name}.imports = [
        self.modules.homeManager.${module-name}
      ];

      internal.users.normalUsers = [name];

      users = {
        mutableUsers = false;
        users.${name} = {
          inherit name uid;
          isPrimary = mkDefault primary;
          home = "/home/${name}";
          isNormalUser = true;
          description = fullName;
          group = "users";
          extraGroups = extraGroups ++ optional superuser "wheel";
          hashedPasswordFile = config.sops.secrets.${passwordSecret}.path;
        };
      };

      sops = {
        secrets.${passwordSecret}.neededForUsers = true;
      };

      nix = {
        settings.trusted-users = [name];
      };

      services = {
        accounts-daemon.enable = true;
      };

      internal.boot.impermanence.extraDirectories = ["/var/lib/AccountsService"];
    };

    # DARWIN

    darwin.${module-name} = {
      imports = [
        self.modules.darwin.secrets
        self.modules.darwin.normal-users
      ];

      home-manager.users.${name}.imports = [
        self.modules.homeManager.${module-name}
      ];

      internal.users.normalUsers = [name];

      users.users.${name} = {
        inherit name;
        home = "/Users/${name}";
      };

      system = {
        primaryUser = mkIf superuser name;
      };

      nix = {
        settings.trusted-users = [name];
      };
    };

    # HOME MANAGER

    homeManager.${module-name} = {pkgs, ...}: {
      internal.user = internal-user;

      imports = [
        self.modules.generic.user-options
        self.modules.homeManager.user-dirs
      ];

      home = {
        username = name;
        homeDirectory =
          if pkgs.stdenv.isDarwin
          then "/Users/${name}"
          else "/home/${name}";
      };
    };
  };
}
