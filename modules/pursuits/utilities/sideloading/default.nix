{
  flake.modules.nixos.sideloading = {pkgs, ...}: {
    services.usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
    };

    environment.systemPackages = [
      pkgs.libimobiledevice
      pkgs.internal.iloader
    ];
  };
}
