{
  lib,
  inputs,
  pkgs,
  ...
}:
with pkgs;
  hyprlandPlugins.mkHyprlandPlugin hyprland {
    pluginName = "hyprXPrimary";
    version = "0.1";
    src = inputs.hypr-x-primary;
    nativeBuildInputs = [gnumake];
    preBuild = ''
      export HOME="$PWD"
    '';
    meta = with lib; {
      homepage = "https://github.com/zakk4223/hyprXPrimary";
      description = "Set XWayland primary monitor for Hyprland";
      license = licenses.bsd3;
      platforms = platforms.linux;
    };
  }
