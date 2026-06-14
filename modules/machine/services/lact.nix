{
  flake.modules.nixos.lact = {pkgs, ...}: {
    environment.systemPackages = [pkgs.lact];

    internal.boot.impermanence.extraFiles = [
      "/etc/lact/config.yaml"
    ];

    systemd.services.lactd = {
      description = "AMDGPU Control Daemon";
      after = ["multi-user.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig.ExecStart = "${pkgs.lact}/bin/lact daemon";
      enable = true;
    };
  };
}
