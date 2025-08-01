{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  
  cfg = config.tools.nix-index;
in {
  options.tools.nix-index = {
    enable = mkBoolOpt false "Whether to enable nix-index for package/file searching.";
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = config.cli.fish.enable;
    };
  };
}