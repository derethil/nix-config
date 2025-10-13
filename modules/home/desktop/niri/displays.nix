{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf filter listToAttrs;
  cfg = config.glace.desktop.niri;
  displays = config.glace.hardware.displays;

  toNiriOutput = d: let
    outputConfig = {
      enable = true;
      focus-at-startup = d.primary;
      mode = {
        width = d.resolution.width;
        height = d.resolution.height;
        refresh = d.framerate / 1.0;
      };
      position = {
        x = d.position.x;
        y = d.position.y;
      };
      scale = d.scale;
      transform = {
        rotation = d.rotation;
        flipped = d.flipped;
      };
      variable-refresh-rate = d.vrr;
    };
  in {
    name = d.port;
    value = outputConfig;
  };
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      outputs = listToAttrs (map toNiriOutput (filter (d: d.enabled && d.port != null) displays));
    };
  };
}
