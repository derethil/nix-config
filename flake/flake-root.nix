# This module provides a way to set the flake root directory as an option, which can be used by other modules that need to know the location of the flake root.
# If on NixOS or Darwin, set the option in the system configuration and pass it to Home Manager via sharedModules. If on Home Manager, just set the option.
{
  self,
  lib,
  ...
}: let
  flakeRootOption = lib.mkOption {
    description = "Absolute path to the flake root directory.";
    type = lib.types.str;
  };

  mkHomeManagerModule = flakeRoot: {
    config.internal.flakeRoot = lib.mkDefault flakeRoot;
  };
in {
  flake.modules = {
    nixos.flake-root = {config, ...}: {
      options.internal.flakeRoot = flakeRootOption;

      config.home-manager.sharedModules = [
        (mkHomeManagerModule config.internal.flakeRoot)
        self.modules.homeManager.flake-root
      ];
    };

    darwin.flake-root = {config, ...}: {
      options.internal.flakeRoot = flakeRootOption;

      config.home-manager.sharedModules = [
        (mkHomeManagerModule config.internal.flakeRoot)
        self.modules.homeManager.flake-root
      ];
    };

    homeManager.flake-root = {
      key = "flake-root-options";
      options.internal.flakeRoot = flakeRootOption;
    };
  };
}
