{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.nix.cachix;
in {
  options.glace.tools.nix.cachix = {
    enable = mkBoolOpt false "Whether to enable cachix.";
  };

  config = mkIf cfg.enable {
    secrets."nix/cachix/local_auth_token" = {};

    home = {
      packages = [pkgs.cachix];
      sessionVariables.CACHIX_AUTH_TOKEN = "$(${getExe' pkgs.coreutils "cat"} ${config.sops.secrets."nix/cachix/local_auth_token".path})";
    };
  };
}
