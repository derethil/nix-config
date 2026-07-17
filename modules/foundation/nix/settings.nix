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
          experimental-features = ["nix-command" "flakes"];
          fallback = true;
          http-connections = 50;
          warn-dirty = false;
          log-lines = 50;
          keep-outputs = true;
          keep-derivations = true;
          use-xdg-base-directories = true;
          abort-on-warn = false;
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
            "https://derethil.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "derethil.cachix.org-1:4v8v6Oo2UHdB3FKutgQ2z3O9L++ukejhGvQFg6Pjsfc="
          ];
        };
      };
    };

    nixos.nix-settings = {config, ...}: {
      imports = [self.modules.generic.nix-settings-common];
      nix = {
        optimise = {
          automatic = true;
          persistent = true;
          dates = ["03:45"];
        };
        gc = {
          automatic = mkIf (!config.programs.nh.clean.enable) true;
          dates = "weekly";
        };
        settings = {
          trusted-users = ["root"];
          sandbox = "relaxed";
        };
      };
    };

    darwin.nix-settings = {
      imports = [self.modules.generic.nix-settings-common];
      nix = {
        optimise = {
          automatic = true;
        };
        gc = {
          automatic = true;
          interval = {
            # On sundays at 3:15am
            Hour = 3;
            Minute = 15;
            Weekday = 7;
          };
        };
        settings = {
          trusted-users = ["root"];
          sandbox = false;
        };
      };
    };

    homeManager.nix-settings = {config, ...}: {
      imports = [self.modules.generic.nix-settings-common];
      nix = {
        gc.automatic = mkIf (!config.programs.nh.clean.enable) true;
      };
    };
  };
}
