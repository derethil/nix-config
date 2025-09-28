{lib, ...}: let
  inherit (lib.internal) mkBoolOpt;
in {
  options.desktop.hyprland = {
    enable = mkBoolOpt false "Whether to enable Hyprland desktop environment.";
  };
}

