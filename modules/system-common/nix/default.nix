{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types optionalAttrs;
  inherit (lib.glace) mkBoolOpt mkOpt;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.glace.nix.config;
in {
  options.glace.nix.config = {
    enable = mkBoolOpt false "Whether to enable Nix configuration optimizations.";
    package = mkOpt types.package pkgs.nixVersions.stable "Which nix package to use.";
    extraTrustedUsers = mkOpt (types.listOf types.str) [] "List of trusted users.";
    garbageCollection.enable = mkBoolOpt false "Whether to enable automatic garbage collection.";
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
        trusted-users = ["root" config.glace.user.name] ++ cfg.extraTrustedUsers;
        fallback = true;
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
        sandbox = "relaxed";
        keep-outputs = true;
        keep-derivations = true;
        use-xdg-base-directories = true;
        abort-on-warn = true;
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://derethil.cachix.org"
          "https://hyprland.cachix.org"
          "https://niri.cachix.org"
          "https://attic.xuyh0120.win/lantian"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "derethil.cachix.org-1:4v8v6Oo2UHdB3FKutgQ2z3O9L++ukejhGvQFg6Pjsfc="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };

      gc = mkIf cfg.garbageCollection.enable (
        {
          automatic = true;
          options = "--delete-older-than 7d";
        }
        # darwin already defaults to weekly with interval = { Hour = 3; Minute = 15; Weekday = 7; }
        // optionalAttrs (!isDarwin) {
          dates = "weekly";
        }
      );
    };

    glace.nix.inputs = {
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
    };
  };
}
