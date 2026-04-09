{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.lact;
in {
  options.glace.services.lact = {
    enable = mkBoolOpt false "Whether to enable LACT (Linux AMDGPU Control Tool).";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lact
    ];

    glace.system.impermanence.extraFiles = [
      "/etc/lact/config.yaml"
    ];

    systemd.services.lactd = {
      description = "AMDGPU Control Daemon";
      after = ["multi-user.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.lact}/bin/lact daemon";
      };
      enable = true;
    };
  };
}
