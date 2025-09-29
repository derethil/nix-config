{lib, ...}: let
  inherit (lib.glace) mkBoolOpt;
in {
  options.glace.desktop.hyprland = {
    enable = mkBoolOpt false "Whether to enable Hyprland desktop environment.";
  };
}

