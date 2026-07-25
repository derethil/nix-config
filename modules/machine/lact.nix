{
  flake.modules.nixos.lact = {pkgs, ...}: {
    environment.systemPackages = [pkgs.lact];

    internal.boot.impermanence.extraFiles = [
      "/etc/lact/config.yaml"
    ];

    systemd.services.lactd = {
      enable = true;
      after = ["multi-user.target"];
      description = "AMDGPU Control Daemon";
      serviceConfig.ExecStart = "${pkgs.lact}/bin/lact daemon";
      wantedBy = ["multi-user.target"];
    };
  };
}
