{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.niri;
in {
  options.glace.desktop.niri = {
    enable = mkBoolOpt false "Whether to enable niri desktop environment.";
    screenshots = {
      builtin = mkBoolOpt true "Whether to enable the built-in screenshot functionality of niri.";
      path = mkOpt types.str "~/Pictures/screenshots" "The path where screenshots will be saved to disk.";
    };
    binds = {
      defaultAudioBinds = mkBoolOpt true "Whether to enable the default audio control binds that use wpctl.";
      defaultBrightnessBinds = mkBoolOpt true "Whether to enable the default brightness control binds that use brightnessctl.";
    };
    events = {
      defaultLidEvents = mkBoolOpt true "Whether to enable the default lid events.";
    };
  };

  imports = [
    ./binds.nix
    ./settings.nix
    ./displays.nix
    ./animations.nix
    ./environment.nix
    ./windowrules.nix
    ./xwayland.nix
  ];

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-stable;
    };
  };
}
