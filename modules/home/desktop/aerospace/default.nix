{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.aerospace;
in {
  disabledModules = ["programs/aerospace.nix"];

  imports = [
    "${inputs.home-manager-unstable.outPath}/modules/programs/aerospace.nix"
    ./rules.nix
    ./binds.nix
    ./settings.nix
  ];

  options.glace.desktop.aerospace = {
    enable = mkBoolOpt false "Whether or not to enable the Aerospace window manager.";
  };

  config = mkIf cfg.enable {
    programs.aerospace = {
      enable = true;
      launchd.enable = true;
    };
  };
}
