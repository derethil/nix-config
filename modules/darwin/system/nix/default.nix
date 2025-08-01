{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt mkOpt;
  inherit (lib.types) package;

  cfg = config.system.nix;
in {
  options.system.nix = {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
    package = mkOpt package pkgs.nixVersions.stable "Which nix package to use.";
  };

  config = mkIf cfg.enable {
    nix = let
      users = ["root" config.user.name];
    in {
      package = cfg.package;

      settings = {
        experimental-features = "nix-command flakes";
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
        sandbox = "relaxed";
        trusted-users = users;

        extra-nix-path = "nixpkgs=flake:nixpkgs";
        build-users-group = "nixbld";
      };

      optimise.automatic = true;

      gc = {
        automatic = true;
        interval = {Day = 7;};
        options = "--delete-older-than 30d";
      };

      # flake-utils-plus
      generateRegistryFromInputs = true;
      generateNixPathFromInputs = true;
      linkInputs = true;
    };
  };
}
