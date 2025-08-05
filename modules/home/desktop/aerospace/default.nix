{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.desktop.aerospace;
in {
  options.desktop.aerospace = {
    enable = mkBoolOpt false "Whether or not to enable the Aerospace window manager.";
  };

  imports = [
    ./rules.nix
    ./binds.nix
    ./settings.nix
  ];

  config = mkIf cfg.enable {
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
    };
  };
}
