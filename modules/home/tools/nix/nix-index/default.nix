{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.tools.nix.nix-index;
in {
  options.glace.tools.nix.nix-index = {
    enable = mkBoolOpt false "Whether to enable nix-index for package/file searching.";
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = config.glace.cli.fish.enable;
    };
  };
}

