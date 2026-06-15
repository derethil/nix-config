{
  flake.modules.darwin.keychain = {
    lib,
    config,
    ...
  }: let
    inherit (lib) types mkOption;
  in {
    options.internal.system.keychain = {
      entries = mkOption {
        type = types.listOf (types.submodule {
          options = {
            secretFile = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Path to file containing the secret.";
            };

            service = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Keychain service identifier";
            };

            account = mkOption {
              type = types.str;
              default = "default";
              description = "Keychain account name.";
            };

            comment = mkOption {
              type = types.str;
              default = "";
              description = "Optional comment for the keychain entry.";
            };

            trustedApp = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Path to application that should be trusted to access this keychain item.";
            };
          };
        });
      };
    };
  };
}
