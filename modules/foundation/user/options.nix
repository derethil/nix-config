{lib, ...}: let
  inherit (lib) mkOption types;

  normalUsersModule = {
    key = "normalUsers";
    options.internal.users.normalUsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of usernames for normal user accounts.";
    };
  };
in {
  flake.modules = {
    generic.user-options = {
      key = "user-options";
      options.internal.user = {
        name = mkOption {
          type = types.str;
          description = "Username of the primary user account.";
        };
        fullName = mkOption {
          type = types.str;
          default = "";
          description = "Full name of the primary user.";
        };
        email = mkOption {
          type = types.str;
          default = "";
          description = "Email address of the primary user.";
        };
      };
    };

    nixos.normal-users = {
      imports = [normalUsersModule];
    };

    darwin.normal-users = {
      imports = [normalUsersModule];
    };
  };

  flake.lib.forEachNormalUser = config: f:
    assert lib.assertMsg (config ? internal.users.normalUsers) "forEachNormalUser can only be used within a NixOS or Darwin configuration that includes the normalUsers option.";
      lib.genAttrs config.internal.users.normalUsers f;
}
