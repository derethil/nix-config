{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.tools.nh;
in {
  options.tools.nh = {
    enable = mkBoolOpt false "Whether to enable nh (Nix helper) configuration.";
    clean.enable = mkBoolOpt true "Whether to enable automatic nh clean service.";
    flake = mkOpt types.str "~/.config/nix-config" "Path to the flake directory.";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = cfg.clean.enable;
      clean.extraArgs = "--keep-since 7d --keep 3";
      inherit (cfg) flake;
    };
  };
}
