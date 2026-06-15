{lib, ...}: {
  flake.modules.nixos.ntsync = {
    pkgs,
    config,
    ...
  }: {
    boot.kernelModules = ["ntsync"];

    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "ntsync-udev-rules";
        text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
        destination = "/etc/udev/rules.d/70-ntsync.rules";
      })
    ];

    assertions = [
      {
        assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
        message = "ntsync requires Linux 6.14+.";
      }
    ];
  };
}
