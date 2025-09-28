{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types optionalAttrs;
  inherit (lib.internal) mkBoolOpt mkOpt;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.nix.config;
in {
  options.nix.config = {
    enable = mkBoolOpt false "Whether to enable Nix configuration optimizations.";
    package = mkOpt types.package pkgs.nixVersions.stable "Which nix package to use.";
    extraTrustedUsers = mkOpt (types.listOf types.str) [] "List of trusted users.";
    garbageCollection = mkBoolOpt false "Whether to enable automatic garbage collection.";
  };

  config = mkIf cfg.enable {
    nix = {
      package = cfg.package;

      optimise =
        {
          automatic = true;
        }
        // optionalAttrs (!isDarwin) {
          persistent = true;
          dates = ["03:45"];
        };

      settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" config.user.name] ++ cfg.extraTrustedUsers;
        fallback = true;
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
        sandbox = "relaxed";
        keep-outputs = true;
        keep-derivations = true;
      };

      gc = mkIf cfg.garbageCollection {
        automatic = true;
        options = "--delete-older-than 7d";
        dates = "weekly";
      };

      inputs = {
        generateRegistryFromInputs = true;
        generateNixPathFromInputs = true;
        linkInputs = true;
      };
    };
  };
}
