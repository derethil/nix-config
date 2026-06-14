{self, ...}: {
  flake.modules.homeManager.niri = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkIf mkMerge filter;

    toTransform = rotation: flipped:
      if flipped
      then
        if rotation == 0
        then "flipped"
        else "flipped-${toString rotation}"
      else if rotation == 0
      then "normal"
      else toString rotation;

    toNiriOutput = d:
      mkMerge [
        {
          _args = [d.port];
          mode = "${toString d.resolution.width}x${toString d.resolution.height}@${toString (d.framerate / 1.0)}";
          position._props = {
            x = d.position.x;
            y = d.position.y;
          };
          scale = d.scale;
          transform = toTransform d.rotation d.flipped;
        }
        (mkIf d.primary {focus-at-startup = [];})
        (mkIf (d.vrr != false) {
          variable-refresh-rate =
            if d.vrr == "on-demand"
            then {_props."on-demand" = true;}
            else {};
        })
      ];
  in {
    imports = [self.modules.homeManager.displays];

    wayland.windowManager.niri.settings.output =
      map toNiriOutput (filter (d: d.enabled && d.port != null) config.internal.displays);
  };
}
