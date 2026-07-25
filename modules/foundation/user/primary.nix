{lib, ...}: let
  inherit (lib) attrNames concatStringsSep filterAttrs head length mkEnableOption mkIf mkOption types;
in {
  flake.modules.nixos.primary-user = {config, ...}: {
    key = "primary-user";

    options = {
      internal.primaryUser = mkOption {
        default = "";

        description = ''
          Username of the human this host is primarily for. Consumed by
          host-level features that need to mirror or default to one user
          (greeter configHome, autologin, etc.). Does not preclude
          additional non-primary users on the same host.

          Defaults to "" when no user is marked primary so the assertion
          above produces a readable failure instead of a generic
          "option used but not defined" eval error.
        '';

        type = types.str;
      };

      users.users = mkOption {
        type = types.attrsOf (types.submodule {
          options.isPrimary = mkEnableOption "primary user designation for this host";
        });
      };
    };

    config = let
      primaries = attrNames (filterAttrs (_: u: u.isPrimary) config.users.users);
    in {
      internal.primaryUser = mkIf (primaries != []) (head primaries);

      assertions = [
        {
          assertion = length primaries == 1;

          message = ''
            Expected exactly one primary user; got ${toString (length primaries)}: [${concatStringsSep ", " primaries}].
            Set `primary = false` on all but one user-factory invocation.
          '';
        }
      ];
    };
  };
}
