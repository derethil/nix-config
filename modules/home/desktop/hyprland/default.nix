{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
in {
  options.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether to enable Hyprland desktop environment.";
    withPackage = mkBoolOpt false "Whether to use the Hyprland package from the Nixpkgs repository.";
    gap = mkOpt int 9 "Default outer gap size for Hyprland.";
  };

  imports = [
    ./displays.nix
    ./environment.nix
    ./settings.nix
    ./binds.nix
    ./layerrules.nix
    ./windowrules.nix
    ./workspacerules.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = mkMerge [
        (mkIf (!cfg.withPackage) null)
        (mkIf cfg.withPackage (config.lib.nixGL.wrap pkgs.hyprland))
      ];
      portalPackage = mkIf (!cfg.withPackage) null;
    };
  };
}
