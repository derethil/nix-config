{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.tools.homebrew;
in {
  options.tools.homebrew = {
    enable = mkBoolOpt true "Whether to enable Homebrew configuration.";
    macApps = mkOpt (types.attrsOf types.int) {} "List of Mac App Store application IDs to install.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mas
    ];
    homebrew = {
      enable = true;
      masApps = mkIf (cfg.macApps != {}) cfg.macApps;
      onActivation = {
        cleanup = "zap";
      };
    };
  };
}
