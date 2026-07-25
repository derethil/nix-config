{
  flake.modules.nixos.bluetooth = {pkgs, ...}: {
    environment.systemPackages = [pkgs.bluetuith];

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/bluetooth"
    ];
  };
}
