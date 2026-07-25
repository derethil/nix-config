{
  flake.modules.nixos.coolercontrol = {pkgs, ...}: {
    environment.systemPackages = [pkgs.lm_sensors];

    internal.boot.impermanence.extraDirectories = [
      "/etc/coolercontrol"
    ];

    programs.coolercontrol.enable = true;
  };
}
