{
  flake.modules.homeManager.niri = {
    lib,
    pkgs,
    ...
  }: {
    wayland.windowManager.niri.settings.xwayland-satellite.path =
      lib.getExe pkgs.unstable.xwayland-satellite;
  };
}
