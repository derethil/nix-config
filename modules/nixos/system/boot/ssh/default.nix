{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.system.boot.ssh;
in {
  options.glace.system.boot.ssh = {
    enable = mkBoolOpt false "Whether to enable OpenSSH key management for root-level initrd.";
  };

  config = mkIf cfg.enable {
    secrets."users/${config.glace.user.name}/ssh/public_key" = {};

    boot.initrd.network.ssh = {
      enable = true;
      authorizedKeyFiles = [
        config.sops.secrets."users/${config.glace.user.name}/ssh/public_key".path
      ];
    };
  };
}
