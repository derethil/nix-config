{
  flake.modules.nixos.coolercontrol = {pkgs, ...}: {
    programs.coolercontrol.enable = true;
    environment.systemPackages = [pkgs.lm_sensors];

    internal.boot.impermanence.extraDirectories = [
      "/etc/coolercontrol"
    ];
  };
}
