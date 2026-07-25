{
  self,
  lib,
  ...
}: let
  inherit (lib) mkIf;
in {
  flake.modules = {
    generic.nix-settings-common = {pkgs, ...}: {
      nix = {
        package = lib.mkDefault pkgs.nixVersions.stable;
        gc.options = "--delete-older-than 7d";

        settings = {
          abort-on-warn = false;
          experimental-features = ["flakes" "nix-command"];
          fallback = true;
          http-connections = 50;
          keep-derivations = true;
          keep-outputs = true;
          log-lines = 50;

          substituters = [
            "https://cache.nixos.org"
            "https://derethil.cachix.org"
            "https://nix-community.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "derethil.cachix.org-1:4v8v6Oo2UHdB3FKutgQ2z3O9L++ukejhGvQFg6Pjsfc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          use-xdg-base-directories = true;
          warn-dirty = false;
        };
      };
    };

    nixos.nix-settings = {config, ...}: {
      imports = [self.modules.generic.nix-settings-common];

      nix = {
        gc = {
          automatic = mkIf (!config.programs.nh.clean.enable) true;
          dates = "weekly";
        };

        optimise = {
          automatic = true;
          dates = ["03:45"];
          persistent = true;
        };

        settings = {
          sandbox = "relaxed";
          trusted-users = ["root"];
        };
      };
    };

    darwin.nix-settings = {
      imports = [self.modules.generic.nix-settings-common];

      nix = {
        gc = {
          automatic = true;

          interval = {
            # On sundays at 3:15am
            Hour = 3;
            Minute = 15;
            Weekday = 7;
          };
        };

        optimise.automatic = true;

        settings = {
          sandbox = false;
          trusted-users = ["root"];
        };
      };
    };

    homeManager.nix-settings = {config, ...}: {
      imports = [self.modules.generic.nix-settings-common];
      nix.gc.automatic = mkIf (!config.programs.nh.clean.enable) true;
    };
  };
}
