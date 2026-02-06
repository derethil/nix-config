{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.coolercontrol;
in {
  imports = [
    ./amdgpu.nix
  ];

  options.glace.services.coolercontrol = {
    enable = mkBoolOpt false "Whether to enable CoolerControl for fan and pump control.";
  };

  config = mkIf cfg.enable {
    programs.coolercontrol.enable = true;
    environment.systemPackages = with pkgs; [
      lm_sensors
    ];
  };
}
