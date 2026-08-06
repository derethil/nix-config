{self, ...}: {
  flake.modules.nixos.restic = {config, ...}: let
    cacheDir = "/var/lib/restic/cache";
    healthChecksDomain = self.lib.homelab.mkServiceDomain config "healthchecks";
  in {
    key = "restic";

    imports = [
      self.modules.nixos.restic-backup
      self.modules.nixos.restic-maintenance
      self.modules.nixos.restic-options
      self.modules.nixos.restic-restore
      self.modules.nixos.secrets
      self.modules.nixos.impermanence-options
    ];

    config = {
      internal.boot.impermanence.extraDirectories = ["/var/lib/restic"];

      sops = {
        secrets = {
          "services/restic/b2_account_id" = {};
          "services/restic/b2_account_key" = {};
          "services/restic/healthchecks_ping_key" = {};
          "services/restic/repository" = {};
          "services/restic/repository_password" = {};
        };

        templates."restic-env".content = ''
          B2_ACCOUNT_ID=${config.sops.placeholder."services/restic/b2_account_id"}
          B2_ACCOUNT_KEY=${config.sops.placeholder."services/restic/b2_account_key"}
          HC_PING_URL=${healthChecksDomain}/ping/${config.sops.placeholder."services/restic/healthchecks_ping_key"}
          RESTIC_CACHE_DIR=${cacheDir}
        '';
      };
    };
  };
}
