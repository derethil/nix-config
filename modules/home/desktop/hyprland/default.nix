{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.hyprland;
in {
  options.glace.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether to enable Hyprland desktop environment.";
    gap = mkOpt int 9 "Default outer gap size for Hyprland.";
    binds = {
      defaultAudioBinds = mkBoolOpt true "Whether to enable the default audio control binds that use wpctl.";
      defaultBrightnessBinds = mkBoolOpt true "Whether to enable the default brightness control binds that use brightnessctl.";
    };
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
      package = config.lib.nixGL.wrap pkgs.hyprland;
      portalPackage = null;
      systemd.enable = false;
    };
  };
}
