{
  flake.modules.darwin.keychain = {lib, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.system.keychain.entries = mkOption {
      type = types.listOf (types.submodule {
        options = {
          account = mkOption {
            default = "default";
            description = "Keychain account name.";
            type = types.str;
          };

          comment = mkOption {
            default = "";
            description = "Optional comment for the keychain entry.";
            type = types.str;
          };

          secretFile = mkOption {
            default = null;
            description = "Path to file containing the secret.";
            type = types.nullOr types.str;
          };

          service = mkOption {
            default = null;
            description = "Keychain service identifier";
            type = types.nullOr types.str;
          };

          trustedApp = mkOption {
            default = null;
            description = "Path to application that should be trusted to access this keychain item.";
            type = types.nullOr types.str;
          };
        };
      });
    };
  };
}
