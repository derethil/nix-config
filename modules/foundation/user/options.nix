{lib, ...}: let
  inherit (lib) mkOption types;

  normalUsersModule = {
    key = "normalUsers";

    options.internal.users.normalUsers = mkOption {
      default = [];
      description = "List of usernames for normal user accounts.";
      type = types.listOf types.str;
    };
  };
in {
  flake = {
    modules = {
      generic.user-options = {
        key = "user-options";

        options.internal.user = {
          email = mkOption {
            default = "";
            description = "Email address of the primary user.";
            type = types.str;
          };

          fullName = mkOption {
            default = "";
            description = "Full name of the primary user.";
            type = types.str;
          };

          name = mkOption {
            description = "Username of the primary user account.";
            type = types.str;
          };
        };
      };

      nixos.normal-users.imports = [normalUsersModule];
      darwin.normal-users.imports = [normalUsersModule];
    };

    lib.forEachNormalUser = config: f:
      assert lib.assertMsg (config ? internal.users.normalUsers) "forEachNormalUser can only be used within a NixOS or Darwin configuration that includes the normalUsers option.";
        lib.genAttrs config.internal.users.normalUsers f;
  };
}
