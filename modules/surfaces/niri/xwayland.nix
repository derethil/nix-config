{
  flake.modules.homeManager.niri = {
    pkgs,
    lib,
    ...
  }: {
    wayland.windowManager.niri.settings.xwayland-satellite.path =
      lib.getExe pkgs.unstable.xwayland-satellite;
  };
}
