{
  flake.modules.nixos.sideloading = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.internal.iloader
      pkgs.libimobiledevice
    ];

    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };
  };
}
