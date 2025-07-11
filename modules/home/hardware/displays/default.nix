{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  defaultPosition = {
    x = 0;
    y = 0;
  };

  display = types.submodule {
    options = with types; {
      name = mkOpt str "Monitor" "Human-readable name for the monitor";
      port = mkOpt str null "Monitor port/connector name (e.g., DP-1)";
      resolution = mkOpt str "1920x1080" "Monitor resolution in format WIDTHxHEIGHT";
      framerate = mkOpt int 60 "Monitor refresh rate in Hz";
      position = mkOpt (attrsOf int) defaultPosition "Monitor position coordinates";
      scale = mkOpt float 1.0 "Scaling factor for the monitor";
      enabled = mkBoolOpt true "Whether the monitor is enabled";
      rotation = mkOpt (enum ["0" "90" "180" "270"]) "0" "Monitor rotation";
      primary = mkBoolOpt false "Whether this is the primary monitor";
      vrr = mkOpt int 1 "Variable refresh rate setting for the monitor";
      wallpaper = mkOpt str null "Path to the wallpaper for this monitor";
    };
  };
in {
  options.hardware.displays = mkOpt (types.listOf display) [] "List of monitors to configure";

  config.assertions = let
    path = config.desktop.addons.wallpapers.sourceDir;
  in
    map (d: {
      assertion = d.wallpaper == null || pathExists "${path}/${d.wallpaper}";
      message = "wallpaper not found: ${path}/${d.wallpaper} for display ${d.name}";
    })
    config.hardware.displays;
}
