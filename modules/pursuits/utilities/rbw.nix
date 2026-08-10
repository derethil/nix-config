{
  flake.modules.nixos.rbw = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.rbw
      pkgs.pinentry-gnome3
    ];

    services.dbus.packages = [
      pkgs.gcr
    ];
  };
}
