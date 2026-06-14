{
  flake.modules.nixos.bluetooth = {pkgs, ...}: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.systemPackages = [pkgs.bluetuith];

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/bluetooth"
    ];
  };
}
