# This module provides a way to set the flake root directory as an option, which can be used by other modules that need to know the location of the flake root.
# If on NixOS or Darwin, set the option in the system configuration and pass it to Home Manager via sharedModules. If on Home Manager, just set the option.
{
  self,
  lib,
  ...
}: let
  flakeRootOption = lib.mkOption {
    type = lib.types.str;
    description = "Absolute path to the flake root directory.";
  };

  mkHomeManagerModule = flakeRoot: {
    config.internal.flakeRoot = lib.mkDefault flakeRoot;
  };
in {
  flake.modules = {
    nixos.flake-root = {config, ...}: {
      options.internal = {
        flakeRoot = flakeRootOption;
      };

      config.home-manager.sharedModules = [
        self.modules.homeManager.flake-root
        (mkHomeManagerModule config.internal.flakeRoot)
      ];
    };

    darwin.flake-root = {config, ...}: {
      options.internal = {
        flakeRoot = flakeRootOption;
      };

      config.home-manager.sharedModules = [
        self.modules.homeManager.flake-root
        (mkHomeManagerModule config.internal.flakeRoot)
      ];
    };

    homeManager.flake-root = {
      key = "flake-root-options";
      options.internal.flakeRoot = flakeRootOption;
    };
  };
}
