{self, ...}: {
  flake.modules.homeManager.niri = {
    config,
    lib,
    ...
  }: let
    inherit (lib) filter mkIf mkMerge;

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
        (mkIf (d.vrr != false) {
          variable-refresh-rate =
            if d.vrr == "on-demand"
            then {_props."on-demand" = true;}
            else {};
        })
        (mkIf d.primary {focus-at-startup = [];})
        {
          inherit (d) scale;
          _args = [d.port];
          mode = "${toString d.resolution.width}x${toString d.resolution.height}@${toString (d.framerate / 1.0)}";

          position._props = {
            x = d.position.x;
            y = d.position.y;
          };

          transform = toTransform d.rotation d.flipped;
        }
      ];
  in {
    imports = [self.modules.homeManager.displays];

    wayland.windowManager.niri.settings.output =
      map toNiriOutput (filter (d: d.enabled && d.port != null) config.internal.displays);
  };
}
